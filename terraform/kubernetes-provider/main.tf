# ============================================================================
# ☸️ TERRAFORM + KUBERNETES PROVIDER
# ============================================================================
# SIMPLE ANALOGY:
# Instead of manually running kubectl commands, Terraform reads blueprints
# (this file) and creates Kubernetes resources for you. It's like having a
# construction manager who builds AND maintains your infrastructure.
#
# WHY TERRAFORM FOR KUBERNETES?
# - Declarative: Describe what you want, Terraform figures out how
# - Reproducible: Same code = same infrastructure every time
# - Version controlled: Track changes to your K8s resources over time
# - Multi-cloud: Same tool works for AWS, Azure, GCP, on-prem
# - Diff/Plan: See changes before applying them (unlike kubectl apply)
# ============================================================================

# ============================================================================
# TERRAFORM BLOCK: Configuration
# ============================================================================
terraform {
  required_version = ">= 1.0"

  required_providers {
    # KUBERNETES PROVIDER: Manages Kubernetes resources
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
      
      # WHY THIS PROVIDER?
      # It translates Terraform code into Kubernetes API calls
      # Like a translator who speaks both Terraform and Kubernetes
    }
  }
}

# ============================================================================
# PROVIDER BLOCK: Configure Kubernetes connection
# ============================================================================
# HOW DOES TERRAFORM CONNECT TO KUBERNETES?
# It reads your kubeconfig file (same file kubectl uses)
#
# THE BACKSTORY:
# When you installed Rancher Desktop, it created a kubeconfig file at:
# Windows: C:\Users\<YourName>\.kube\config
# Mac/Linux: ~/.kube/config
#
# This file contains:
# - Cluster address (where Kubernetes is running)
# - Authentication credentials (certificates, tokens)
# - Context (which cluster to use)
#
# ANALOGY: Like a phone book with your saved contacts
# "To call 'rancher-desktop', dial this number with this password"
# ============================================================================
provider "kubernetes" {
  # CONFIG_PATH: Where to find kubeconfig
  # "~/.kube/config" works on all platforms
  # ~ = your home directory (C:\Users\<Name>\ on Windows)
  #
  # ALTERNATIVE: Can also use environment variable KUBECONFIG
  # or auto-detect (leave this blank)
  config_path = "~/.kube/config"
  
  # CONFIG_CONTEXT: Which context to use from kubeconfig
  # A context is a combination of: cluster + user + namespace
  #
  # Rancher Desktop creates a context called "rancher-desktop"
  # If you have multiple clusters (AWS, Azure, local), you switch contexts
  #
  # ANALOGY: Like having multiple phone lines (work, personal)
  # and choosing which one to dial from
  config_context = "rancher-desktop"
}

# ============================================================================
# RESOURCE: kubernetes_namespace
# ============================================================================
# WHAT IS A NAMESPACE?
# A virtual cluster within a cluster. Provides isolation between projects/teams.
#
# ANALOGY: Different departments in a building (Sales, Engineering, HR)
# Each department has their own space but shares the building
#
# WHY CREATE A NAMESPACE?
# - Organization: Keep dev/staging/prod separate
# - Security: Apply different permissions per namespace
# - Resource quotas: Limit CPU/memory per namespace
# - Avoid conflicts: Two teams can both have a "frontend" deployment
#                    if they're in different namespaces
# ============================================================================
resource "kubernetes_namespace" "terraform_demo" {
  # METADATA: Information about the namespace
  metadata {
    # NAME: What to call this namespace
    # You'll use this in kubectl commands: kubectl get pods -n terraform-demo
    name = "terraform-demo"
    
    # LABELS: Tags for organization
    # Like sticky notes on folders
    labels = {
      managed-by = "terraform"  # Who created this?
      environment = "demo"       # What's it for?
      app = "dotnet-todo"       # Which app?
    }
    
    # ANNOTATIONS: Additional metadata (not used for selection)
    # Like writing notes on the folder
    annotations = {
      description = "Namespace created by Terraform for demo purposes"
    }
  }
}

# ============================================================================
# RESOURCE: kubernetes_deployment
# ============================================================================
# A Deployment manages Pods - ensures the desired number are always running
#
# ANALOGY: Restaurant manager who ensures you always have 2 chefs working
# If one chef quits, the manager hires a replacement immediately
# ============================================================================
resource "kubernetes_deployment" "dotnet_api" {
  # METADATA: Information about this Deployment
  metadata {
    name      = "dotnet-api"
    # NAMESPACE: Which namespace to create this in
    # We reference the namespace we created above
    # kubernetes_namespace.terraform_demo.metadata[0].name
    #   = "terraform-demo"
    namespace = kubernetes_namespace.terraform_demo.metadata[0].name
    
    labels = {
      app = "dotnet-api"
    }
  }

  # SPEC: The desired state (what you want)
  spec {
    # REPLICAS: How many Pods to run
    # 2 = high availability (if one crashes, the other keeps working)
    replicas = 2
    
    # SELECTOR: How to find Pods managed by this Deployment
    # "Find all Pods with label app=dotnet-api"
    #
    # ANALOGY: Like finding all employees wearing "Kitchen Staff" name tags
    selector {
      match_labels = {
        app = "dotnet-api"
      }
    }

    # TEMPLATE: Blueprint for creating Pods
    # Every Pod created by this Deployment uses this template
    template {
      # METADATA: Labels for Pods
      # ⚠️ Must match selector.match_labels above!
      metadata {
        labels = {
          app = "dotnet-api"
        }
      }

      # SPEC: What's inside each Pod
      spec {
        # CONTAINERS: List of containers in this Pod
        # (Usually just one container per Pod)
        container {
          # NAME: Name of this container (for kubectl logs)
          name  = "api"
          
          # IMAGE: Which Docker image to run
          # This assumes you've already built the image locally:
          # docker build -t dotnet-api:latest ./backend
          #
          # ⚠️ IMPORTANT: For local images, you MUST set imagePullPolicy = Never
          image = "dotnet-api:latest"
          
          # IMAGE_PULL_POLICY: When to pull the image from a registry
          # - Always: Pull before every Pod start (default for :latest tag)
          # - IfNotPresent: Only pull if not on the node
          # - Never: Never pull, use local image only (for development)
          #
          # WHY "Never"?
          # We built the image locally with Docker, it's not in a registry
          # If we try to pull, it'll fail!
          #
          # ANALOGY: "Never" = use homemade cookies from your kitchen
          #          "Always" = always buy cookies from the store
          image_pull_policy = "Never"

          # PORT: Ports exposed by this container
          port {
            container_port = 5000  # .NET API listens on 5000
            name          = "http"
            protocol      = "TCP"
          }

          # ENV: Environment variables
          # Configuration passed to the container
          env {
            name  = "ASPNETCORE_URLS"
            value = "http://+:5000"
          }
          
          env {
            name  = "DYNAMODB_ENDPOINT"
            # Notice: We use the Service name!
            # Kubernetes DNS will resolve "dynamodb-service" to the Pod IP
            #
            # THE BACKSTORY:
            # Services create DNS entries: <service-name>.<namespace>.svc.cluster.local
            # Short form: <service-name> (if in same namespace)
            #
            # ANALOGY: Like using a person's name instead of phone number
            # Kubernetes is the phonebook that looks up the number
            value = "http://dynamodb-service:8000"
          }

          # RESOURCES: CPU and memory limits
          # Prevents one Pod from hogging all resources
          resources {
            # REQUESTS: Minimum guaranteed resources
            # "I need at least this much to start"
            requests = {
              memory = "256Mi"  # 256 megabytes of RAM
              cpu    = "250m"   # 250 millicores = 25% of one CPU
            }
            
            # LIMITS: Maximum allowed resources
            # "Don't let me use more than this"
            # If exceeded:
            # - Memory: Pod is killed (OOMKilled)
            # - CPU: Pod is throttled (slowed down)
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          # PROBES REMOVED FOR FASTER DEMO DEPLOYMENT
          # In production, you'd want readiness/liveness probes!
          # But they slow down "terraform apply" because Terraform waits
          # for them to pass. For learning purposes, we skip them.
        }
      }
    }
  }
}

# ============================================================================
# RESOURCE: kubernetes_service
# ============================================================================
# A Service provides a stable network endpoint for Pods
# Even if Pods die and get new IPs, the Service name stays the same
#
# ANALOGY: A restaurant's phone number. Employees change, but customers
# always call the same number
# ============================================================================
resource "kubernetes_service" "dotnet_api" {
  metadata {
    name      = "dotnet-api-service"
    namespace = kubernetes_namespace.terraform_demo.metadata[0].name
  }

  spec {
    # SELECTOR: Which Pods does this Service route to?
    # "Route traffic to all Pods with label app=dotnet-api"
    #
    # DYNAMIC: As Pods are created/destroyed, the Service automatically
    # updates its list of targets (Endpoints)
    selector = {
      app = "dotnet-api"
    }

    # TYPE: How is this Service exposed?
    # - ClusterIP: Only accessible within the cluster (default)
    # - NodePort: Accessible on a port on every node (30000-32767)
    # - LoadBalancer: Creates a cloud load balancer (AWS/Azure/GCP only)
    #
    # WHY ClusterIP?
    # The API is internal - only the frontend needs to call it
    # We don't want external users hitting the API directly
    #
    # ANALOGY: ClusterIP = internal phone extension (only employees)
    #          NodePort = public phone number (anyone can call)
    type = "ClusterIP"

    # PORT: Port configuration
    port {
      # PORT: The Service listens on this port
      # Other Pods will call: http://dotnet-api-service:5000
      port        = 5000
      
      # TARGET_PORT: Forward to this port on the Pod
      # The container listens on 5000, so we forward to 5000
      target_port = 5000
      
      protocol    = "TCP"
      name        = "http"
    }
  }
}

# ============================================================================
# DYNAMODB DEPLOYMENT & SERVICE
# ============================================================================
# NOW INCLUDED! This creates the DynamoDB database so the API works properly
# ============================================================================

resource "kubernetes_deployment" "dynamodb" {
  metadata {
    name      = "dynamodb"
    namespace = kubernetes_namespace.terraform_demo.metadata[0].name
    labels = {
      app = "dynamodb"
    }
  }

  spec {
    replicas = 1  # Only 1 replica for database!

    selector {
      match_labels = {
        app = "dynamodb"
      }
    }

    template {
      metadata {
        labels = {
          app = "dynamodb"
        }
      }

      spec {
        container {
          name  = "dynamodb"
          image = "amazon/dynamodb-local:latest"

          port {
            container_port = 8000
          }

          args = ["-jar", "DynamoDBLocal.jar", "-inMemory", "-sharedDb"]

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "dynamodb" {
  metadata {
    name      = "dynamodb-service"
    namespace = kubernetes_namespace.terraform_demo.metadata[0].name
  }

  spec {
    selector = {
      app = "dynamodb"
    }

    type = "ClusterIP"

    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
    }
  }
}

# ============================================================================
# OUTPUTS
# ============================================================================
output "namespace_name" {
  description = "Name of the created namespace"
  value       = kubernetes_namespace.terraform_demo.metadata[0].name
}

output "deployment_name" {
  description = "Name of the API deployment"
  value       = kubernetes_deployment.dotnet_api.metadata[0].name
}

output "service_name" {
  description = "Name of the API service"
  value       = kubernetes_service.dotnet_api.metadata[0].name
}

output "service_endpoint" {
  description = "Internal service endpoint (accessible within cluster)"
  value       = "http://${kubernetes_service.dotnet_api.metadata[0].name}.${kubernetes_namespace.terraform_demo.metadata[0].name}.svc.cluster.local:5000"
}

# ============================================================================
# HOW TO USE THIS FILE
# ============================================================================
# PREREQUISITES:
# 1. Rancher Desktop running with Kubernetes enabled
# 2. kubectl configured (check with: kubectl cluster-info)
# 3. Docker image built: docker build -t dotnet-api:latest ./backend
#
# STEPS:
# 1. Navigate to this directory:
#    cd terraform/kubernetes-provider
#
# 2. Initialize Terraform:
#    terraform init
#
# 3. Preview changes:
#    terraform plan
#
# 4. Apply changes:
#    terraform apply
#
# 5. Verify:
#    kubectl get all -n terraform-demo
#
# 6. Check Pods:
#    kubectl get pods -n terraform-demo
#
# 7. View logs:
#    kubectl logs -n terraform-demo -l app=dotnet-api
#
# 8. Destroy everything:
#    terraform destroy
#
# ============================================================================
# TERRAFORM vs KUBECTL
# ============================================================================
# WHY USE TERRAFORM INSTEAD OF KUBECTL?
#
# KUBECTL:
# ✅ Quick and easy for one-off changes
# ✅ Good for debugging (logs, exec, port-forward)
# ❌ Hard to track what you've created
# ❌ No "undo" - you must remember what to delete
# ❌ No "preview" - changes happen immediately
#
# TERRAFORM:
# ✅ Infrastructure as Code (version controlled)
# ✅ "Plan" shows changes before applying
# ✅ "Destroy" removes everything you created
# ✅ State tracking (knows what it manages)
# ✅ Can manage multiple clouds (AWS + Azure + K8s in one file!)
# ❌ More complex initial setup
# ❌ Another tool to learn
#
# ANALOGY:
# kubectl = Using a hammer and nails (direct, immediate)
# Terraform = Using blueprints and a construction crew (planned, reproducible)
#
# WHEN TO USE WHICH?
# - Development/Debugging: kubectl (fast iteration)
# - Production/Team projects: Terraform (reproducible, auditable)
# - Quick fixes: kubectl
# - Infrastructure setup: Terraform
#
# BEST PRACTICE:
# Use Terraform for infrastructure (deployments, services, namespaces)
# Use kubectl for operations (logs, exec, port-forward, debugging)
# ============================================================================

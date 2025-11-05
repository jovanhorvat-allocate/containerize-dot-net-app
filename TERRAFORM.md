# Terraform — Infrastructure as Code (IaC)

> **Construction Analogy**: Terraform is like a **construction manager** who reads blueprints (`.tf` files) and builds your infrastructure. Instead of manually hammering nails (running docker/kubectl commands), you hand over blueprints and the manager builds everything for you.

---

## What is Terraform?

**Terraform** is an Infrastructure as Code (IaC) tool that lets you define and manage infrastructure using code files instead of manual commands.

### The Problem Terraform Solves

**Without Terraform (Manual Way):**
```bash
# You type commands one by one
docker build -t my-api .
docker run -d --name api -p 5000:5000 my-api
kubectl create namespace prod
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
# ... dozens more commands ...
```

**Problems:**
- ❌ Have to remember every command you ran
- ❌ Hard to replicate on another machine
- ❌ No way to "undo" everything at once
- ❌ Can't see what will change before running commands
- ❌ Team members might set things up differently

**With Terraform (Infrastructure as Code):**
```hcl
# You write a blueprint file (main.tf)
resource "docker_container" "api" {
  name  = "api"
  image = "my-api"
  ports {
    internal = 5000
    external = 5000
  }
}
```

```bash
# Then run one command
terraform apply
```

**Benefits:**
- ✅ Everything is documented in code
- ✅ Version controlled (track changes with Git)
- ✅ Reproducible (same code = same infrastructure every time)
- ✅ Preview changes before applying (`terraform plan`)
- ✅ Easy cleanup (`terraform destroy` removes everything)
- ✅ Team collaboration (everyone uses the same code)

---

## Terraform Glossary (With Analogies)

### 🏗️ **Terraform**
**What?** A tool that reads configuration files and creates infrastructure.

**Analogy**: A **construction manager** who reads blueprints and builds buildings. You hand over the plans, they coordinate all the workers (Docker, Kubernetes, AWS, etc.) to build what you specified.

---

### 📄 **.tf Files**
**What?** Terraform configuration files written in HCL (HashiCorp Configuration Language).

**Analogy**: **Architectural blueprints**. They describe what you want to build, not how to build it. Terraform figures out the "how."

---

### 🔌 **Provider**
**What?** A plugin that allows Terraform to interact with a specific platform (Docker, Kubernetes, AWS, Azure, etc.).

**Analogy**: A **specialized contractor**. The construction manager (Terraform) hires a Docker contractor, a Kubernetes contractor, or an AWS contractor depending on what you're building.

**Examples:**
- `provider "docker"` → Manages Docker containers/images
- `provider "kubernetes"` → Manages K8s deployments/services
- `provider "aws"` → Manages EC2 instances/S3 buckets

---

### 📦 **Resource**
**What?** A thing Terraform creates and manages (container, deployment, S3 bucket, etc.).

**Analogy**: A **building component** in your construction project. Could be a room, a door, a window, etc.

**Syntax:**
```hcl
resource "TYPE" "NAME" {
  # configuration...
}
```

**Example:**
```hcl
resource "docker_container" "web" {
  name  = "nginx-web"
  image = "nginx:latest"
}
```
- `docker_container` = resource type (what kind of thing)
- `web` = resource name (your nickname for it)

---

### 📊 **Data Source**
**What?** A way to READ information without creating anything. Like a "lookup" or "query."

**Analogy**: Looking up a part number in a catalog before ordering. You're not buying yet, just finding specifications.

**Example:**
```hcl
data "docker_registry_image" "nginx" {
  name = "nginx:latest"
}
```
This fetches info about the nginx image from Docker Hub.

---

### 📝 **Variable**
**What?** A placeholder for values you can customize without changing the code.

**Analogy**: Like a form with blank fields. "Enter your name: ____". Different people fill in different values.

**Example:**
```hcl
variable "replicas" {
  default = 2
}

resource "kubernetes_deployment" "app" {
  spec {
    replicas = var.replicas  # Use the variable
  }
}
```

---

### 📤 **Output**
**What?** Values displayed after Terraform finishes. Like a receipt showing what was created.

**Analogy**: The construction manager hands you keys and says "Here's your new building, address: 123 Main St."

**Example:**
```hcl
output "api_url" {
  value = "http://localhost:5000"
}
```

After `terraform apply`, you'll see:
```
Outputs:
api_url = "http://localhost:5000"
```

---

### 💾 **State (terraform.tfstate)**
**What?** A file that tracks what Terraform has created. It's Terraform's "memory."

**Analogy**: A construction project's **logbook**. "We built a fence on June 1st, painted it blue, 10 feet tall." Next day: "The logbook says we have a fence, so I won't build another one."

**Why Important?**
- Terraform compares your code to the state file
- Determines what needs to be created/updated/deleted
- Without state, Terraform has no memory of what it built

**⚠️ WARNING:** Never delete `terraform.tfstate`! You'll lose track of your infrastructure.

**Location:** Same directory as your `.tf` files (by default).

---

### 🎯 **Desired State**
**What?** What you've defined in your `.tf` files. This is what you WANT.

**Analogy**: An architect's blueprint showing the finished building.

---

### 🔍 **Actual State**
**What?** What currently exists in reality (actual Docker containers, K8s pods, etc.).

**Analogy**: The actual building that's been constructed so far.

---

### 🔄 **Reconciliation**
**What?** Terraform compares desired state (code) to actual state (reality) and makes changes to match.

**Analogy**: A building inspector comparing the blueprint to the actual building. If the blueprint says "3 windows" but there are only 2, the inspector tells workers to add one more.

---

### 📋 **Plan**
**What?** A preview of what Terraform will do. Shows additions, changes, deletions.

**Command:** `terraform plan`

**Analogy**: A construction estimate. "We'll add 2 rooms, repaint 1 room, demolish 1 shed."

**Output Symbols:**
- `+` = will be created
- `~` = will be modified
- `-` = will be destroyed

---

### ✅ **Apply**
**What?** Execute the plan. Actually make the changes.

**Command:** `terraform apply`

**Analogy**: Giving the green light to start construction. Workers begin building.

---

### 💥 **Destroy**
**What?** Delete everything Terraform created.

**Command:** `terraform destroy`

**Analogy**: Demolishing the entire building. Terraform removes all resources it knows about (from the state file).

---

### 🔄 **Idempotent**
**What?** Running the same Terraform code multiple times produces the same result.

**Analogy**: Asking "Please make sure the door is closed." If it's already closed, nothing happens. If it's open, it gets closed. Either way, end result is the same: door closed.

**Example:**
```bash
terraform apply  # Creates resources
terraform apply  # Does nothing (already exists)
terraform apply  # Still does nothing
```

---

## Two Terraform Examples

We provide two examples in the `terraform/` directory:

### 1️⃣ **Docker Provider** (`terraform/docker-provider/`)
**What?** Uses Terraform to build Docker images and create containers.

**Analogy**: Using blueprints to build a **food truck** (single machine, local development).

**What It Does:**
- Builds the .NET API Docker image (from backend/Dockerfile)
- Creates and runs a container
- Exposes on port 5001

**Use Case:** Local development, reproducible Docker setups.

---

### 2️⃣ **Kubernetes Provider** (`terraform/kubernetes-provider/`)
**What?** Uses Terraform to create Kubernetes resources (namespace, deployment, service).

**Analogy**: Using blueprints to build a **restaurant chain** (multiple locations, production-ready).

**What It Does:**
- Creates a namespace (`terraform-demo`)
- Creates a deployment (2 replicas of .NET API)
- Creates a service (load balancer for the API)

**Use Case:** Production deployments, team collaboration, multi-environment setups (dev/staging/prod).

---

## Prerequisites

✅ **Terraform installed**
- Download: https://www.terraform.io/downloads
- Or use package manager:
  - Windows: `choco install terraform`
  - Mac: `brew install terraform`
  - Linux: `sudo apt install terraform`

✅ **Docker running** (for Docker provider example)

✅ **Kubernetes running** (for Kubernetes provider example)
- Rancher Desktop with Kubernetes enabled

---

## Example 1: Terraform + Docker Provider

### Step 1: Navigate to the Directory

```powershell
cd terraform/docker-provider
```

---

### Step 2: Initialize Terraform

```powershell
terraform init
```

**What Happens?**
- Downloads the Docker provider plugin
- Creates `.terraform/` directory (stores plugins)
- Creates `.terraform.lock.hcl` (locks provider versions)

**Analogy**: Hiring contractors before starting construction. "We need a Docker contractor, let me find one..."

**Expected Output:**
```
Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "~> 3.0"...
- Installing kreuzwerker/docker v3.0.2...

Terraform has been successfully initialized!
```

---

### Step 3: Preview Changes (Plan)

```powershell
terraform plan
```

**What Happens?**
- Reads your `main.tf` file
- Compares to current state (nothing exists yet)
- Shows what will be created

**Analogy**: Construction estimate. "Here's what we'll build..."

**Expected Output:**
```
Terraform will perform the following actions:

  # docker_image.dotnet_api will be created
  + resource "docker_image" "dotnet_api" {
      + name         = "dotnet-api:terraform"
      ...
    }

  # docker_container.dotnet_api will be created
  + resource "docker_container" "dotnet_api" {
      + name  = "dotnet-api-terraform"
      + image = (known after apply)
      ...
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

**Symbols:**
- `+` = will be created
- `~` = will be modified
- `-` = will be destroyed

---

### Step 4: Apply Changes

```powershell
terraform apply
```

**What Happens?**
1. Shows the plan again
2. Asks for confirmation: `Do you want to perform these actions?`
3. Type `yes` and press Enter
4. Builds Docker image (reads backend/Dockerfile)
5. Creates and starts container

**Analogy**: Green-lighting construction. "Yes, build it!"

**Expected Output:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_image.dotnet_api: Creating...
docker_image.dotnet_api: Creation complete after 45s
docker_container.dotnet_api: Creating...
docker_container.dotnet_api: Creation complete after 2s

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

api_url = "http://localhost:5001/api/todos"
container_name = "dotnet-api-terraform"
image_id = "sha256:f7916af0c0d1..."
```

---

### Step 5: Verify

```powershell
# Check Docker containers
docker ps

# Test the API
curl http://localhost:5001/api/todos
```

**You Should See:**
- Container named `dotnet-api-terraform` running
- API responding on port 5001

---

### Step 6: View State

```powershell
terraform show
```

**What Happens?**
- Displays the current state in human-readable format
- Shows all resources Terraform is managing

**Analogy**: Checking the construction logbook. "What have we built so far?"

---

### Step 7: Destroy Everything

```powershell
terraform destroy
```

**What Happens?**
1. Shows what will be destroyed
2. Asks for confirmation
3. Deletes the container
4. Keeps the image (because `keep_locally = true`)

**Analogy**: Demolishing the building but keeping the blueprints.

**Expected Output:**
```
Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Enter a value: yes

docker_container.dotnet_api: Destroying...
docker_container.dotnet_api: Destruction complete after 1s
docker_image.dotnet_api: Destroying...
docker_image.dotnet_api: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```

---

## Example 2: Terraform + Kubernetes Provider

### Step 1: Build Docker Image First

```powershell
# Kubernetes needs a local image to run
docker build -t dotnet-api:latest ./backend
```

**Why?**
The Kubernetes example uses `imagePullPolicy: Never`, meaning it won't pull from a registry - it expects the image to exist locally.

---

### Step 2: Navigate to Directory

```powershell
cd terraform/kubernetes-provider
```

---

### Step 3: Initialize Terraform

```powershell
terraform init
```

**Expected Output:**
```
Initializing provider plugins...
- Finding hashicorp/kubernetes versions matching "~> 2.23"...
- Installing hashicorp/kubernetes v2.23.0...

Terraform has been successfully initialized!
```

---

### Step 4: Plan

```powershell
terraform plan
```

**What You'll See:**
- Creates namespace `terraform-demo`
- Creates deployment `dynamodb` (1 replica)
- Creates service `dynamodb-service`
- Creates deployment `dotnet-api` (2 replicas)
- Creates service `dotnet-api-service`

**Expected Output:**
```
Plan: 5 to add, 0 to change, 0 to destroy.
```

**Note:** The Kubernetes example includes DynamoDB deployment so the API has a working database. This creates a complete, functional stack.

---

### Step 5: Apply

```powershell
terraform apply
```

Type `yes` when prompted.

**What Happens?**
1. Creates namespace first
2. Creates both services (dotnet-api-service and dynamodb-service)
3. Creates both deployments (API and DynamoDB)
4. Waits briefly for resources to stabilize

**Expected Output:**
```
kubernetes_namespace.terraform_demo: Creating...
kubernetes_namespace.terraform_demo: Creation complete after 0s
kubernetes_service.dynamodb: Creating...
kubernetes_service.dotnet_api: Creating...
kubernetes_deployment.dotnet_api: Creating...
kubernetes_deployment.dynamodb: Creating...
kubernetes_service.dynamodb: Creation complete after 0s
kubernetes_service.dotnet_api: Creation complete after 0s
kubernetes_deployment.dotnet_api: Creation complete after 2s
kubernetes_deployment.dynamodb: Creation complete after 4s

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

namespace_name = "terraform-demo"
deployment_name = "dotnet-api"
service_name = "dotnet-api-service"
service_endpoint = "http://dotnet-api-service.terraform-demo.svc.cluster.local:5000"
```

**⚡ Fast Deployment:** This completes in ~4 seconds because:
- No readiness/liveness probes (removed for demo speed)
- Images already exist locally
- No need to wait for health checks

**📝 Production Note:** In a real environment, you'd want readiness and liveness probes to ensure Pods are healthy before receiving traffic. They were removed here to make `terraform apply` complete faster for learning purposes.

---

### Step 6: Verify with kubectl

```powershell
# Check namespace
kubectl get namespaces | grep terraform

# Check resources in namespace
kubectl get all -n terraform-demo

# Check pods
kubectl get pods -n terraform-demo

# Check logs
kubectl logs -n terraform-demo -l app=dotnet-api
```

**Expected Output:**
```
NAME                          READY   STATUS    RESTARTS   AGE
dotnet-api-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
dotnet-api-xxxxxxxxxx-yyyyy   1/1     Running   0          2m
dynamodb-xxxxxxxxxx-zzzzz     1/1     Running   0          2m
```

**You should see:**
- ✅ 2 API Pods (because replicas = 2)
- ✅ 1 DynamoDB Pod
- ✅ 2 Services (dotnet-api-service and dynamodb-service)

---

### Step 7: Destroy

```powershell
terraform destroy
```

Type `yes` when prompted.

**What Happens?**
- Deletes both Services (dotnet-api-service and dynamodb-service)
- Deletes both Deployments (which deletes all Pods)
- Deletes the Namespace

**Expected Output:**
```
Plan: 0 to add, 0 to change, 5 to destroy.

kubernetes_deployment.dotnet_api: Destroying...
kubernetes_deployment.dynamodb: Destroying...
kubernetes_service.dotnet_api: Destroying...
kubernetes_service.dynamodb: Destroying...
kubernetes_namespace.terraform_demo: Destroying...

Destroy complete! Resources: 5 destroyed.
```

---

## Understanding Health Probes (And Why We Removed Them)

### What Are Health Probes?

**Readiness Probe** - "Is the container ready to accept traffic?"
- Kubernetes won't send traffic until this passes
- Used during startup and rolling updates

**Liveness Probe** - "Is the container still healthy?"
- If it fails repeatedly, Kubernetes restarts the container
- Used to detect hung or crashed processes

### Why They're Important in Production

```hcl
readiness_probe {
  http_get {
    path = "/api/todos"
    port = 5000
  }
  initial_delay_seconds = 10
  period_seconds        = 5
  failure_threshold     = 3
}
```

**Benefits:**
- ✅ Zero-downtime deployments
- ✅ Traffic only sent to healthy Pods
- ✅ Automatic recovery from crashes

### Why We Removed Them From This Demo

**The Problem:**
- With `wait_for_rollout = true` (Terraform default), Terraform waits for all Pods to become "Ready"
- Readiness probe needs the API to respond successfully
- API needs DynamoDB to be ready first
- **Result:** `terraform apply` took 2+ minutes waiting for health checks

**The Solution:**
- Removed readiness and liveness probes from the demo config
- **Result:** `terraform apply` completes in ~4 seconds

**Trade-off:**
- ✅ **Faster learning experience** - see results immediately
- ❌ **Less production-ready** - no health checking

### Adding Probes Back (Optional)

If you want to see probes in action, you can add them back to `main.tf`:

```hcl
# Inside the container block
readiness_probe {
  http_get {
    path = "/api/todos"
    port = 5000
  }
  initial_delay_seconds = 10
  period_seconds        = 5
}

liveness_probe {
  http_get {
    path = "/api/todos"
    port = 5000
  }
  initial_delay_seconds = 30
  period_seconds        = 10
}
```

Then run:
```bash
terraform apply
# This will now wait ~30-60 seconds for probes to pass
```

---

## Terraform Workflow Summary

```
1. Write Code (main.tf)
   ↓
2. terraform init (download providers)
   ↓
3. terraform plan (preview changes)
   ↓
4. terraform apply (create infrastructure)
   ↓
5. terraform show (view current state)
   ↓
6. terraform destroy (cleanup)
```

---

## Terraform vs Manual Commands

| Task | Manual Commands | Terraform |
|------|----------------|-----------|
| **Create** | `docker run ...` or `kubectl apply ...` | `terraform apply` |
| **Preview** | ❌ No preview | ✅ `terraform plan` |
| **Track** | ❌ Have to remember what you created | ✅ State file tracks everything |
| **Modify** | Re-run commands manually | Edit code, `terraform apply` |
| **Delete** | Find and delete each resource | `terraform destroy` (deletes all) |
| **Reproduce** | Copy/paste commands | Share `.tf` files |
| **Version Control** | ❌ Can't version commands | ✅ Commit `.tf` files to Git |

---

## Best Practices

### 1️⃣ Always Use Version Control
```bash
git add main.tf
git commit -m "Add Terraform config for API deployment"
```

### 2️⃣ Add to .gitignore
```
# .gitignore
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl
```

**Why?**
- `.terraform/` = large provider binaries (can be re-downloaded)
- `*.tfstate` = contains sensitive data, environment-specific
- `.terraform.lock.hcl` = can be committed (locks provider versions)

### 3️⃣ Use Variables for Reusability
```hcl
variable "replicas" {
  default = 2
}

resource "kubernetes_deployment" "app" {
  spec {
    replicas = var.replicas
  }
}
```

### 4️⃣ Always Run Plan Before Apply
```bash
terraform plan  # Review changes
terraform apply # Only if plan looks good
```

### 5️⃣ Use Workspaces for Environments
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

Each workspace has its own state file (separate infrastructure per environment).

---

## Common Issues & Troubleshooting

### ❌ "Error: Provider not found"
**Cause:** Didn't run `terraform init`

**Solution:**
```bash
terraform init
```

---

### ❌ "Error: No such file or directory"
**Cause:** Wrong directory or paths in code are incorrect

**Solution:** Check `context = "../../backend"` paths in `main.tf`

---

### ❌ "Error: failed to solve with frontend dockerfile.v0"
**Cause:** Docker build failed (syntax error in Dockerfile)

**Solution:** Test Docker build manually first:
```bash
docker build -t dotnet-api:latest ./backend
```

---

### ❌ "Error: Post 'http://localhost/v1.41/images/create': dial tcp 127.0.0.1:2375: connect: connection refused"
**Cause:** Docker isn't running or Terraform can't connect

**Solution:**
1. Start Rancher Desktop
2. Verify Docker is running: `docker ps`
3. Check provider config in `main.tf`

---

### ❌ "Error: the server could not find the requested resource"
**Cause:** Kubernetes provider can't connect to cluster

**Solution:**
1. Verify Kubernetes is running: `kubectl cluster-info`
2. Check config_context in provider block: `config_context = "rancher-desktop"`
3. Verify kubeconfig: `kubectl config current-context`

---

## Next Steps

🎉 **Congratulations!** You've learned Infrastructure as Code with Terraform!

**What You've Learned:**
- ✅ Terraform basics (providers, resources, state)
- ✅ Building Docker images with Terraform
- ✅ Creating Kubernetes resources with Terraform
- ✅ terraform init/plan/apply/destroy workflow

**Production Skills:**
- Store state remotely (S3, Terraform Cloud)
- Use modules for reusability
- Implement CI/CD with Terraform
- Manage multiple environments (dev/staging/prod)

**The DevOps Journey:**
```
Docker → Docker Compose → Kubernetes → Terraform → Production! 🚀
  ↓           ↓               ↓            ↓
Hour 1     Hour 2         Hour 3       Hour 5
```

---

## Resources

- 📚 Terraform Documentation: https://www.terraform.io/docs
- 🐳 Docker Provider: https://registry.terraform.io/providers/kreuzwerker/docker
- ☸️ Kubernetes Provider: https://registry.terraform.io/providers/hashicorp/kubernetes
- 🎓 Learn Terraform: https://learn.hashicorp.com/terraform

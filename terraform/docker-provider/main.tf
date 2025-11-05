# ============================================================================
# 🐳 TERRAFORM + DOCKER PROVIDER
# ============================================================================
# SIMPLE ANALOGY:
# Terraform is like a CONSTRUCTION MANAGER who reads blueprints and builds
# infrastructure. Instead of manually running docker commands, you write
# blueprints (this file) and Terraform builds everything for you.
#
# WHY TERRAFORM?
# - Infrastructure as Code (IaC) - Your infrastructure is documented in files
# - Reproducible - Anyone can run this and get the exact same setup
# - Version controlled - Track changes to your infrastructure over time
# - Idempotent - Run it 100 times, get the same result (safe to re-run)
# ============================================================================

# ============================================================================
# TERRAFORM BLOCK: Configuration for Terraform itself
# ============================================================================
# This tells Terraform:
# 1. Which version of Terraform to use
# 2. Which providers (plugins) we need
#
# ANALOGY: Like specifying which tools a construction crew needs
# "You'll need a crane (Docker provider) version 3.0 or higher"
# ============================================================================
terraform {
  # REQUIRED_VERSION: Which Terraform version can run this
  # ">= 1.0" means "version 1.0 or newer"
  #
  # WHY? Different Terraform versions have different features
  # Like saying "You need at least a 2020 model crane, not the 1990 version"
  required_version = ">= 1.0"

  # REQUIRED_PROVIDERS: Which plugins Terraform needs to download
  required_providers {
    # DOCKER PROVIDER: Allows Terraform to manage Docker resources
    docker = {
      # SOURCE: Where to download the provider from
      # Format: "registry.terraform.io/namespace/provider"
      # Like an app store URL
      source = "kreuzwerker/docker"
      
      # VERSION: Which version of the Docker provider to use
      # "~> 3.0" means "3.0.x" (any patch version of 3.0)
      # The ~> is called "pessimistic constraint operator"
      #   - ✅ Allows: 3.0.1, 3.0.2, 3.0.99
      #   - ❌ Blocks: 3.1.0, 4.0.0 (might have breaking changes)
      #
      # ANALOGY: "I want a 2024 Honda Civic, any trim level is fine,
      # but don't give me a 2025 model (might be too different)"
      version = "~> 3.0"
    }
  }
}

# ============================================================================
# PROVIDER BLOCK: Configure the Docker provider
# ============================================================================
# The provider is the "plugin" that knows how to talk to Docker
#
# ANALOGY: The construction manager (Terraform) needs a translator
# (provider) who speaks Docker's language
# ============================================================================
provider "docker" {
  # HOST: Where is Docker running?
  # This connects to Docker on your local machine
  #
  # Windows/Mac with Rancher Desktop: Uses a Unix socket in WSL
  # Format: "unix:///path/to/docker.sock"
  #
  # WHAT IS A SOCKET?
  # A socket is like a pipe for programs to talk to each other
  # Docker listens on this "phone line" for commands
  #
  # THE BACKSTORY:
  # Rancher Desktop runs Docker inside a WSL 2 Linux VM
  # The socket file is the "door" to communicate with that VM
  # On Linux: /var/run/docker.sock
  # On Windows WSL: /var/run/docker.sock (inside the Linux VM)
  #
  # ALTERNATIVE: If this doesn't work, comment it out
  # Terraform will try to auto-detect Docker's location
  # host = "unix:///var/run/docker.sock"
}

# ============================================================================
# DATA SOURCE: docker_registry_image
# ============================================================================
# WHAT IS A DATA SOURCE?
# A data source READS information from somewhere (doesn't create anything)
# Think of it like a "lookup" or "search"
#
# ANALOGY: Like looking up a part number in a catalog before ordering
# You're not buying yet, just finding the exact specifications
#
# WHY USE THIS?
# We want to ensure we're pulling the latest .NET 8 runtime image
# This data source checks Docker Hub and gets the current image digest
# (digest = unique fingerprint of an image version)
# ============================================================================
data "docker_registry_image" "dotnet_runtime" {
  # NAME: Which Docker image to look up
  # This is checking "mcr.microsoft.com/dotnet/aspnet" with tag "8.0"
  # MCR = Microsoft Container Registry
  name = "mcr.microsoft.com/dotnet/aspnet:8.0"
  
  # RESULT: This data source will have an attribute called "sha256_digest"
  # which is the unique hash of this specific image version
  #
  # ANALOGY: Like getting a VIN (Vehicle Identification Number) for a car
  # Even if two cars look the same, the VIN is unique
}

# ============================================================================
# RESOURCE: docker_image
# ============================================================================
# WHAT IS A RESOURCE?
# A resource is something Terraform CREATES and MANAGES
# This is the "noun" in your infrastructure
#
# RESOURCE SYNTAX:
# resource "TYPE" "NAME" {
#   configuration...
# }
#
# TYPE = what kind of thing (docker_image, docker_container, etc.)
# NAME = your nickname for this resource (used to reference it elsewhere)
#
# ANALOGY: Like filling out a form to order construction materials
# "I want a docker_image called 'dotnet_api'"
# ============================================================================
resource "docker_image" "dotnet_api" {
  # NAME: Tag for the Docker image we're building
  # This is what you'll see in "docker images"
  name = "dotnet-api:terraform"
  
  # BUILD BLOCK: Instructions to build the image from a Dockerfile
  # Like telling a chef: "Here's the recipe (Dockerfile), go cook it"
  build {
    # CONTEXT: The directory containing the Dockerfile and source code
    # "../../backend" means go up 2 directories, then into backend/
    # From: terraform/docker-provider/ → DevOpsyLab/flask-dynamo-demo/ → backend/
    #
    # WHY "CONTEXT"?
    # Docker needs to know which files are available during build
    # The context is the "working directory" for the build
    #
    # ANALOGY: Giving a chef access to a specific pantry
    # "Everything in the 'backend' folder is available for your recipe"
    context = "../../backend"
    
    # DOCKERFILE: Which Dockerfile to use
    # Default is "Dockerfile" in the context directory
    # Since our Dockerfile is at backend/Dockerfile, we specify it here
    dockerfile = "Dockerfile"
    
    # TAG: Additional tags to apply to the image
    # You can tag the same image with multiple names
    # Like giving a product multiple labels
    tag = ["dotnet-api:latest", "dotnet-api:terraform-built"]
    
    # BUILD_ARG: Pass build arguments to the Dockerfile
    # (if your Dockerfile uses ARG instructions)
    # build_arg = {
    #   BUILDKIT_INLINE_CACHE = "1"
    # }
    
    # NO_CACHE: Force rebuild without using cache?
    # false = use layer caching (faster, default)
    # true = rebuild everything from scratch (slower, but fresh)
    #
    # ANALOGY: false = reheating leftovers, true = cooking from scratch
    # no_cache = false
  }
  
  # KEEP_LOCALLY: Should Terraform delete this image when you run "terraform destroy"?
  # true = keep the image (don't delete)
  # false = delete the image when infrastructure is destroyed
  #
  # WHY true?
  # Docker images are often reused, and rebuilding takes time
  # You probably want to keep the image even if you destroy the container
  #
  # ANALOGY: When you demolish a building, do you throw away the blueprints?
  # No! You keep them for the next building.
  keep_locally = true
  
  # TRIGGERS: Force rebuild when these values change
  # This is an optional map that tells Terraform:
  # "If this value changes, rebuild the image"
  #
  # Here we use the base image digest from our data source
  # If Microsoft releases a new .NET 8 image, this digest changes,
  # and Terraform rebuilds our custom image
  #
  # ANALOGY: Like setting a reminder to repaint your house
  # when the original paint formula changes
  triggers = {
    base_image_digest = data.docker_registry_image.dotnet_runtime.sha256_digest
  }
}

# ============================================================================
# RESOURCE: docker_container
# ============================================================================
# This creates and runs a Docker container from our image
#
# ANALOGY: The docker_image is the recipe, the docker_container is
# the actual meal served to a customer
# ============================================================================
resource "docker_container" "dotnet_api" {
  # IMAGE: Which image to run
  # We reference the image we built above using: docker_image.dotnet_api.image_id
  #
  # TERRAFORM REFERENCES:
  # Format: RESOURCE_TYPE.RESOURCE_NAME.ATTRIBUTE
  # docker_image.dotnet_api.image_id = "The ID of the image we built"
  #
  # WHY image_id instead of name?
  # image_id is the unique hash, ensures we're using the exact image we built
  # name might match multiple images
  #
  # ANALOGY: Using a serial number instead of a product name
  # (more precise, avoids confusion)
  image = docker_image.dotnet_api.image_id
  
  # NAME: Name for the container
  # This is what you'll see in "docker ps"
  # Must be unique (can't have 2 containers with the same name)
  name = "dotnet-api-terraform"
  
  # MUST_RUN: Should the container always be running?
  # true = Terraform ensures the container is running
  # false = Terraform doesn't care if it's running or stopped
  #
  # WHY true?
  # We want our API to be accessible, so it needs to run
  must_run = true
  
  # PORTS BLOCK: Port mapping (host:container)
  # Exposes the container's port to your machine
  ports {
    # INTERNAL: Port inside the container
    # Our .NET API listens on port 5000 inside the container
    internal = 5000
    
    # EXTERNAL: Port on your machine (host)
    # Access the API at http://localhost:5001
    # (We use 5001 to avoid conflicts with other apps using 5000)
    external = 5001
    
    # PROTOCOL: tcp or udp
    # HTTP uses TCP (Transmission Control Protocol)
    protocol = "tcp"
  }
  
  # ENV: Environment variables passed to the container
  # Like giving the container a config file
  env = [
    # Tell the .NET API where to find DynamoDB
    # Format: "KEY=VALUE"
    "DYNAMODB_ENDPOINT=http://host.docker.internal:8000",
    
    # WHAT IS host.docker.internal?
    # A special DNS name that resolves to your host machine
    # Containers can use this to access services on your computer
    #
    # THE BACKSTORY:
    # Containers are isolated (they can't see your machine by default)
    # host.docker.internal is a "bridge" from container to host
    #
    # ANALOGY: Like giving a hotel room guest the front desk phone number
    # The guest (container) can call the front desk (host) using a special number
    
    "ASPNETCORE_URLS=http://+:5000"  # Tell .NET to listen on port 5000
  ]
  
  # RESTART: Restart policy
  # "unless-stopped" = always restart if it crashes, unless you manually stop it
  #
  # OPTIONS:
  # - "no" = never restart automatically
  # - "always" = always restart, even after manual stop
  # - "on-failure" = only restart if it crashes (exit code != 0)
  # - "unless-stopped" = restart unless manually stopped
  #
  # ANALOGY: Like a self-righting toy that pops back up when knocked over
  # (but stays down if you hold it down)
  restart = "unless-stopped"
  
  # HEALTHCHECK: Check if the container is healthy
  # (Optional, but good practice)
  # healthcheck {
  #   test     = ["CMD", "curl", "-f", "http://localhost:5000/api/todos"]
  #   interval = "30s"
  #   timeout  = "3s"
  #   retries  = 3
  # }
}

# ============================================================================
# OUTPUT: Export values after apply
# ============================================================================
# WHAT ARE OUTPUTS?
# Outputs display information after Terraform finishes
# Like a receipt after a purchase showing what you got
#
# ANALOGY: The construction manager hands you the keys and says
# "Here's your new building, and here's the address: 123 Main St"
# ============================================================================
output "container_name" {
  description = "Name of the running container"
  value       = docker_container.dotnet_api.name
}

output "api_url" {
  description = "URL to access the API"
  value       = "http://localhost:${docker_container.dotnet_api.ports[0].external}/api/todos"
}

output "image_id" {
  description = "Docker image ID"
  value       = docker_image.dotnet_api.image_id
}

# ============================================================================
# HOW TO USE THIS FILE
# ============================================================================
# 1. Navigate to this directory:
#    cd terraform/docker-provider
#
# 2. Initialize Terraform (downloads providers):
#    terraform init
#
# 3. See what Terraform will do (dry-run):
#    terraform plan
#
# 4. Create the infrastructure:
#    terraform apply
#
# 5. Check what was created:
#    terraform show
#
# 6. Destroy everything:
#    terraform destroy
#
# ============================================================================
# TERRAFORM STATE
# ============================================================================
# After you run "terraform apply", Terraform creates "terraform.tfstate"
# This file tracks what Terraform has created
#
# WHAT'S IN THE STATE FILE?
# - List of all resources Terraform manages
# - Current configuration of each resource
# - Metadata (IDs, timestamps, etc.)
#
# WHY IS IT IMPORTANT?
# Terraform uses state to know:
# - What exists vs what's in your .tf files
# - What needs to be created, updated, or deleted
# - How to map your code to real infrastructure
#
# ANALOGY: Like a construction project's logbook
# "We built a fence on June 1st, painted it blue, it's 10 feet tall"
# Next day: "The logbook says we have a fence, so I won't build another one"
#
# ⚠️ WARNING: Don't delete terraform.tfstate!
# If you delete it, Terraform forgets what it created
# You'll have "orphaned" resources (containers running but Terraform doesn't know)
#
# GITIGNORE: Always add terraform.tfstate to .gitignore
# It contains sensitive data and is environment-specific
# ============================================================================

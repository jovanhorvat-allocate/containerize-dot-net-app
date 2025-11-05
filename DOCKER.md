# Docker & Docker Compose

> **Restaurant Kitchen Analogy**: Docker is like having a fully-equipped portable kitchen that you can set up anywhere. Everything the chef needs is inside, and it works the same whether it's in New York or Tokyo.

---

## What is Docker?

**Docker** packages your application and everything it needs (code, runtime, libraries, dependencies) into a **container** - a lightweight, standalone, executable package.

### The Problem Docker Solves

**Without Docker (Traditional Way):**
```
😰 "It works on my machine!"
😰 "Do you have Node.js version 18.2.0 installed?"
😰 "Did you remember to install libssl-dev?"
😰 "Wait, you're on Windows? This only works on Linux..."
```

**With Docker:**
```
😎 "Just run: docker run my-app"
😎 Works everywhere: Windows, Mac, Linux, Cloud
😎 All dependencies included
😎 Consistent behavior guaranteed
```

### Restaurant Analogy

**Without Docker** = Hiring a chef and hoping they bring their own knives, pots, and ingredients
- Different chefs need different tools
- Your kitchen might not have what they need
- Recipe might not work in your kitchen

**With Docker** = Chef arrives with a complete portable kitchen
- Everything needed is inside
- Set it up anywhere
- Guaranteed to work the same way every time

---

## Docker vs Docker Compose

| Aspect | Docker | Docker Compose |
|--------|--------|----------------|
| **Purpose** | Run single containers | Run multiple containers together |
| **Command** | `docker run nginx` | `docker-compose up` |
| **Configuration** | Long CLI commands | YAML file (`docker-compose.yml`) |
| **Networking** | Manual setup | Automatic network creation |
| **Use Case** | Testing one service | Full application stack |
| **Analogy** | One food truck | Entire restaurant with kitchen staff |

### When to Use What?

**Use Docker** when:
- Testing a single container
- Running one-off commands
- Building images
- Learning Docker basics

**Use Docker Compose** when:
- Running multiple services (frontend + backend + database)
- Local development environment
- Services need to talk to each other
- You want easy start/stop for everything

---

## Prerequisites

- **WSL 2** (Windows Subsystem for Linux) - Required for Rancher on Windows
  - [Installation Guide](https://learn.microsoft.com/en-us/windows/wsl/install)
  - Quick install: Open PowerShell as Admin and run `wsl --install`
  
- **Rancher Desktop** installed and running
  - [Download for Windows](https://docs.rancherdesktop.io/getting-started/installation/#windows)
  - Provides Docker engine and Kubernetes cluster

---

## Quick Start with Docker Compose

### Start Everything

```bash
docker-compose up -d
```

**What this does:**
- `docker-compose` - Tool that orchestrates multiple containers
- `up` - Start everything (builds images if needed, then runs containers)
- `-d` - Detached mode (runs in background)

**Behind the scenes:**
1. Creates network `todo-net` (like installing an intercom system)
2. Starts DynamoDB container (the pantry)
3. Builds .NET API image (prep the chef's station)
4. Starts API container (chef starts cooking)
5. Starts Frontend container (waiter ready to serve)

**Access the app:**
- Frontend (what users see): http://localhost:8080
- Backend API (the kitchen): http://localhost:5000
- DynamoDB (the pantry): http://localhost:8000

---

### View Running Containers

```bash
docker-compose ps
```

**Expected output:**
```
NAME                  STATUS          PORTS
dynamodb              Up 2 minutes    0.0.0.0:8000->8000/tcp
dotnet-api            Up 1 minute     0.0.0.0:5000->5000/tcp
frontend              Up 1 minute     0.0.0.0:8080->80/tcp
```

**What this means:**
- All 3 containers are running (`Up`)
- Each container has a port exposed to your machine

---

### View Logs

```bash
# All services
docker-compose logs

# Just the API
docker-compose logs dotnet-api

# Follow logs in real-time
docker-compose logs -f dotnet-api
```

**What to look for:**
- ✅ `Now listening on: http://[::]:5000` - API is ready
- ✅ `Application started` - Frontend is ready
- ❌ Error messages or stack traces

---

### Stop Everything

```bash
docker-compose down
```

**What this does:**
- Stops all running containers
- Removes containers (but keeps images)
- Removes the network
- **Data is lost** (DynamoDB runs in memory mode)

**Analogy**: Closes the restaurant for the night. Tomorrow you can reopen with the same setup, but today's data is gone.

---

### Rebuild After Code Changes

```bash
# Rebuild images and restart
docker-compose up -d --build

# Or rebuild just one service
docker-compose build dotnet-api
docker-compose up -d dotnet-api
```

**When to rebuild:**
- Changed backend code (C#)
- Changed Dockerfile
- Added new dependencies

**When NOT needed:**
- Changed frontend code (uses volume mount, auto-updates)
- Changed environment variables (just restart: `docker-compose restart`)

---

## Understanding the Files

### 📄 docker-compose.yml

**What it is:** Configuration file that defines your entire application stack.

**Key concepts explained:**

```yaml
version: '3.8'  # Docker Compose file format version

services:  # Each service = one container
  
  dynamodb:  # Service name (used for DNS resolution)
    image: amazon/dynamodb-local:latest  # Pre-built image
    ports:
      - "8000:8000"  # Your machine:Container
    
  dotnet-api:
    build: ./backend  # Build from Dockerfile
    depends_on:  # Start AFTER dynamodb
      dynamodb:
        condition: service_started
    environment:  # Pass config to container
      DYNAMODB_ENDPOINT: http://dynamodb:8000
    ports:
      - "5000:5000"
      
networks:  # Containers can talk using service names
  todo-net:
    driver: bridge  # Like a virtual network switch
```

**📚 Full File:** The actual `docker-compose.yml` has extensive comments explaining every line!

---

### 📄 backend/Dockerfile

**What it is:** Instructions for building the .NET API container image.

**Multi-Stage Build Concept:**

```dockerfile
# STAGE 1: BUILD (uses SDK - 1.2GB)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
COPY . .
RUN dotnet publish

# STAGE 2: RUNTIME (uses runtime - 220MB)
FROM mcr.microsoft.com/dotnet/aspnet:8.0
COPY --from=build /app/publish .
CMD ["dotnet", "TodoApi.dll"]
```

**Why multi-stage?**
- Build stage has compilers, tools (SDK) - needed to build but not to run
- Runtime stage only has what's needed to run the app
- **Result:** Final image is 80% smaller!

**Analogy:**
- Build stage = Chef's prep kitchen (lots of tools, equipment)
- Runtime stage = Serving window (just the finished dish, no prep tools)

**📚 Full File:** The actual `backend/Dockerfile` has extensive comments explaining every line!

---

## Common Docker Commands

### Container Management

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop dotnet-api

# Start a stopped container
docker start dotnet-api

# Restart a container
docker restart dotnet-api

# Remove a container
docker rm dotnet-api

# View container logs
docker logs dotnet-api

# Follow logs in real-time
docker logs -f dotnet-api

# Execute command inside container
docker exec -it dotnet-api bash
```

---

### Image Management

```bash
# List images
docker images

# Build an image
docker build -t my-api:v1 ./backend

# Remove an image
docker rmi my-api:v1

# Remove unused images
docker image prune

# View image details
docker inspect dotnet-api:latest
```

---

### Network Management

```bash
# List networks
docker network ls

# Inspect a network
docker network inspect todo-net

# Create a network
docker network create my-network

# Connect container to network
docker network connect my-network my-container
```

---

### Clean Up

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune

# Nuclear option (remove EVERYTHING)
docker system prune -a --volumes
```

---

## How Containers Communicate

### Container-to-Container (Internal)

```
API Container → http://dynamodb:8000
```

**How it works:**
- Docker creates a DNS server for the network
- Service names become hostnames
- `dynamodb` resolves to the container's internal IP

**Analogy:** Like calling a coworker by their name instead of phone number. The company directory (DNS) looks up their extension.

---

### Your Machine → Container (External)

```
Your Browser → http://localhost:8080 → Frontend Container
```

**How it works:**
- Port mapping: `8080:80` means "forward port 8080 on my machine to port 80 in container"
- Docker acts as a traffic cop, routing requests

**Analogy:** Like a hotel room number. You go to room 8080 at the front desk, they redirect you to the actual room.

---

## What Happens Under the Hood

When you run `docker-compose up -d`:

```
1. 🔍 Read docker-compose.yml
   ↓
2. 🌐 Create network (todo-net)
   ↓
3. 📦 Pull images (DynamoDB)
   ↓
4. 🔨 Build images (API from Dockerfile)
   ↓
5. 🚀 Start containers in order:
   - DynamoDB first (no dependencies)
   - API second (depends on DynamoDB)
   - Frontend third (depends on API)
   ↓
6. ✅ Health checks pass
   ↓
7. 🎉 Everything running!
```

**Restaurant Analogy:**
1. Read operations manual
2. Install intercom system
3. Order supplies
4. Prep the kitchen
5. Open for business (pantry → kitchen → dining room)
6. Manager checks everyone is ready
7. Start serving customers!

---

## Troubleshooting

### Port Already in Use

**Error:**
```
Error: bind: address already in use
```

**Solution:**
```bash
# Find what's using the port
netstat -ano | findstr :8080

# Kill the process (replace PID with actual number)
taskkill /PID 12345 /F

# Or change port in docker-compose.yml
ports:
  - "8081:80"  # Use different external port
```

---

### Container Keeps Restarting

**Check logs:**
```bash
docker-compose logs dotnet-api
```

**Common causes:**
- Application crashed (check error messages)
- Health check failing (API not responding)
- Missing environment variables
- Can't connect to DynamoDB

---

### Changes Not Reflected

**Solution:**
```bash
# Rebuild the image
docker-compose up -d --build

# Or remove everything and start fresh
docker-compose down
docker-compose up -d --build
```

---

### Can't Connect to DynamoDB

**Check:**
1. Is DynamoDB running? `docker ps`
2. Is it on the same network? `docker network inspect todo-net`
3. Is the endpoint correct? Should be `http://dynamodb:8000` (not localhost!)

---

## Best Practices

### 1️⃣ Use .dockerignore

```
# .dockerignore
node_modules/
bin/
obj/
*.log
.git/
```

**Why?** Excludes unnecessary files from build context (faster builds).

---

### 2️⃣ Keep Images Small

- ✅ Use multi-stage builds
- ✅ Use specific base images (`aspnet:8.0` not `sdk:8.0` for runtime)
- ✅ Clean up in the same layer: `RUN apt-get update && apt-get install && rm -rf /var/lib/apt/lists/*`

---

### 3️⃣ Don't Run as Root

```dockerfile
# Create non-root user
RUN useradd -m appuser
USER appuser
```

**Why?** Security - if container is compromised, attacker has limited privileges.

---

### 4️⃣ Use Health Checks

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

**Why?** Docker knows when container is actually ready, not just "running."

---

### 5️⃣ Use Environment Variables for Config

```yaml
environment:
  - DATABASE_URL=${DATABASE_URL}
  - API_KEY=${API_KEY}
```

**Why?** Same image works in dev/staging/prod with different config.

---

## Next Steps

🎉 **You've mastered Docker and Docker Compose!**

**Ready for the next level?**

👉 **[Kubernetes](./KUBERNETES.md)** - Run containers across multiple machines with auto-scaling and self-healing

👉 **[Terraform](./TERRAFORM.md)** - Manage your infrastructure as code

---

## Resources

- 📚 [Docker Documentation](https://docs.docker.com/)
- 📚 [Docker Compose Documentation](https://docs.docker.com/compose/)
- 🎓 [Docker Getting Started Tutorial](https://docs.docker.com/get-started/)
- 🐳 [Docker Hub](https://hub.docker.com/) - Find pre-built images

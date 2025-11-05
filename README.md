# Containerized .NET Todo App - Learning Guide

**The Journey:** Docker → Kubernetes → Terraform (Learn containerization from basics to production)

---

## 🎯 Why This Order?

Think of opening a restaurant business:

### 1. Docker - Learn to Cook
**Start here:** Master the basics of containers
- Package your app with everything it needs
- Understand images, containers, and networking
- Like learning to cook one dish in a portable kitchen

📖 **[DOCKER.md](./DOCKER.md)** - Start here

---

### 2. Docker Compose - Coordinate Your Kitchen
**Next:** Run multiple services together
- Backend talks to database, frontend serves users
- All containers work together on your machine
- Like coordinating chef, prep cook, and waiter

📖 **[DOCKER.md](./DOCKER.md)** - Covers this too

---

### 3. Kubernetes - Build a Restaurant Chain
**Then:** Scale to production
- Run across multiple servers
- Auto-healing when containers crash
- Load balancing across replicas
- Zero-downtime deployments
- Like managing restaurants in multiple cities

📖 **[KUBERNETES.md](./KUBERNETES.md)** - Production deployment

---

### 4. Terraform - Create Blueprints
**Finally:** Infrastructure as Code
- Define everything in code files
- Reproducible setups (no more manual commands)
- Version control your infrastructure
- Like having architectural blueprints to build restaurants anywhere

📖 **[TERRAFORM.md](./TERRAFORM.md)** - Automate everything

---

## 🔄 How They Connect

```
Docker               Docker Compose        Kubernetes           Terraform
  ↓                       ↓                     ↓                   ↓
Package apps         Run multiple          Scale across        Define as code
as containers        containers            many machines       (reproducible)
                     together
  ↓                       ↓                     ↓                   ↓
🚚 Food truck     →  👨‍🍳 Kitchen staff  →  🏢 Restaurant    →  📐 Blueprints
                                              chain
```

**Each builds on the previous!** You can't manage a chain before you learn to cook.

---

## 📊 Quick Comparison

| Tool | Purpose | Scope | Analogy |
|------|---------|-------|---------|
| **Docker** | Package apps | Single container | Portable kitchen |
| **Docker Compose** | Run multiple services | Single machine | Kitchen staff coordination |
| **Kubernetes** | Production orchestration | Multiple machines | Restaurant chain |
| **Terraform** | Infrastructure as Code | Any infrastructure | Construction blueprints |

---

## 🚀 Quick Start Commands

### Docker Compose (Start Here)
```bash
docker-compose up -d
# Access: http://localhost:8080
```

### Kubernetes (Next Level)
```bash
docker build -t dotnet-api:latest ./backend
kubectl apply -f k8s/
# Access: http://localhost:30080
```

### Terraform (Final Boss)
```bash
cd terraform/kubernetes-provider
terraform init
terraform apply
```

---

## 📚 Your Learning Path

```
┌─────────────┐
│   Docker    │  ← Start: Learn containers (1-2 hours)
│ 🚚 Portable │    Read: DOCKER.md
│   Kitchen   │
└──────┬──────┘
       ↓
┌─────────────┐
│ Kubernetes  │  ← Next: Scale to production (2 hours)
│ 🏢 Multi-   │    Read: KUBERNETES.md
│    City     │
└──────┬──────┘
       ↓
┌─────────────┐
│  Terraform  │  ← Final: Infrastructure as Code (1 hour)
│ 📐 Blueprint│    Read: TERRAFORM.md
└─────────────┘
```

**Total time:** ~5 hours to complete the journey

---

**Ready to start?** → **[DOCKER.md](./DOCKER.md)**

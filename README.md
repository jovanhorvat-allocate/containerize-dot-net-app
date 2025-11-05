# Containerized .NET Todo App

## Prerequisites

- **WSL 2** (Windows Subsystem for Linux) - Required for Rancher on Windows
  - [Installation Guide](https://learn.microsoft.com/en-us/windows/wsl/install)
  - Quick install: Open PowerShell as Admin and run `wsl --install`
  
- **Rancher Desktop** installed and running
  - [Download for Windows](https://docs.rancherdesktop.io/getting-started/installation/#windows)

## TL;DR

```bash
docker-compose up -d
```

**Why this command?**
- `docker-compose` - Like a conductor for an orchestra (tells all containers what to do)
- `up` - Start everything! Builds what's needed, then runs it
- `-d` - Detached mode = runs in background (like minimizing a window, it keeps running but you can use your terminal)

**Access:**
- Frontend: http://localhost:8080
- Backend API: http://localhost:5000
- DynamoDB: http://localhost:8000

## What Happens Under the Hood

**Think of Docker like a restaurant kitchen:**

1. **Creates network** `todo-net` - Like installing an intercom system so the chef, sous chef, and waiter can talk to each other
2. **Starts DynamoDB** - The pantry opens (stores ingredients/data in memory, not on a shelf)
3. **Builds .NET API** - The chef preps the dish using fancy tools (SDK), then sends only the finished meal to the table (throws away the pots and pans!)
4. **Starts API** - The chef starts cooking, talks to the pantry, prepares the "todos" menu
5. **Waits for health check** - Manager asks chef: "Ready to serve?" Chef: "Yes, kitchen is hot!" ✓
6. **Starts Frontend** - The waiter (nginx) is ready to serve customers your website

**How they talk:** Kitchen staff use names over the intercom ("Hey DynamoDB, I need ingredients!"). Customers (your browser) come through the front door at `localhost`.

## Stop

```bash
docker-compose down
```

**Why this command?**
- Stops all running containers (closes the restaurant for the night)
- Removes containers but keeps the blueprints (throws away today's prepped food, but keeps the recipes for tomorrow)
- Removes the network (unplugs the intercom system)
- **Data is lost** because DynamoDB runs in memory mode (like writing orders on a whiteboard that gets erased every night)

## Important Docker Files

**📄 docker-compose.yml** - The restaurant's operations manual
- Defines all 3 services (DynamoDB, API, Frontend)
- Sets up networking between containers
- Configures ports, health checks, and startup order
- **Heavily commented** - read it to understand the full setup!


**📄 backend/Dockerfile** - The chef's recipe book
- Multi-stage build: Build with SDK (1.2GB), run with runtime (220MB)
- Copies your .NET code and compiles it
- Creates a secure, minimal container
- **Every line explained** - great for learning Docker!

---

## 🚀 Next Step: Kubernetes

Once you're comfortable with Docker Compose, level up to **Kubernetes**!

### Docker Compose vs Kubernetes

| Feature | Docker Compose | Kubernetes |
|---------|----------------|------------|
| **Scale** | Single machine | Multiple machines (cluster) |
| **Availability** | If container dies, you restart manually | Auto-restarts failed containers |
| **Load Balancing** | No built-in | Yes, distributes traffic automatically |
| **Production Ready** | ❌ Development only | ✅ Production grade |

### Restaurant Analogy

- **Docker Compose** = Running a **food truck** 🚚
  - One vehicle (your machine)
  - If the truck breaks down, everything stops
  - You manage everything yourself
  
- **Kubernetes** = Running a **restaurant chain** 🏢
  - Multiple locations (nodes)
  - If one location has issues, others keep serving
  - Corporate managers (controllers) handle staffing automatically
  - Self-healing: A chef doesn't show up? A replacement is called in instantly

### Why Kubernetes?

In the real world, production apps need:
- ✅ **High Availability** - If one server crashes, others take over (no downtime!)
- ✅ **Auto-Scaling** - Automatically add more containers when traffic increases
- ✅ **Self-Healing** - Crashed containers are automatically restarted
- ✅ **Load Balancing** - Spread traffic across multiple container replicas
- ✅ **Zero-Downtime Updates** - Update your app without taking it offline

### 📚 Ready to Deploy on Kubernetes?

Check out **[KUBERNETES.md](./KUBERNETES.md)** for:
- Complete glossary of Kubernetes terms (with analogies!)
- Step-by-step deployment guide
- How to test load balancing between replicas
- Troubleshooting common issues
- Understanding self-healing in action

**The Progression:**
```
Docker (Hour 1-2) → Docker Compose (Hour 2) → Kubernetes (Hour 3) → Production! 🎉
     ↓                    ↓                         ↓
  One container    Multiple containers on     Multiple containers on
  on your machine    your machine (local)     multiple machines (cluster)
```

👉 **[Start with Kubernetes →](./KUBERNETES.md)**


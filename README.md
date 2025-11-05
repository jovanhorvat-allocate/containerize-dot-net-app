# 🚀 Docker-Based Todo Application# Flask DynamoDB Demo 🚀



> **A complete guide to understanding Docker and Docker Compose through a real-world .NET + DynamoDB + Vue.js application**A production-ready full-stack application demonstrating CRUD operations with Flask, DynamoDB Local, and Vue.js, fully containerized using Docker.



## 📚 Table of Contents## 📋 TL;DR



- [What is Docker? (ELI5)](#what-is-docker-eli5)**What**: REST API + Database + Frontend, all in Docker containers  

- [What is Docker Compose?](#what-is-docker-compose)**Why**: Easy deployment, consistent environments, no "works on my machine"  

- [Application Architecture](#application-architecture)**How**: One command → `docker-compose up -d` → Everything runs  

- [Quick Start](#quick-start)**Access**: Frontend at http://localhost:8080, API at http://localhost:5000

- [Deep Dive: Understanding Each Component](#deep-dive-understanding-each-component)

- [Common Docker Commands](#common-docker-commands)---

- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture Overview

---

```

## What is Docker? (ELI5)┌─────────────────────────────────────────────────────────────┐

│                    Docker Network                            │

### The Problem Docker Solves│                  (flask-dynamo-net)                          │

│                                                              │

**"It works on my machine!" 😤**│  ┌──────────────┐      ┌──────────────┐      ┌──────────┐  │

│  │   Vue.js     │      │    Flask     │      │ DynamoDB │  │

You've probably heard this before. Your code runs perfectly on your laptop, but when a colleague tries to run it, or you deploy it to a server, it breaks. Why?│  │  Frontend    │─────▶│     API      │─────▶│  Local   │  │

│  │   (nginx)    │      │   (Python)   │      │  (Java)  │  │

- Different operating system (Windows vs Mac vs Linux)│  │   Port 8080  │      │   Port 5000  │      │ Port 8000│  │

- Different versions of .NET, Python, Node.js, etc.│  └──────────────┘      └──────────────┘      └──────────┘  │

- Missing dependencies│         │                      │                     │       │

- Different environment variables└─────────┼──────────────────────┼─────────────────────┼──────┘

- Different database versions          │                      │                     │

      Browser                   API                Database

### The Solution: Docker Containers      Requests               Endpoints              Storage

```

**Docker is like a shipping container for your code.**

**Request Flow:**

``````

Traditional Shipping (Before Containers):User clicks "Delete" 

┌─────────────────────────────────────────────────┐    → Vue.js sends DELETE request 

│ Ship with loose cargo                           │        → Flask validates & processes 

│  🍎🍊📦📚🎸  All items loaded separately         │            → DynamoDB removes item 

│  Different handling for each item               │                → Flask returns success 

│  Slow loading/unloading                         │                    → Vue.js updates UI

│  Items can get damaged or mixed up              │```

└─────────────────────────────────────────────────┘

---

Modern Shipping (With Containers):

┌─────────────────────────────────────────────────┐## 📁 Project Structure

│ Ship with standardized containers               │

│  ┌──────┐ ┌──────┐ ┌──────┐                    │```

│  │ 🍎🍊 │ │ 📦📚 │ │ 🎸🎹 │                    │flask-dynamo-demo/

│  └──────┘ └──────┘ └──────┘                    │├── app.py                 # Flask REST API (192 lines)

│  Same handling for all containers               ││                          # - Routes: /health, /items CRUD

│  Fast loading/unloading                         ││                          # - DynamoDB client initialization

│  Contents protected                             ││                          # - Auto table creation logic

└─────────────────────────────────────────────────┘│

├── frontend/              

Docker (Software Containers):│   └── index.html         # Vue.js SPA (608 lines)

┌─────────────────────────────────────────────────┐│                          # - CRUD operations UI

│ Your Computer                                    ││                          # - Real-time health monitoring

│  ┌──────────┐ ┌──────────┐ ┌──────────┐        ││                          # - Responsive card-based design

│  │ .NET App │ │ Database │ │ Frontend │        ││

│  │ + .NET 8 │ │ +DynamoDB│ │ + nginx  │        │├── requirements.txt       # Python dependencies

│  │ + deps   │ │ + Java   │ │ + files  │        ││                          # - Flask 2.3.3 (web framework)

│  └──────────┘ └──────────┘ └──────────┘        ││                          # - boto3 1.29.7 (AWS SDK)

│  Same environment everywhere                     ││                          # - flask-cors 4.0.0 (CORS handling)

│  Runs identically on any computer               ││

│  Isolated from other applications               │├── Dockerfile            # Flask container blueprint (63 lines)

└─────────────────────────────────────────────────┘│                         # - Base: python:3.11-slim

```│                         # - Installs: gcc, curl, pip packages

│                         # - Security: non-root user (appuser)

### Key Concepts│                         # - Health: curl /health endpoint

│

#### 1. **Docker Image** = Recipe/Blueprint├── docker-compose.yml    # Multi-container orchestration

│                         # - 3 services: dynamodb, flask, frontend

An image is a frozen snapshot containing:│                         # - Health checks & dependencies

- Operating system (usually a lightweight Linux)│                         # - Network isolation

- Your application code│

- All dependencies (libraries, frameworks)├── SHARING_GUIDE.md      # Distribution & deployment guide

- Configuration files└── README.md             # This file

```

**Analogy:** Like a recipe for making a cake. You can't eat the recipe, but you can use it to create cakes.

---

#### 2. **Docker Container** = Running Instance

## ✨ Features

A container is a running instance of an image.

- ✅ **Full CRUD REST API** - Create, Read, Update, Delete operations

**Analogy:** The actual cake you baked from the recipe. You can make multiple cakes (containers) from one recipe (image).- ✅ **Real-time Vue.js UI** - Interactive frontend with live updates

- ✅ **DynamoDB Local** - AWS-compatible NoSQL database for development

```- ✅ **Health Checks** - Automatic service monitoring & startup ordering

Docker Image (Recipe)          Docker Containers (Cakes)- ✅ **CORS Enabled** - Frontend-backend communication configured

┌──────────────┐              ┌──────────┐ ┌──────────┐- ✅ **Docker Compose** - One-command deployment of all services

│ dotnet-api   │  ─────────>  │Container1│ │Container2│- ✅ **Non-root Containers** - Security best practices implemented

│ image        │   docker run  │ Running  │ │ Running  │- ✅ **Auto Table Creation** - Database schema initialized on startup

│ (500MB)      │              └──────────┘ └──────────┘- ✅ **Graceful Dependencies** - Services start in correct order

└──────────────┘- ✅ **Volume Persistence** - Optional data persistence between restarts

```

---

#### 3. **Dockerfile** = How to Build an Image

## 🎯 Why Docker & Docker Compose?

A text file with instructions for building an image.

### **The Problem Without Docker:**

**Analogy:** Step-by-step recipe instructions.```

Developer A's Machine          Production Server

```dockerfile├─ Python 3.9                 ├─ Python 3.11

FROM mcr.microsoft.com/dotnet/aspnet:8.0  # Start with .NET runtime├─ Windows 11                 ├─ Ubuntu 22.04

COPY . /app                                # Copy your code├─ Port 5000 available        ├─ Port 5000 used by other app

ENTRYPOINT ["dotnet", "TodoApi.dll"]      # How to run it└─ Works! ✓                   └─ Crashes! ✗

``````

**Result:** "But it works on my machine!" 😤

---

### **The Solution With Docker:**

## What is Docker Compose?```

Any Machine

**Docker Compose is like a conductor for an orchestra.**└─ Docker Engine

   ├─ Container 1: Exact Python 3.11 environment

Imagine you're building a web application:   ├─ Container 2: Exact DynamoDB Local version

- You need a backend (API)   └─ Container 3: Exact nginx configuration

- You need a database   

- You need a frontendResult: Works everywhere! ✓✓✓

- They all need to talk to each other```



Without Docker Compose:### **TL;DR Docker Benefits:**

```bash1. **Consistency**: Same environment dev → staging → production

# You'd run these manually (tedious! 😩)2. **Isolation**: No dependency conflicts between projects

docker run -d --name db -p 8000:8000 amazon/dynamodb-local3. **Portability**: Ship containers, not installation instructions

docker run -d --name api -p 5000:5000 --link db my-api4. **Scalability**: Easy to replicate and scale services

docker run -d --name web -p 8080:80 --link api my-frontend5. **Reproducibility**: Dockerfile = executable documentation

```

---

With Docker Compose:

```bash## 🐳 Docker Deep Dive: Dockerfile Explained

# One command to rule them all! 🎉

docker-compose up**TL;DR**: A Dockerfile is a recipe that tells Docker how to build your application container.

```

### **Our Dockerfile Breakdown:**

### docker-compose.yml = The Orchestra Score

```dockerfile

This YAML file defines:# Line 1: FROM python:3.11-slim

- All the containers (services) you need# ─────────────────────────────────────────────────────────────

- How they connect to each other# FROM = Starting point (base image)

- What ports they expose# python:3.11-slim = Official Python image, minimal size (~50MB)

- Startup order and dependencies# Why slim? Production needs speed, not dev tools

#

```yaml# Analogy: Like getting a furnished apartment vs empty one

services:# - python:3.11 = Fully furnished (200MB, has compilers, tools)

  database:    # 🥁 Drums (foundation)# - python:3.11-slim = Minimalist (50MB, only Python runtime)

  backend:     # 🎸 Guitar (connects database to frontend)FROM python:3.11-slim

  frontend:    # 🎤 Vocals (user-facing)

```# Line 2: WORKDIR /app

# ─────────────────────────────────────────────────────────────

---# WORKDIR = cd (change directory) + mkdir (if not exists)

# Creates /app folder and makes it the current directory

## Application Architecture# All subsequent commands run from here

#

### High-Level Overview# Why /app? Convention. Could be /code, /src, anything

WORKDIR /app

Our application has 3 services (containers) working together:

# Lines 3-5: RUN apt-get update && ...

```# ─────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────────────┐# RUN = Execute shell commands DURING BUILD (not at runtime)

│                        YOUR COMPUTER (Host)                          │# apt-get update = Refresh package list

│                                                                       │# apt-get install -y = Install packages (gcc for compiling, curl for health checks)

│  👤 User's Browser                                                   │# && = Chain commands (all must succeed)

│    │                                                                  │# rm -rf /var/lib/apt/lists/* = Delete cache to reduce image size

│    │ 1. Visit http://localhost:8080                                 │#

│    ↓                                                                  │# Why one RUN? Each RUN = new Docker layer = bigger image

│  ┌─────────────────────────────────────────────────────────────┐   │# Bad:  RUN apt-get update

│  │                     Port Mappings                             │   │#       RUN apt-get install gcc

│  │  8080 ──→ Frontend    5000 ──→ API    8000 ──→ Database     │   │#       RUN apt-get install curl

│  └──────────────────────┬───────────────────────────────────────┘   │#       (3 layers, cache not cleared)

└─────────────────────────┼─────────────────────────────────────────-─┘#

                          │ Docker Network# Good: RUN apt-get update && apt-get install -y gcc curl && rm ...

┌─────────────────────────┼─────────────────────────────────────────-─┐#       (1 layer, cache cleared)

│                         ↓                                             │RUN apt-get update && apt-get install -y \

│  ┌──────────────────────────────────────────────────────────────┐   │    gcc \

│  │           Docker Network: todo-net (172.18.0.0/16)           │   │    curl \

│  │                                                                │   │    && rm -rf /var/lib/apt/lists/*

│  │   ┌─────────────┐       ┌──────────────┐      ┌───────────┐ │   │

│  │   │  Frontend   │       │   Backend    │      │ Database  │ │   │# Line 6: COPY requirements.txt .

│  │   │   (nginx)   │  2.   │  (dotnet-api)│  3.  │(DynamoDB) │ │   │# ─────────────────────────────────────────────────────────────

│  │   │             │ ────> │              │ ───> │           │ │   │# COPY = Copy files from HOST to CONTAINER

│  │   │ Serves Vue  │       │ .NET 8 API   │      │  NoSQL    │ │   │# requirements.txt = source (from your computer)

│  │   │    :80      │       │    :5000     │      │   :8000   │ │   │# . = destination (current dir, which is /app)

│  │   └─────────────┘       └──────────────┘      └───────────┘ │   │#

│  │        ↑                        │                     │       │   │# Why copy requirements FIRST before app.py?

│  │        │                        ↓                     ↓       │   │# DOCKER LAYER CACHING! If requirements.txt doesn't change,

│  │        │                   4. Create Todo        5. Store     │   │# Docker reuses the pip install layer (saves minutes on rebuild)

│  │        └──────────── 6. Return Response ──────────────────── │   │#

│  └──────────────────────────────────────────────────────────────┘   │# Build sequence:

│                        DOCKER ENGINE                                 │# 1. Change app.py → Docker rebuilds from COPY app.py onward

└──────────────────────────────────────────────────────────────────────┘# 2. Don't change requirements.txt → Docker reuses pip install ✓

```COPY requirements.txt .



### Request Flow (Adding a Todo)# Line 7: RUN pip install ...

# ─────────────────────────────────────────────────────────────

```# pip install = Install Python packages

User Action: Click "Add Todo" button# --no-cache-dir = Don't store pip cache (saves ~50MB)

   │# -r requirements.txt = Read from file

   ├─ 1. Browser sends POST to http://localhost:5000/todos#

   │     ↓# This is EXPENSIVE (takes 10-30 seconds)

   │     Host OS routes to port 5000# That's why we copy requirements.txt separately!

   │     ↓RUN pip install --no-cache-dir -r requirements.txt

   ├─ 2. Docker maps port 5000 → dotnet-api container

   │     ↓# Line 8: COPY app.py .

   │     dotnet-api receives request# ─────────────────────────────────────────────────────────────

   │     ↓# Now copy the actual application code

   ├─ 3. .NET code calls DynamoDB at http://dynamodb-local:8000# Done AFTER pip install so code changes don't invalidate cache

   │     ↓#

   │     Docker DNS resolves "dynamodb-local" → container IP# You change code often → fast rebuilds

   │     ↓# You change dependencies rarely → slow rebuilds (but cached!)

   ├─ 4. DynamoDB stores todo in memoryCOPY app.py .

   │     ↓

   │     Returns success response# Line 9: EXPOSE 5000

   │     ↓# ─────────────────────────────────────────────────────────────

   ├─ 5. dotnet-api returns JSON to browser# EXPOSE = Documentation only! Doesn't actually open ports

   │     ↓# Tells users "this container listens on port 5000"

   ├─ 6. Vue.js receives response, updates UI# Actual port mapping: done in docker-compose.yml or docker run -p

   │     ↓#

   └─ ✓ Todo appears in the list!# Think of it like a sign on a door: "Office Hours: 9-5"

```# The sign doesn't unlock the door, but tells you when to knock

EXPOSE 5000

### Container Communication

# Lines 10-11: Create non-root user

**Why can containers talk to each other?**# ─────────────────────────────────────────────────────────────

# useradd -m -u 1001 appuser = Create user with UID 1001

Docker creates a virtual network (`todo-net`) with its own DNS server:# chown -R appuser:appuser /app = Give ownership of /app to appuser

#

```# WHY? Security! If hacker breaks into container:

Container Name Resolution (Docker's Internal DNS)# - Running as root: Can do anything ✗

┌─────────────────────────────────────────────────┐# - Running as appuser: Limited damage ✓

│ Docker DNS Server                                │#

│                                                   │# Production best practice: NEVER run as root in containers

│  dynamodb-local  →  172.18.0.2:8000             │RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app

│  dotnet-api      →  172.18.0.3:5000             │

│  vue-frontend    →  172.18.0.4:80               │# Line 12: USER appuser

└─────────────────────────────────────────────────┘# ─────────────────────────────────────────────────────────────

# Switch from root to appuser

When dotnet-api makes a request to:# All subsequent commands (including CMD) run as this user

  http://dynamodb-local:8000USER appuser



Docker DNS translates it to:# Line 13: CMD ["python", "app.py"]

  http://172.18.0.2:8000# ─────────────────────────────────────────────────────────────

```# CMD = Command to run when container STARTS (not during build!)

# ["python", "app.py"] = exec form (preferred over shell form)

**Key Point:** Container names work ONLY inside the Docker network. From your browser (outside Docker), you use `localhost`.#

# RUN vs CMD:

---# - RUN = Build time (install packages, copy files)

# - CMD = Runtime (start your application)

## Quick Start#

# Only ONE CMD per Dockerfile (last one wins)

### PrerequisitesCMD ["python", "app.py"]

```

- Docker Desktop installed (includes Docker + Docker Compose)

  - [Download for Windows](https://docs.docker.com/desktop/install/windows-install/)### **Docker Build Process Visualization:**

  - [Download for Mac](https://docs.docker.com/desktop/install/mac-install/)

  - [Download for Linux](https://docs.docker.com/desktop/install/linux-install/)```

docker build -t flask-app .

### Start the Application        │

        ├─ Step 1/7: FROM python:3.11-slim

```bash        │   └─ ✓ Pull base image (if not cached)

# Clone or navigate to the project directory        │

cd flask-dynamo-demo        ├─ Step 2/7: WORKDIR /app

        │   └─ ✓ Create directory

# Start all services (builds images if needed)        │

docker-compose up        ├─ Step 3/7: RUN apt-get install...

        │   └─ ✓ Install system packages

# OR run in background (detached mode)        │

docker-compose up -d        ├─ Step 4/7: COPY requirements.txt

```        │   └─ ✓ Copy dependency file

        │

**What happens?**        ├─ Step 5/7: RUN pip install

1. Downloads base images (nginx:alpine, dotnet/aspnet:8.0, amazon/dynamodb-local)        │   └─ ✓ Install Python packages (CACHED if no change)

2. Builds the .NET API image from `backend/Dockerfile`        │

3. Creates 3 containers        ├─ Step 6/7: COPY app.py

4. Starts them in order: DynamoDB → API (waits for DynamoDB) → Frontend (waits for API healthy)        │   └─ ✓ Copy application code

5. Sets up the `todo-net` network        │

6. Maps ports to your host machine        └─ Step 7/7: USER appuser

            └─ ✓ Set runtime user

### Access the Application            

Result: Image "flask-app" created (~250MB)

| Service  | URL                     | Description                      |```

|----------|-------------------------|----------------------------------|

| Frontend | http://localhost:8080   | Vue.js web interface             |---

| API      | http://localhost:5000   | .NET API endpoints               |

| API Docs | http://localhost:5000/health | Health check endpoint      |## 🎼 Docker Compose Deep Dive: Multi-Container Orchestration

| DynamoDB | http://localhost:8000   | DynamoDB Local (for admin tools) |

**TL;DR**: Docker Compose coordinates multiple containers so they work together as one application.

### Stop the Application

### **docker-compose.yml Breakdown:**

```bash

# Stop and remove containers (data lost since we use -inMemory)```yaml

docker-compose down# ═══════════════════════════════════════════════════════════════

# SERVICE 1: DynamoDB Local

# Stop containers but keep them (can restart quickly)# ═══════════════════════════════════════════════════════════════

docker-compose stopservices:

  dynamodb-local:

# Start stopped containers    # ─────────────────────────────────────────────────────────

docker-compose start    # image: Pre-built image from Docker Hub (no build needed)

```    # amazon/dynamodb-local = Official AWS image

    # :latest = Always get newest version

---    # ─────────────────────────────────────────────────────────

    image: amazon/dynamodb-local:latest

## Deep Dive: Understanding Each Component    

    # ─────────────────────────────────────────────────────────

### 1. DynamoDB Local Container    # container_name: Custom name (default: folder_service_1)

    # Useful for docker logs dynamodb-local, docker exec, etc.

**What is it?**    # ─────────────────────────────────────────────────────────

- Amazon's NoSQL database running locally    container_name: dynamodb-local

- No AWS account needed!    

- Perfect for development/testing    # ─────────────────────────────────────────────────────────

    # ports: Map HOST:CONTAINER

**Key Configuration:**    # "8000:8000" = localhost:8000 → container:8000

    # ─────────────────────────────────────────────────────────

```yaml    # Analogy: Like port forwarding on your router

dynamodb-local:    # External port 8000 → Internal container port 8000

  image: amazon/dynamodb-local:latest    # ─────────────────────────────────────────────────────────

  command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-inMemory"]    ports:

```      - "8000:8000"

    

**Flags Explained:**    # ─────────────────────────────────────────────────────────

- `-sharedDb`: All tables share one database file (simpler)    # command: Override default container command

- `-inMemory`: Store data in RAM instead of disk    # -jar DynamoDBLocal.jar = Run the Java application

  - **Pro:** Fast, no file permission issues    # -sharedDb = Use single database file (not per-credential)

  - **Con:** Data lost when container stops    # -inMemory = Don't persist to disk (fast, but data lost on restart)

    # ─────────────────────────────────────────────────────────

**Container Lifecycle:**    # Why -inMemory? Development speed > data persistence

    # Production would remove -inMemory for persistence

```    # ─────────────────────────────────────────────────────────

docker-compose up    command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-inMemory"]

   ↓    

┌─────────────────────────────────────┐    # ─────────────────────────────────────────────────────────

│ 1. Pull amazon/dynamodb-local image │ (if not cached)    # networks: Virtual network this container joins

│ 2. Create container                  │    # Containers on same network can talk to each other

│ 3. Start Java process                │    # ─────────────────────────────────────────────────────────

│ 4. Initialize in-memory database     │    networks:

│ 5. Listen on port 8000               │      - flask-dynamo-net

└─────────────────────────────────────┘

   ↓# ═══════════════════════════════════════════════════════════════

Container Running ✓# SERVICE 2: Flask Application

   ↓# ═══════════════════════════════════════════════════════════════

dotnet-api connects and creates "todos" table  flask-app:

   ↓    # ─────────────────────────────────────────────────────────

Ready to store data! 🎉    # build: Build from Dockerfile instead of using pre-built image

```    # . = Current directory (looks for ./Dockerfile)

    # ─────────────────────────────────────────────────────────

### 2. .NET API Container    # When you run docker-compose up --build:

    # 1. Reads Dockerfile

**What is it?**    # 2. Builds image

- Custom-built container from our Dockerfile    # 3. Tags as flask-dynamo-demo-flask-app

- Runs a C# .NET 8 Web API    # 4. Starts container from that image

- Handles CRUD operations for todos    # ─────────────────────────────────────────────────────────

    build: .

**Build Process (Multi-Stage Build):**    

    container_name: flask-app

```    

┌──────────────────────────────────────────────────────────────┐    # ─────────────────────────────────────────────────────────

│ STAGE 1: Build (Heavy - ~1.2GB)                              │    # ports: "5000:5000" = Access Flask at localhost:5000

│                                                                │    # ─────────────────────────────────────────────────────────

│  FROM mcr.microsoft.com/dotnet/sdk:8.0                        │    ports:

│    ↓                                                           │      - "5000:5000"

│  COPY TodoApi.csproj                                          │    

│  RUN dotnet restore  ← Downloads NuGet packages              │    # ─────────────────────────────────────────────────────────

│    ↓                                                           │    # environment: Environment variables inside container

│  COPY Program.cs                                              │    # Like setting $env:VAR = "value" in PowerShell

│  RUN dotnet publish  ← Compiles to DLL files                 │    # ─────────────────────────────────────────────────────────

│    ↓                                                           │    # DYNAMODB_ENDPOINT uses service name "dynamodb-local"

│  Output: /app/publish/TodoApi.dll + dependencies              │    # Docker's DNS resolves "dynamodb-local" → container IP

└──────────────────────────────────────────────────────────────┘    # ─────────────────────────────────────────────────────────

                         ↓    environment:

┌──────────────────────────────────────────────────────────────┐      - DYNAMODB_ENDPOINT=http://dynamodb-local:8000

│ STAGE 2: Runtime (Light - ~220MB)                            │      - FLASK_ENV=development

│                                                                │    

│  FROM mcr.microsoft.com/dotnet/aspnet:8.0                     │    # ─────────────────────────────────────────────────────────

│    ↓                                                           │    # depends_on: Start order dependency

│  COPY --from=build /app/publish .  ← Copy ONLY compiled files│    # Flask won't start until dynamodb-local starts

│    ↓                                                           │    # ─────────────────────────────────────────────────────────

│  Create non-root user (appuser)                               │    # NOTE: "starts" ≠ "ready"

│    ↓                                                           │    # dynamodb-local might start but not be ready for connections

│  ENTRYPOINT ["dotnet", "TodoApi.dll"]                         │    # That's why we need healthcheck!

└──────────────────────────────────────────────────────────────┘    # ─────────────────────────────────────────────────────────

                         ↓    depends_on:

                  Final Image: ~220MB      - dynamodb-local

         (Stage 1 discarded! Saved ~980MB!)    

```    networks:

      - flask-dynamo-net

**Why Multi-Stage?**    

    # ─────────────────────────────────────────────────────────

```    # restart: Restart policy if container crashes

Without Multi-Stage (Bad):    # unless-stopped = Always restart, except manual stop

┌────────────────────────┐    # ─────────────────────────────────────────────────────────

│ Final Image            │    # Other options:

│ • SDK (~1.2GB)         │ ← Don't need this!    # - no: Never restart (default)

│ • Build tools          │ ← Don't need this!    # - always: Always restart (even after reboot)

│ • Compiled app         │ ✓ Need this    # - on-failure: Only restart on error exit code

│ Total: ~1.3GB          │    # ─────────────────────────────────────────────────────────

└────────────────────────┘    restart: unless-stopped

    

With Multi-Stage (Good):    # ─────────────────────────────────────────────────────────

┌────────────────────────┐    # healthcheck: How to verify container is actually working

│ Final Image            │    # ─────────────────────────────────────────────────────────

│ • Runtime (~200MB)     │ ✓ Need this    healthcheck:

│ • Compiled app         │ ✓ Need this      # test: Command to run (exit 0 = healthy, non-zero = unhealthy)

│ Total: ~220MB          │      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]

└────────────────────────┘      

      # interval: How often to check (every 10 seconds)

Result: 83% smaller! 🎉      interval: 10s

```      

      # timeout: How long to wait for response (5 seconds max)

**Health Check Mechanism:**      timeout: 5s

      

```      # retries: How many failures before marking unhealthy (5 tries)

Docker Compose starts dotnet-api      retries: 5

   ↓      

Wait 10 seconds (start_period)      # start_period: Grace period before health checks count (10 seconds)

   ↓      # Gives container time to start before failing health checks

Every 10 seconds (interval):      start_period: 10s

   ┌──────────────────────────────────┐    

   │ Docker runs: curl http://localhost:5000/health │    # ─────────────────────────────────────────────────────────

   │    ↓                              │    # Health Check Timeline:

   │  HTTP 200 OK?                     │    # t=0s:  Container starts

   │    ├─ Yes → Mark as HEALTHY ✓    │    # t=10s: First health check (in grace period, failure ignored)

   │    └─ No  → Retry (max 5 times)  │    # t=20s: Second health check (now counts toward retries)

   └──────────────────────────────────┘    # t=30s: Third health check...

   ↓    # After 5 failures: Container marked unhealthy

Container marked HEALTHY    # ─────────────────────────────────────────────────────────

   ↓

Frontend can now start (depends_on: service_healthy)# ═══════════════════════════════════════════════════════════════

```# SERVICE 3: Vue.js Frontend (nginx)

# ═══════════════════════════════════════════════════════════════

### 3. Frontend Container  frontend:

    # ─────────────────────────────────────────────────────────

**What is it?**    # nginx:alpine = Lightweight web server (5MB!)

- nginx web server serving static files    # alpine = Minimal Linux distribution

- Vue.js single-page application    # ─────────────────────────────────────────────────────────

- Connects to API from the browser    # Why nginx? It's designed to serve static files FAST

    # - Handles 10,000+ concurrent connections

**Volume Mount (Live Reload):**    # - Uses ~2MB RAM per worker

    # - Battle-tested in production

```    # ─────────────────────────────────────────────────────────

Host Machine                     Docker Container    image: nginx:alpine

┌─────────────────────┐         ┌─────────────────────┐    

│ ./frontend/         │  Mount  │ /usr/share/nginx/   │    container_name: vue-frontend

│                     │ ─────→  │ html/               │    

│ ├── index.html ─────┼─────────┼─→ index.html        │    # ─────────────────────────────────────────────────────────

│ └── styles.css ─────┼─────────┼─→ styles.css        │    # ports: "8080:80" = localhost:8080 → container:80

└─────────────────────┘         └─────────────────────┘    # nginx listens on port 80 inside container

         ↑                              ↓    # We map it to 8080 on host (5000 taken by Flask)

         │                        nginx serves    # ─────────────────────────────────────────────────────────

    You edit here                 these files    ports:

         │                              ↓      - "8080:80"

    Save file                     Changes appear    

         │                        in browser    # ─────────────────────────────────────────────────────────

         └────────── Instant! ───────────┘    # volumes: Mount host directory into container

    # ./frontend:/usr/share/nginx/html:ro

No rebuild needed! 🚀    # ─────────────────────────────────────────────────────────

```    # Breakdown:

    # - ./frontend = Source (your computer's frontend folder)

**Important:** Frontend JavaScript runs in YOUR browser, not in the container. That's why API calls use `http://localhost:5000` (host port), not `http://dotnet-api:5000` (container name).    # - /usr/share/nginx/html = Destination (nginx's web root)

    # - :ro = Read-only (container can't modify your files)

---    # ─────────────────────────────────────────────────────────

    # Benefits:

## Common Docker Commands    # 1. Edit index.html on host → Changes immediately in container

    # 2. No rebuild needed for frontend changes

### Essential Commands    # 3. Container can't accidentally corrupt your source files

    # ─────────────────────────────────────────────────────────

```bash    volumes:

# ============================================================================      - ./frontend:/usr/share/nginx/html:ro

# Docker Compose Commands (Multi-Container Applications)    

# ============================================================================    # ─────────────────────────────────────────────────────────

    # depends_on with condition: Advanced dependency

# Start all services    # ─────────────────────────────────────────────────────────

docker-compose up    # service_healthy = Wait until Flask PASSES health check

  # -d          Run in background (detached)    # Not just "started", but actually responding to requests!

  # --build     Force rebuild images before starting    # ─────────────────────────────────────────────────────────

  # --force-recreate  Recreate containers even if config hasn't changed    # Startup sequence:

    # 1. dynamodb-local starts

# Stop all services    # 2. flask-app starts, depends on dynamodb-local

docker-compose down    # 3. flask-app health check runs every 10s

  # -v          Remove volumes too (delete data)    # 4. Once flask-app is HEALTHY, frontend starts

    # 5. If flask-app never becomes healthy, frontend never starts

# View logs    # ─────────────────────────────────────────────────────────

docker-compose logs    depends_on:

  # -f                  Follow log output (live)      flask-app:

  # dotnet-api          Show logs for specific service        condition: service_healthy

  # --tail 50           Show only last 50 lines    

    networks:

# Check status      - flask-dynamo-net

docker-compose ps        # List containers with status    

docker-compose top       # Show running processes in containers    restart: unless-stopped



# Restart services# ═══════════════════════════════════════════════════════════════

docker-compose restart              # Restart all# NETWORK DEFINITION

docker-compose restart dotnet-api   # Restart one service# ═══════════════════════════════════════════════════════════════

networks:

# Execute commands in running container  flask-dynamo-net:

docker-compose exec dotnet-api sh   # Open shell in container    # ─────────────────────────────────────────────────────────

docker-compose exec dotnet-api curl http://localhost:5000/health    # driver: bridge = Default Docker network type

    # ─────────────────────────────────────────────────────────

# ============================================================================    # Bridge network creates isolated network for containers

# Docker Commands (Individual Containers)    # Containers can talk to each other using service names

# ============================================================================    # Host can access via published ports

    # ─────────────────────────────────────────────────────────

# List containers    # Network isolation visualization:

docker ps              # Running containers    # 

docker ps -a           # All containers (including stopped)    # Host Machine (Your Computer)

    #   │

# List images    #   ├─ localhost:8080 ──▶ frontend:80

docker images          # All images on your system    #   ├─ localhost:5000 ──▶ flask-app:5000

    #   └─ localhost:8000 ──▶ dynamodb-local:8000

# Remove containers    #

docker rm container_name        # Remove stopped container    # Inside Docker Network (flask-dynamo-net):

docker rm -f container_name     # Force remove running container    #   frontend ─▶ http://flask-app:5000

    #   flask-app ─▶ http://dynamodb-local:8000

# Remove images    # ─────────────────────────────────────────────────────────

docker rmi image_name           # Remove image    driver: bridge

```

# View logs

docker logs dotnet-api          # View container logs### **Docker Compose Commands Explained:**

docker logs -f dotnet-api       # Follow logs (live)

```bash

# Execute command in container# ─────────────────────────────────────────────────────────────

docker exec -it dotnet-api sh   # Interactive shell# docker-compose up

# ─────────────────────────────────────────────────────────────

# Inspect container details# What it does:

docker inspect dotnet-api       # Full JSON configuration# 1. Creates network (flask-dynamo-net)

# 2. Pulls/builds images (if not cached)

# View resource usage# 3. Creates containers from images

docker stats                    # CPU, memory, network usage# 4. Starts containers in dependency order

# 5. Attaches to logs (shows output)

# ============================================================================#

# Cleanup Commands (Free Up Space!)# Flags:

# ============================================================================# -d = Detached (run in background)

# --build = Force rebuild images

# Remove stopped containers# --force-recreate = Recreate containers even if config unchanged

docker container prune# ─────────────────────────────────────────────────────────────

docker-compose up -d --build

# Remove unused images

docker image prune# ─────────────────────────────────────────────────────────────

docker image prune -a    # Remove ALL unused images (aggressive)# docker-compose ps

# ─────────────────────────────────────────────────────────────

# Remove unused volumes# Shows status of all services

docker volume prune# Columns: NAME, STATUS, PORTS, HEALTH

docker-compose ps

# Remove unused networks

docker network prune# ─────────────────────────────────────────────────────────────

# docker-compose logs

# Nuclear option (clean everything!)# ─────────────────────────────────────────────────────────────

docker system prune      # Remove all unused containers, networks, images# View logs from all services

docker system prune -a --volumes  # Remove EVERYTHING unused (careful!)# Flags:

# -f = Follow (like tail -f)

# ============================================================================# --tail 50 = Show last 50 lines

# Development Workflow# flask-app = Show only flask-app logs

# ============================================================================# ─────────────────────────────────────────────────────────────

docker-compose logs -f --tail 50 flask-app

# Full rebuild after code changes

docker-compose down              # Stop everything# ─────────────────────────────────────────────────────────────

docker-compose build --no-cache  # Rebuild from scratch# docker-compose down

docker-compose up -d             # Start in background# ─────────────────────────────────────────────────────────────

# What it does:

# Quick restart after backend changes# 1. Stops all containers

docker-compose restart dotnet-api# 2. Removes containers

# 3. Removes networks

# Frontend changes (HTML/CSS/JS)# 4. Does NOT remove images or volumes (unless -v flag)

# → Just refresh browser! Volume mount auto-updates 🎉#

```# Flags:

# -v = Also remove volumes (deletes data!)

### Debugging Commands# --rmi all = Also remove images

# ─────────────────────────────────────────────────────────────

```bashdocker-compose down

# Check if containers are healthy

docker-compose ps# ─────────────────────────────────────────────────────────────

# Look for "Up (healthy)" status# docker-compose restart

# ─────────────────────────────────────────────────────────────

# View real-time logs from all services# Restart specific service without rebuilding

docker-compose logs -fdocker-compose restart flask-app

```

# Check specific service logs

docker-compose logs dotnet-api --tail 100### **Container Lifecycle Visualization:**



# Enter a running container```

docker-compose exec dotnet-api shdocker-compose up --build

# Now you're inside! Try:        │

#   curl http://localhost:5000/health        ├─ 1. BUILD PHASE

#   ls -la        │   ├─ Read Dockerfile

#   printenv        │   ├─ Execute each instruction

        │   └─ Create image (tagged)

# Check network connectivity        │

docker network inspect flask-dynamo-demo_todo-net        ├─ 2. CREATE PHASE

# Shows all containers and their IPs        │   ├─ Create network: flask-dynamo-net

        │   ├─ Pull image: amazon/dynamodb-local:latest

# Test API from command line        │   ├─ Pull image: nginx:alpine

curl http://localhost:5000/health        │   └─ Create containers (not started yet)

curl http://localhost:5000/todos        │

        ├─ 3. START PHASE (respecting depends_on)

# Check port mappings        │   ├─ Start: dynamodb-local

docker port dotnet-api        │   │   └─ Status: Running

```        │   │

        │   ├─ Start: flask-app

---        │   │   ├─ Status: Running

        │   │   ├─ Health: Starting... (10s grace period)

## Troubleshooting        │   │   ├─ Health: Checking... (curl /health every 10s)

        │   │   └─ Health: Healthy ✓ (after successful check)

### Problem: "Port already in use"        │   │

        │   └─ Start: frontend (waits for flask-app healthy)

**Error:**        │       └─ Status: Running

```        │

Error starting userland proxy: listen tcp4 0.0.0.0:5000: bind: address already in use        └─ 4. RUNNING PHASE

```            ├─ All services operational

            ├─ Health checks continue in background

**Cause:** Another application is using port 5000, 8000, or 8080.            └─ Logs streaming to console (if not -d)



**Solution:**docker-compose down

        │

```bash        ├─ Send SIGTERM to all containers (graceful shutdown)

# Find what's using the port (Windows)        ├─ Wait 10 seconds for cleanup

netstat -ano | findstr :5000        ├─ Send SIGKILL if still running (force stop)

        ├─ Remove containers

# Find what's using the port (Mac/Linux)        ├─ Remove networks

lsof -i :5000        └─ Done (images remain for next startup)

```

# Kill the process or change ports in docker-compose.yml:---

ports:

  - "5001:5000"  # Use host port 5001 instead## 🔌 API Endpoints

```

| Method | Endpoint         | Description              |

---|--------|------------------|--------------------------|

| GET    | `/health`        | Health check             |

### Problem: Container exits immediately| GET    | `/items`         | Get all items            |

| GET    | `/items/{id}`    | Get item by ID           |

**Error:**| POST   | `/items`         | Create new item          |

```| PUT    | `/items/{id}`    | Update existing item     |

dotnet-api exited with code 137| DELETE | `/items/{id}`    | Delete item by ID        |

```

---

**Cause:** Not enough memory allocated to Docker.| GET    | `/health`        | Health check             |

| GET    | `/items`         | Get all items            |

**Solution:**| GET    | `/items/{id}`    | Get item by ID           |

| POST   | `/items`         | Create new item          |

1. Open Docker Desktop → Settings → Resources| PUT    | `/items/{id}`    | Update existing item     |

2. Increase Memory to at least 4GB| DELETE | `/items/{id}`    | Delete item by ID        |

3. Click "Apply & Restart"

---

---

## 🚀 Quick Start

### Problem: "Cannot connect to Docker daemon"

### Prerequisites

**Error:**- **Docker Desktop** ([Download](https://www.docker.com/products/docker-desktop))

```  - Windows: WSL2 backend required

Cannot connect to the Docker daemon at unix:///var/run/docker.sock  - Mac: Native support

```  - Linux: Docker Engine + Docker Compose



**Cause:** Docker Desktop isn't running.### One-Command Deployment



**Solution:**```powershell

# Clone or extract project

1. Start Docker Desktop applicationcd flask-dynamo-demo

2. Wait for "Docker is running" status

3. Try command again# Start everything (builds images, creates containers, starts services)

docker-compose up -d --build

---

# Wait ~15 seconds for health checks, then access:

### Problem: Health check failing# 🌐 Frontend: http://localhost:8080

# 🔧 API:      http://localhost:5000

**Error:**# 💾 DynamoDB: http://localhost:8000

``````

dotnet-api is unhealthy

```### Startup Timeline

```

**Check logs:**t=0s:   docker-compose up -d --build

t=1s:   Building Flask image... (60s)

```basht=61s:  Pulling nginx:alpine... (5s)

docker-compose logs dotnet-apit=66s:  Creating network...

t=67s:  Starting dynamodb-local...

# Common causes:t=68s:  Starting flask-app...

# 1. Application crashed → Check for C# exceptionst=78s:  Flask health check #1... (grace period)

# 2. Wrong port → Verify ASPNETCORE_URLSt=83s:  Flask health check #2... ✓ HEALTHY

# 3. DynamoDB not accessible → Check network/depends_ont=84s:  Starting frontend...

```t=85s:  ✅ All services running!

```

---

### Verification Commands

### Problem: Frontend shows "Cannot connect to API"

```powershell

**Cause:** API not ready or CORS issue.# Check all services are running

docker-compose ps

**Solution:**

# Expected output:

```bash# NAME            STATUS                  PORTS

# 1. Check API is healthy# dynamodb-local  Up 2 minutes            0.0.0.0:8000->8000/tcp

docker-compose ps# flask-app       Up 2 minutes (healthy)  0.0.0.0:5000->5000/tcp

# Should show "Up (healthy)"# vue-frontend    Up 2 minutes            0.0.0.0:8080->80/tcp



# 2. Test API directly# View logs

curl http://localhost:5000/healthdocker-compose logs -f



# 3. Check browser console (F12) for CORS errors# Test API health

# If CORS error, verify API has CORS enabled in Program.cscurl http://localhost:5000/health

# {"status": "healthy", "message": "Flask DynamoDB demo app is running"}

# 4. Check API is accessible from browser

# Open: http://localhost:5000/health# Create test item

```curl -X POST http://localhost:5000/items -H "Content-Type: application/json" -d '{"id":"test1","name":"Test Item","price":99}'

```

---

---

### Problem: Changes not appearing

## Services

**Frontend changes:**

- Refresh browser (Ctrl+F5 / Cmd+Shift+R)### Flask App

- Clear browser cache- **Port**: 5000

- Check volume mount: `docker-compose ps` → verify volume path- **Container**: flask-app

- **Health**: http://localhost:5000/health

**Backend changes:**

```bash### DynamoDB Local

# Must rebuild image- **Port**: 8000

docker-compose up --build- **Container**: dynamodb-local

```- **Data**: Persisted in Docker volume `dynamodb_data`

- **Web Shell**: http://localhost:8000/shell (for debugging)

---

## Environment Variables

### Problem: DynamoDB errors

| Variable           | Default                      | Description                    |

**Error:**|-------------------|------------------------------|--------------------------------|

```| DYNAMODB_ENDPOINT | http://dynamodb-local:8000   | DynamoDB service endpoint      |

Unable to connect to DynamoDB endpoint| FLASK_ENV         | development                  | Flask environment              |

```

## Development

**Solution:**

### Running Without Docker

```bash

# 1. Check DynamoDB is running1. **Start DynamoDB Local**

docker-compose ps dynamodb-local   ```bash

   docker run -p 8000:8000 amazon/dynamodb-local

# 2. Test DynamoDB directly   ```

curl http://localhost:8000

2. **Install Python dependencies**

# 3. Check environment variable in dotnet-api   ```bash

docker-compose exec dotnet-api printenv DYNAMODB_ENDPOINT   pip install -r requirements.txt

# Should show: http://dynamodb-local:8000   ```



# 4. Restart in correct order3. **Set environment variables**

docker-compose down   ```bash

docker-compose up -d   # Windows PowerShell

```   $env:DYNAMODB_ENDPOINT = "http://localhost:8000"

   

---   # Linux/Mac

   export DYNAMODB_ENDPOINT=http://localhost:8000

## Understanding Docker Layers (Advanced)   ```



Docker images are made of layers, like a cake:4. **Run Flask app**

   ```bash

```   python app.py

Image Layer Structure:   ```

┌─────────────────────────────────────┐  ← Read/Write (Container Layer)

│ Container: Your running app         │     Changes made here### Viewing DynamoDB Data

├═════════════════════════════════════┤

│ Layer 5: ENTRYPOINT ["dotnet"...   │  ← Image Layers (Read-Only)You can use the DynamoDB Local web shell to inspect data:

├─────────────────────────────────────┤     Shared between containers```bash

│ Layer 4: COPY --from=build /app    │     Cached for fast rebuilds# Open in browser

├─────────────────────────────────────┤http://localhost:8000/shell

│ Layer 3: RUN useradd appuser        │```

├─────────────────────────────────────┤

│ Layer 2: RUN apt-get install curl  │Or use AWS CLI with local endpoint:

├─────────────────────────────────────┤```bash

│ Layer 1: FROM aspnet:8.0            │aws dynamodb scan --table-name items --endpoint-url http://localhost:8000

└─────────────────────────────────────┘```



Each RUN, COPY, ADD command = New layer## Sample API Usage

```

### Create Items

**Why Layers Matter:**```bash

# Create multiple test items

```curl -X POST http://localhost:5000/items \

Build #1 (First Time):  -H "Content-Type: application/json" \

┌────────────────────────────────┐  -d '{"id": "item1", "name": "Laptop", "category": "Electronics", "price": 999.99}'

│ FROM aspnet:8.0     ────────────┼─ Downloaded (5 min)

│ RUN apt-get update  ────────────┼─ Executed (30 sec)curl -X POST http://localhost:5000/items \

│ COPY app files      ────────────┼─ Copied (1 sec)  -H "Content-Type: application/json" \

└────────────────────────────────┘  -d '{"id": "item2", "name": "Book", "category": "Education", "price": 29.99}'

Total: ~6 minutes```



Build #2 (Changed app code):### Retrieve Items

┌────────────────────────────────┐```bash

│ FROM aspnet:8.0     ────────────┼─ CACHED! ✓ (instant)# Get all items

│ RUN apt-get update  ────────────┼─ CACHED! ✓ (instant)curl http://localhost:5000/items

│ COPY app files      ────────────┼─ Re-copied (1 sec)

└────────────────────────────────┘# Get specific item

Total: ~1 second! 🚀curl http://localhost:5000/items/item1

``````



**Best Practice:** Put frequently changing commands (COPY app code) AFTER stable commands (install dependencies).### Update Items

```bash

---curl -X PUT http://localhost:5000/items/item1 \

  -H "Content-Type: application/json" \

## Docker vs Virtual Machines  -d '{"id": "item1", "name": "Gaming Laptop", "category": "Electronics", "price": 1299.99}'

```

**Virtual Machines (Old Way):**

### Delete Items

``````bash

┌─────────────────────────────────────────────────┐curl -X DELETE http://localhost:5000/items/item1

│ Physical Computer                                │```

│ ┌─────────────────────────────────────────────┐ │

│ │ Host OS (Windows)                           │ │---

│ │ ┌─────────────────────────────────────────┐ │ │

│ │ │ Hypervisor (VMware, VirtualBox)         │ │ │## 🛠️ Troubleshooting

│ │ │ ┌─────────┐ ┌─────────┐ ┌─────────┐   │ │ │

│ │ │ │  VM 1   │ │  VM 2   │ │  VM 3   │   │ │ │### **TL;DR Troubleshooting Flow:**

│ │ │ │ Linux OS│ │ Linux OS│ │ Linux OS│   │ │ │ Each VM = Full OS!```

│ │ │ │ (1GB)   │ │ (1GB)   │ │ (1GB)   │   │ │ │ Heavy & SlowProblem?

│ │ │ │  App    │ │  App    │ │  App    │   │ │ │   │

│ │ │ └─────────┘ └─────────┘ └─────────┘   │ │ │   ├─ Check if Docker is running

│ │ └─────────────────────────────────────────┘ │ │   │  └─ docker info (should not error)

│ └─────────────────────────────────────────────┘ │   │

└─────────────────────────────────────────────────┘   ├─ Check service status

Boot time: Minutes per VM   │  └─ docker-compose ps

Resource usage: Heavy (GBs per VM)   │

```   ├─ Check logs for errors

   │  └─ docker-compose logs [service-name]

**Docker Containers (New Way):**   │

   ├─ Check ports are available

```   │  └─ netstat -ano | findstr "5000 8000 8080"

┌─────────────────────────────────────────────────┐   │

│ Physical Computer                                │   └─ Nuclear option: Full reset

│ ┌─────────────────────────────────────────────┐ │      └─ docker-compose down -v && docker-compose up --build

│ │ Host OS (Windows/Mac/Linux)                 │ │```

│ │ ┌─────────────────────────────────────────┐ │ │

│ │ │ Docker Engine                           │ │ │### Common Issues & Solutions

│ │ │ ┌─────────┐ ┌─────────┐ ┌─────────┐   │ │ │

│ │ │ │Container│ │Container│ │Container│   │ │ │#### 1. "Cannot connect to Docker daemon"

│ │ │ │  App    │ │  App    │ │  App    │   │ │ │ Shares Host OS!```

│ │ │ │ (50MB)  │ │ (50MB)  │ │ (50MB)  │   │ │ │ Light & FastError: Cannot connect to the Docker daemon at unix:///var/run/docker.sock

│ │ │ └─────────┘ └─────────┘ └─────────┘   │ │ │```

│ │ └─────────────────────────────────────────┘ │ │**Cause:** Docker Desktop not running  

│ └─────────────────────────────────────────────┘ │**Solution:**

└─────────────────────────────────────────────────┘```powershell

Start time: Seconds# Windows: Start Docker Desktop from Start Menu

Resource usage: Light (MBs per container)# Mac: Start Docker from Applications

```# Linux: sudo systemctl start docker



**Key Differences:**# Verify:

docker info

| Feature           | Virtual Machines  | Docker Containers |```

|-------------------|-------------------|-------------------|

| Startup Time      | Minutes           | Seconds           |#### 2. "Port already in use"

| Size              | GBs               | MBs               |```

| Resource Usage    | Heavy             | Light             |Error: Bind for 0.0.0.0:5000 failed: port is already allocated

| Isolation         | Full OS isolation | Process isolation |```

| Portability       | Medium            | Excellent         |**Cause:** Another process using port 5000, 8000, or 8080  

**Diagnosis:**

---```powershell

# Find process using port (Windows)

## Summary: Key Takeawaysnetstat -ano | findstr ":5000"



1. **Docker** packages your app + dependencies into a portable container# Find process using port (Mac/Linux)

2. **Docker Compose** orchestrates multiple containers as one applicationlsof -i :5000

3. **Images** are blueprints, **containers** are running instances

4. **Multi-stage builds** keep images small and secure# Kill process (Windows - use PID from netstat)

5. **Port mapping** lets you access containers from your computertaskkill /PID <pid> /F

6. **Networks** let containers talk to each other using names

7. **Volumes** enable live-reload during development# Kill process (Mac/Linux)

8. **Health checks** ensure dependencies are ready before startupkill -9 <pid>

```

**The Magic:** Write once, run anywhere. No more "works on my machine" problems! 🎉

**Alternative:** Change ports in docker-compose.yml:

---```yaml

ports:

## Next Steps  - "5001:5000"  # Use port 5001 instead of 5000

```

- Modify `frontend/index.html` and see changes instantly

- Change backend code in `backend/Program.cs` and rebuild#### 3. "flask-app is unhealthy"

- Explore DynamoDB using AWS CLI or NoSQL Workbench```

- Add persistent storage with Docker volumesStatus: flask-app (unhealthy)

- Deploy to AWS ECS or Azure Container Instances```

**Cause:** Flask app failing health checks  

---**Diagnosis:**

```powershell

**Questions?** Check container logs: `docker-compose logs -f`# Check Flask logs

docker-compose logs flask-app

**Still stuck?** File an issue or read Docker docs at https://docs.docker.com

# Common causes:
# - DynamoDB connection failed
# - Python syntax error
# - Missing dependencies
# - Curl not installed (check Dockerfile)
```

**Solution:**
```powershell
# Rebuild with no cache
docker-compose build --no-cache flask-app
docker-compose up -d
```

#### 4. "frontend not starting"
```
Status: vue-frontend (waiting for flask-app to be healthy)
```
**Cause:** Flask health check never passes  
**This is CORRECT behavior!** Frontend waits for backend.

**Check Flask status:**
```powershell
docker-compose ps
# If flask-app shows "unhealthy", fix Flask first
```

#### 5. "CORS errors in browser console"
```
Access to fetch at 'http://localhost:5000/items' from origin 'http://localhost:8080' 
has been blocked by CORS policy
```
**Cause:** CORS not properly configured  
**Solution:** Already fixed in app.py, but verify:
```python
from flask_cors import CORS
CORS(app, resources={r"/*": {"origins": "*", "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"]}})
```

Rebuild:
```powershell
docker-compose up -d --build flask-app
```

#### 6. "Cannot delete items from frontend"
**Symptom:** Delete button doesn't work, no error  
**Cause:** Usually CORS issue with DELETE method  
**Check:**
1. Open browser Developer Tools (F12)
2. Go to Console tab
3. Look for red CORS errors
4. Check Network tab for failed requests

**Solution:** Verify CORS allows DELETE (already configured in our app.py)

#### 7. "Out of disk space"
```
Error: no space left on device
```
**Cause:** Docker images/containers using too much disk  
**Solution:**
```powershell
# See disk usage
docker system df

# Clean up unused images/containers
docker system prune -a

# Nuclear option: Remove everything (keeps volumes)
docker system prune -a --volumes
```

#### 8. "Build takes forever"
**Cause:** Downloading dependencies every time  
**Solution:** Docker layer caching is working, but you can:
```powershell
# Use BuildKit (faster builds)
$env:DOCKER_BUILDKIT=1
docker-compose build

# Or pre-download base images
docker pull python:3.11-slim
docker pull nginx:alpine
docker pull amazon/dynamodb-local:latest
```

### Health Check Debugging

**Check health status:**
```powershell
# See detailed health check output
docker inspect flask-app --format='{{json .State.Health}}' | ConvertFrom-Json

# Expected output:
# Status: healthy
# FailingStreak: 0
# Log: [
#   {
#     "Start": "2025-11-05T10:15:01Z",
#     "End": "2025-11-05T10:15:02Z",
#     "ExitCode": 0,
#     "Output": "{\"status\":\"healthy\"}"
#   }
# ]
```

**Manual health check:**
```powershell
# Test health endpoint from inside container
docker exec flask-app curl -f http://localhost:5000/health

# Test from host
curl http://localhost:5000/health
```

### Performance Issues

**Slow startup?**
```powershell
# Check what's taking time
docker-compose up --build

# Typical timing:
# - Pulling images: 30-60s (first time only)
# - Building Flask: 30-90s (first time only)
# - Starting services: 5-10s
# - Health checks: 10-20s

# Subsequent starts (images cached):
docker-compose up -d  # ~5-10 seconds total
```

**High CPU/Memory usage?**
```powershell
# Check resource usage
docker stats

# Expected:
# dynamodb-local: ~300MB RAM, <5% CPU
# flask-app:      ~50MB RAM, <2% CPU
# vue-frontend:   ~2MB RAM, <1% CPU
```

### Complete Reset (Nuclear Option)

When all else fails:
```powershell
# 1. Stop and remove everything
docker-compose down -v

# 2. Remove all flask-dynamo-demo images
docker images | Select-String "flask-dynamo-demo" | ForEach-Object { docker rmi -f $_.Line.Split()[2] }

# 3. Clean Docker system
docker system prune -f

# 4. Fresh start
docker-compose up --build -d

# 5. Wait for health checks
Start-Sleep -Seconds 20

# 6. Verify
docker-compose ps
```

---

## 📊 Resource Usage

---

## 📊 Resource Usage

### Disk Space
```
Image Sizes:
├─ python:3.11-slim          ~140MB
├─ amazon/dynamodb-local     ~500MB
├─ nginx:alpine              ~5MB
├─ flask-dynamo-demo-flask   ~250MB (python + deps)
└─ Total                     ~900MB
```

### Runtime Memory
```
┌─────────────────┬─────────┬──────────┐
│ Container       │ RAM     │ CPU      │
├─────────────────┼─────────┼──────────┤
│ dynamodb-local  │ ~300MB  │ <5%      │
│ flask-app       │ ~50MB   │ <2%      │
│ vue-frontend    │ ~2MB    │ <1%      │
├─────────────────┼─────────┼──────────┤
│ TOTAL           │ ~352MB  │ <8%      │
└─────────────────┴─────────┴──────────┘
```

**Comparison to running natively:**
```
Native (no Docker):           With Docker:
├─ Python 3.11      ~50MB    ├─ All services  ~350MB
├─ Node.js          ~30MB    ├─ Isolated envs
├─ Java (DynamoDB)  ~200MB   ├─ Reproducible
├─ Global packages  ~100MB   └─ One command to start ✓
└─ Total            ~380MB   
   (similar memory, harder to manage)
```

---

## 🎓 Key Concepts Explained (FAANG Interview Style)

### Q: Why separate containers instead of one container?

**Bad Approach: Monolithic Container**
```dockerfile
FROM ubuntu
RUN apt-get install python java nginx
COPY everything .
CMD start-everything.sh
```
**Problems:**
- ❌ 2GB+ image size
- ❌ One service crashes → entire container restarts
- ❌ Can't scale services independently
- ❌ Hard to update individual components

**Good Approach: Microservices**
```yaml
services:
  database:    # Scalable independently
  backend:     # Can update without touching DB
  frontend:    # Can deploy frontend changes fast
```
**Benefits:**
- ✓ Small images (5-500MB each)
- ✓ Service isolation (one crash ≠ total failure)
- ✓ Independent scaling (10x frontend, 1x database)
- ✓ Easy updates (rebuild only what changed)

### Q: Why use docker-compose instead of multiple `docker run` commands?

**Without docker-compose:**
```bash
# Create network
docker network create my-net

# Start DB
docker run -d --name db --network my-net -p 8000:8000 amazon/dynamodb-local ...

# Start Flask (need to wait for DB...)
sleep 10
docker run -d --name api --network my-net -p 5000:5000 \
  -e DYNAMODB_ENDPOINT=http://db:8000 flask-app

# Start frontend (need to wait for Flask...)
sleep 20
docker run -d --name web --network my-net -p 8080:80 \
  -v ./frontend:/usr/share/nginx/html nginx:alpine

# This is 15+ lines and error-prone!
```

**With docker-compose:**
```bash
docker-compose up -d

# One line, handles:
# - Network creation
# - Service dependencies
# - Health checks
# - Volume mounting
# - Environment variables
```

### Q: Why health checks? Can't we just use `depends_on`?

**Problem with `depends_on` alone:**
```yaml
services:
  flask-app:
    depends_on:
      - dynamodb-local  # Waits for START, not READY
```

**Timeline:**
```
t=0s:  Start dynamodb-local container
t=1s:  Container running (but Java app still loading...)
t=2s:  Start flask-app (depends_on satisfied!)
t=3s:  Flask tries to connect to DynamoDB
t=3s:  ERROR: Connection refused (DynamoDB not ready yet!)
```

**Solution with health checks:**
```yaml
services:
  flask-app:
    healthcheck:
      test: ["CMD", "curl", "http://localhost:5000/health"]
    depends_on:
      dynamodb-local:
        condition: service_healthy  # Wait until HEALTHY
```

**Timeline:**
```
t=0s:   Start dynamodb-local
t=1s:   DynamoDB health check... fail
t=11s:  DynamoDB health check... success! HEALTHY
t=12s:  Now start flask-app (database is ready)
```

### Q: What's the difference between COPY and volume mount?

**COPY (in Dockerfile):**
```dockerfile
COPY app.py /app/
```
- Copies files INTO image at BUILD time
- File becomes part of image (permanent)
- Changes require rebuild
- Good for: Application code, static files

**Volume Mount (in docker-compose.yml):**
```yaml
volumes:
  - ./frontend:/usr/share/nginx/html
```
- Links host directory to container at RUNTIME
- Changes on host immediately visible in container
- No rebuild needed
- Good for: Development, configuration files

**Example:**
```
# Edit frontend/index.html on your computer
vim frontend/index.html

# With COPY: Must rebuild
docker-compose build frontend  # 30 seconds
docker-compose up -d

# With volume mount: Instant!
# Just refresh browser, changes visible immediately ✓
```

### Q: Why `-inMemory` for DynamoDB?

**Trade-offs:**

| Aspect | -inMemory | Persistent (with volume) |
|--------|-----------|--------------------------|
| Speed | ✓✓✓ Fast (RAM) | ✓ Slower (disk I/O) |
| Data persistence | ✗ Lost on restart | ✓ Survives restarts |
| Disk usage | ✓ 0 bytes | ✗ Can grow large |
| Use case | ✓ Development | ✓ Testing/Staging |

**For production**: Use real AWS DynamoDB (fully managed, durable, scalable)

---

## 🚦 Production Readiness Checklist

This demo is educational. For production, consider:

### Security
- [ ] Remove CORS wildcard `origins: "*"`
- [ ] Add authentication/authorization
- [ ] Use secrets management (not environment variables)
- [ ] Enable HTTPS/TLS
- [ ] Scan images for vulnerabilities (`docker scan`)
- [ ] Run containers as non-root ✓ (already implemented)

### Reliability
- [ ] Replace `-inMemory` with persistent storage
- [ ] Add proper logging (not just stdout)
- [ ] Implement rate limiting
- [ ] Add request timeouts
- [ ] Use production WSGI server (gunicorn, not Flask dev server)

### Observability
- [ ] Add metrics (Prometheus)
- [ ] Implement tracing (Jaeger, OpenTelemetry)
- [ ] Centralized logging (ELK, Splunk)
- [ ] Set up alerts (PagerDuty, Opsgenie)

### Scalability
- [ ] Use container orchestration (Kubernetes, ECS)
- [ ] Implement load balancing
- [ ] Add caching layer (Redis)
- [ ] Database read replicas
- [ ] CDN for static assets

### Infrastructure
- [ ] CI/CD pipeline (GitHub Actions, Jenkins)
- [ ] Infrastructure as Code (Terraform, CloudFormation)
- [ ] Automated testing
- [ ] Blue-green or canary deployments

---

## 📚 Further Learning

### Docker Concepts
- **Images vs Containers**: Image = Class, Container = Instance
- **Layers**: Each Dockerfile instruction creates a new layer
- **BuildKit**: Modern build engine (faster, more features)
- **Multi-stage builds**: Reduce final image size

### Docker Compose
- **Profiles**: Different configs for dev/staging/prod
- **Extends**: Share common configuration
- **Secrets**: Secure credential management
- **Networks**: Bridge, host, overlay modes

### Best Practices
- **Small base images**: alpine, distroless
- **Layer caching**: Order instructions by change frequency
- **.dockerignore**: Exclude unnecessary files from context
- **Health checks**: Always implement for production
- **Security scanning**: Regular vulnerability checks

---

## 📞 Support & Contributing

### Getting Help
1. Check this README thoroughly
2. Review logs: `docker-compose logs`
3. Check [SHARING_GUIDE.md](SHARING_GUIDE.md) for deployment
4. Search existing issues
5. Create new issue with:
   - OS and Docker version
   - Full error message
   - Output of `docker-compose ps`
   - Output of `docker-compose logs`

### Contributing
Contributions welcome! Please:
1. Fork the repository
2. Create feature branch
3. Add tests if applicable
4. Update documentation
5. Submit pull request

---

## 📝 License & Credits

**License:** MIT (free to use, modify, distribute)

**Technologies Used:**
- **Flask** - Lightweight Python web framework
- **DynamoDB Local** - AWS's local database for development
- **Vue.js** - Progressive JavaScript framework
- **nginx** - High-performance web server
- **Docker** - Container platform
- **Docker Compose** - Multi-container orchestration

**Created**: November 2025  
**Last Updated**: November 2025

---

## 🎯 Summary

**What you learned:**
- ✓ How Docker containers work (images, layers, isolation)
- ✓ How Dockerfile instructions build images step-by-step
- ✓ How docker-compose orchestrates multiple services
- ✓ Why health checks matter for service dependencies
- ✓ Best practices for container security and efficiency
- ✓ How to troubleshoot common Docker issues

**What you built:**
- ✓ Full-stack application with 3 services
- ✓ REST API with CRUD operations
- ✓ NoSQL database (DynamoDB)
- ✓ Interactive web frontend
- ✓ All deployable with one command!

**Next steps:**
- Deploy to cloud (AWS ECS, DigitalOcean, Heroku)
- Add more features (authentication, search, pagination)
- Implement caching (Redis)
- Set up CI/CD pipeline
- Learn Kubernetes for production orchestration

---

**Happy Dockerizing! 🐳🚀**
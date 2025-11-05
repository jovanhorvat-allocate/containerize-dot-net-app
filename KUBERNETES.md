# Kubernetes Commands — Build & Deploy

> **Restaurant Analogy**: You've created the blueprints (YAML files) for your restaurant. Now it's time to actually build and open the restaurant!

---

## Kubernetes Glossary (With Analogies)

Before diving in, let's understand the key Kubernetes concepts you'll encounter:

### 🎯 **Pod**
**What?** The smallest deployable unit in Kubernetes. A Pod wraps one or more containers.

**Analogy**: A Pod is like a **work station** in a restaurant. It might have one chef (container) or a chef + sous chef working together at the same station. They share the same workspace (network, storage).

**In Our App**: Each frontend/API/database instance runs in its own Pod.

---

### 🚀 **Deployment**
**What?** A controller that manages Pods. It ensures the desired number of Pod replicas are always running.

**Analogy**: The **restaurant manager** who ensures you always have the right number of staff working. If someone calls in sick, the manager hires a replacement immediately.

**In Our App**: `replicas: 2` in the frontend Deployment means "always keep 2 frontend Pods running."

**THE MAGIC**: Self-healing! If a Pod crashes, the Deployment creates a new one automatically.

---

### 🔌 **Service**
**What?** A stable network endpoint that routes traffic to Pods. Even if Pods die and get new IP addresses, the Service name stays the same.

**Analogy**: The restaurant's **phone number**. Customers call the same number, but different employees (Pods) might answer. Even if employees change, the phone number stays the same.

**In Our App**: 
- `dynamodb-service` → Always routes to the DynamoDB Pod (even if it restarts and gets a new IP)
- `dotnet-api-service` → Load balances between 2 API Pods
- `frontend-service` → Load balances between 2 frontend Pods

**DNS MAGIC**: Other Pods can use the Service name like a URL:
- `http://dynamodb-service:8000` (not an IP address!)
- `http://dotnet-api-service:5000`

---

### 🏷️ **Label & Selector**
**What?** Key-value pairs that tag resources. Selectors use labels to find resources.

**Analogy**: **Name tags** at a conference. Everyone wears a tag saying "Dept: Sales" or "Dept: Engineering". When you need to announce something to all sales people, you look for the "Dept: Sales" tags.

**In Our App**:
```yaml
labels:
  app: frontend  # This Pod is tagged as "frontend"
  
selector:
  matchLabels:
    app: frontend  # Find all Pods tagged "app: frontend"
```

**HOW IT WORKS**: Services and Deployments use selectors to find which Pods they manage.

---

### 🌐 **ClusterIP (Service Type)**
**What?** A Service type that's only accessible WITHIN the Kubernetes cluster.

**Analogy**: An **internal phone extension** (like dialing "x123" within an office). Employees can call each other, but people outside the building can't dial in.

**In Our App**: 
- `dynamodb-service` (ClusterIP) → Only accessible to other Pods
- `dotnet-api-service` (ClusterIP) → Only accessible to other Pods

**WHY?** Security! Your database shouldn't be accessible from the internet.

---

### 🚪 **NodePort (Service Type)**
**What?** A Service type that exposes a port on the host machine, making it accessible from outside the cluster.

**Analogy**: The restaurant's **main entrance door** with a street address. Customers (external users) can come in from outside.

**In Our App**: `frontend-service` (NodePort on 30080) → Accessible at `http://localhost:30080`

**PORT RANGE**: NodePorts must be 30000-32767 (Kubernetes reserves this range).

---

### 🔄 **Replica**
**What?** The number of identical Pod copies running simultaneously.

**Analogy**: Having **multiple cashiers** at a store. If you have 3 replicas, you have 3 identical Pods sharing the workload.

**In Our App**:
- Frontend: `replicas: 2` → 2 nginx Pods
- API: `replicas: 2` → 2 .NET API Pods  
- DynamoDB: `replicas: 1` → Only 1 database (multiple writers would cause conflicts!)

**BENEFITS**:
- ✅ Load balancing (spread traffic across replicas)
- ✅ High availability (if one crashes, others keep working)
- ✅ Zero-downtime updates (update one at a time)

---

### 📦 **ConfigMap**
**What?** Stores configuration data (key-value pairs or files) that Pods can read.

**Analogy**: A **company handbook** or **recipe book** that all employees can reference. If you update the handbook, everyone sees the changes.

**In Our App**: `frontend-nginx-config` stores the nginx configuration file. It's mounted into the nginx Pods so they know how to proxy requests.

**WHY NOT BUILD INTO IMAGE?** Separation of concerns! You can change config without rebuilding the Docker image.

---

### 💾 **Volume**
**What?** Storage that can be mounted into containers. Survives container restarts.

**Analogy**: A **filing cabinet** or **shared drive** that containers can access. Even if the worker (container) gets replaced, the files (data) remain.

**Types We Use**:
- **hostPath**: Mounts a directory from the host machine (Rancher Desktop VM)
- **configMap**: Mounts configuration data as files

**In Our App**: Frontend uses hostPath to mount `/tmp/frontend` (the Vue.js files).

---

### 🩺 **Readiness Probe**
**What?** A health check that determines if a Pod is ready to receive traffic.

**Analogy**: Asking a chef **"Are you ready to take orders?"** If they say "Not yet, still setting up!", you don't send customers to them.

**In Our App**: API Pods have a readiness probe (`GET /api/todos`). Until it responds with HTTP 200, the Service won't route traffic to that Pod.

**BENEFIT**: Prevents sending requests to Pods that aren't ready yet (e.g., still loading data).

---

### 💚 **Liveness Probe**
**What?** A health check that determines if a Pod is still running correctly. If it fails, Kubernetes **restarts the container**.

**Analogy**: Checking **"Is anyone still in the kitchen?"** If nobody responds, you assume something went wrong and call a replacement chef.

**In Our App**: API Pods have a liveness probe. If nginx stops responding, Kubernetes restarts the container.

**DIFFERENCE FROM READINESS**:
- **Readiness**: "Are you ready?" → Removes from Service if not ready
- **Liveness**: "Are you alive?" → Restarts container if dead

---

### 🎯 **Namespace**
**What?** A virtual cluster within a Kubernetes cluster. Provides isolation between different projects/teams.

**Analogy**: Different **departments in a building** (Sales floor, Engineering floor, HR floor). Each department is isolated but in the same building.

**In Our App**: We use the `default` namespace (all resources go there).

**PRODUCTION USE**: You'd have namespaces like `production`, `staging`, `development`.

---

### 🔧 **kubectl**
**What?** The Kubernetes command-line tool. Your interface to the cluster.

**Analogy**: A **walkie-talkie** or **control panel** to talk to the Kubernetes system. You give commands, Kubernetes responds.

**Common Commands**:
- `kubectl get pods` → "Show me all the Pods"
- `kubectl apply -f file.yaml` → "Create/update resources from this file"
- `kubectl delete pod <name>` → "Delete this Pod"
- `kubectl describe pod <name>` → "Give me detailed info about this Pod"

---

### 🏗️ **Control Plane**
**What?** The brain of Kubernetes. Manages the cluster, schedules Pods, monitors health, etc.

**Analogy**: The **corporate headquarters** of a company. Makes decisions, assigns work to regional offices (nodes), monitors performance.

**Components**:
- **API Server**: The receptionist (all requests go through here)
- **Scheduler**: HR department (assigns Pods to nodes)
- **Controller Manager**: Quality assurance (ensures desired state matches actual state)
- **etcd**: The database (stores all cluster data)

---

### 💻 **Node**
**What?** A physical or virtual machine that runs Pods. The worker that does the actual work.

**Analogy**: A **regional office** or **store location**. The headquarters (control plane) tells this office what to do.

**In Rancher Desktop**: You typically have one node (your local machine running the VM).

**In Production**: You'd have many nodes (3, 10, 100+) for redundancy and scale.

---

### 🔄 **ReplicaSet**
**What?** A low-level controller that maintains a stable set of Pod replicas. Usually managed by a Deployment (you rarely touch ReplicaSets directly).

**Analogy**: The **shift scheduler** who ensures the right number of workers are on each shift. If someone doesn't show up, they call in a replacement.

**In Our App**: Each Deployment creates a ReplicaSet automatically. You'll see them in `kubectl get all`.

---

### 📊 **Endpoint**
**What?** The list of Pod IPs that a Service routes traffic to.

**Analogy**: The **phone extension directory**. "Sales department can be reached at extensions: 123, 456, 789."

**In Our App**: `frontend-service` has 2 endpoints (the IPs of the 2 frontend Pods).

**DYNAMIC**: If a Pod dies, its IP is removed from the endpoints. If a new Pod starts, its IP is added.

---

### 🎬 **Declarative Configuration**
**What?** You describe WHAT you want (desired state), not HOW to do it.

**Analogy**: Telling a chef **"I want a Caesar salad"** instead of **"First, wash the lettuce, then cut it, then..."**. You declare the outcome, not the steps.

**In Our App**:
```yaml
replicas: 2  # "I want 2 Pods" (declarative)
```

vs.

```bash
start_pod_1()
start_pod_2()  # "Do these steps" (imperative)
```

**KUBERNETES' JOB**: Figure out how to achieve your desired state and maintain it forever.

---

## Prerequisites

✅ Rancher Desktop installed and running  
✅ Kubernetes enabled in Rancher Desktop  
✅ Docker daemon running

---

## Step 1: Build the Docker Image

**What?** Create a Docker image for your .NET API from the Dockerfile.

**Why?** Kubernetes needs a Docker image to run your application. Think of it like taking your recipe and preparing meal kits that can be quickly cooked.

```powershell
docker build -t dotnet-api:latest ./backend
```

**Command Breakdown:**
- `docker build` — "Hey Docker, create an image"
- `-t dotnet-api:latest` — "Tag it with the name 'dotnet-api' and version 'latest'"
  - `-t` = tag (like putting a label on a jar)
  - `dotnet-api` = image name
  - `latest` = version tag (could also be `v1.0`, `dev`, etc.)
- `./backend` — "Use the Dockerfile in the backend folder"

**Analogy**: Like a chef preparing pre-packaged meal kits. The recipe (Dockerfile) becomes a ready-to-cook kit (Docker image).

**Expected Output:**
```
[+] Building 45.2s (15/15) FINISHED
 => [build 1/6] FROM mcr.microsoft.com/dotnet/sdk:8.0
 => [build 2/6] WORKDIR /src
 ...
 => => naming to docker.io/library/dotnet-api:latest
```

---

## Step 2: Prepare Frontend Files

**What?** Copy your Vue.js frontend files to `/tmp/frontend`.

**Why?** The `frontend.yaml` uses a `hostPath` volume pointing to `/tmp/frontend`. Kubernetes will mount these files into the nginx container.

```powershell
# Create the directory
mkdir C:\tmp\frontend -Force

# Copy your frontend files
Copy-Item -Path .\frontend\* -Destination C:\tmp\frontend -Recurse -Force
```

**Analogy**: Like stocking the host stand with menus and decorations before opening the restaurant.

**Important Note for Windows + Rancher Desktop:**
The `hostPath` in the YAML points to `/tmp/frontend` inside the Rancher Desktop Linux VM, not your Windows filesystem. We need to copy files to BOTH locations:

1. **Windows** (`C:\tmp\frontend`) - For easy access and editing
2. **Rancher Desktop VM** (`/tmp/frontend`) - Where Kubernetes actually mounts from

**Copy files to Rancher Desktop VM:**
```powershell
# Create directory inside Rancher Desktop's WSL distribution
wsl -d rancher-desktop mkdir -p /tmp/frontend

# Copy from Windows to the Rancher Desktop VM
# /mnt/c/ is how WSL accesses your C:\ drive
wsl -d rancher-desktop cp -r /mnt/c/tmp/frontend/* /tmp/frontend/
```

**Why This Extra Step?**
Rancher Desktop runs Kubernetes inside a WSL 2 Linux distribution. When the YAML says `hostPath: /tmp/frontend`, Kubernetes looks for that path inside the Linux VM, not on Windows.

**Analogy**: It's like having two restaurants - one in the USA and one in Europe. You need to stock BOTH kitchens, not just one. The `/mnt/c/` path is the "shipping route" between them.

**THE BACKSTORY:**
- Docker Desktop integrates tightly with Windows and auto-shares folders
- Rancher Desktop is more lightweight and runs in a separate Linux VM
- The VM can access Windows files through `/mnt/c/`, `/mnt/d/`, etc.
- But `hostPath` volumes look at the VM's filesystem, not Windows
- Solution: Copy files into the VM where Kubernetes can find them

---

## Step 3: Deploy to Kubernetes

**What?** Apply all three YAML files to create the resources in Kubernetes.

**Why?** This tells Kubernetes to create the Deployments and Services defined in your YAML files.

```powershell
kubectl apply -f k8s/
```

**Command Breakdown:**
- `kubectl` — The Kubernetes command-line tool (like a walkie-talkie to talk to Kubernetes)
- `apply` — "Create or update these resources"
- `-f k8s/` — "Read all YAML files from the k8s folder"

**Analogy**: Like handing your restaurant blueprints to the construction crew. They start building based on your plans.

**Expected Output:**
```
configmap/frontend-nginx-config created
deployment.apps/frontend created
service/frontend-service created
deployment.apps/dynamodb created
service/dynamodb-service created
deployment.apps/dotnet-api created
service/dotnet-api-service created
```

---

## Step 4: Check Deployment Status

**What?** Monitor your Pods to ensure they're running.

**Why?** Deployments take time to pull images, start containers, and run health checks. You want to verify everything started successfully.

```powershell
kubectl get pods
```

**Expected Output (after ~30 seconds):**
```
NAME                          READY   STATUS    RESTARTS   AGE
dynamodb-xxxxxxxxxx-xxxxx     1/1     Running   0          45s
dotnet-api-xxxxxxxxxx-xxxxx   1/1     Running   0          45s
dotnet-api-xxxxxxxxxx-yyyyy   1/1     Running   0          45s
frontend-xxxxxxxxxx-xxxxx     1/1     Running   0          45s
frontend-xxxxxxxxxx-yyyyy     1/1     Running   0          45s
```

**What to Look For:**
- `READY 1/1` — Container is ready (passed readiness probe)
- `STATUS Running` — Pod is running successfully
- `RESTARTS 0` — No crashes (low number is good)

**If Pods are NOT Running:**

```powershell
# Get detailed information about a specific Pod
kubectl describe pod <pod-name>

# View logs from a Pod
kubectl logs <pod-name>

# Example:
kubectl logs dotnet-api-xxxxxxxxxx-xxxxx
```

**Analogy**: Like checking if all your restaurant staff showed up and are at their stations.

---

## Step 5: Check Services

**What?** Verify that Services were created and have the correct ports.

```powershell
kubectl get services
```

**Expected Output:**
```
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes            ClusterIP   10.43.0.1       <none>        443/TCP          5d
dynamodb-service      ClusterIP   10.43.123.45    <none>        8000/TCP         1m
dotnet-api-service    ClusterIP   10.43.234.56    <none>        5000/TCP         1m
frontend-service      NodePort    10.43.345.67    <none>        80:30080/TCP     1m
```

**What to Look For:**
- `dynamodb-service` — ClusterIP on port 8000 (internal only)
- `dotnet-api-service` — ClusterIP on port 5000 (internal only)
- `frontend-service` — NodePort on 80:30080 (accessible externally on port 30080)

**Analogy**: Like checking that all phone lines are connected — internal intercoms for staff, and a public line for customers.

---

## Step 6: Access Your Application

**What?** Open your browser and visit the application.

```
http://localhost:30080
```

**What Happens:**
1. Browser connects to `localhost:30080` (NodePort)
2. Kubernetes routes to one of the 2 frontend Pods
3. nginx serves the Vue.js app (HTML/CSS/JS)
4. JavaScript calls `/api/todos`
5. nginx proxies to `dotnet-api-service:5000`
6. Kubernetes load balances to one of the 2 API Pods
7. API queries `dynamodb-service:8000`
8. Kubernetes routes to the DynamoDB Pod
9. Response flows back: DynamoDB → API → nginx → Browser

**Analogy**: Customer walks through the front door (port 30080), host greets them (nginx), takes their order, sends it to a chef (API Pod), chef gets ingredients (DynamoDB), meal comes back to customer.

---

## Testing Load Balancing Between Pods

### How to Verify You're Hitting Multiple Frontend Pods

**THE QUESTION**: How do I know Kubernetes is actually load balancing between my 2 frontend Pods?

**THE BACKSTORY**: 
When you visit `http://localhost:30080`, the request goes to the `frontend-service`, which then routes to one of the available frontend Pods. But from your browser, you can't tell WHICH Pod served your request. It's like calling a restaurant - you don't know which employee answered the phone!

**THE SOLUTION**: Watch the Pod logs in real-time and make requests. Each Pod will log which requests it handles.

---

### Method 1: Watch Logs from Both Frontend Pods

**Step 1**: Get the names of your frontend Pods
```powershell
kubectl get pods -l app=frontend
```

**Expected Output:**
```
NAME                        READY   STATUS    RESTARTS   AGE
frontend-6755d95766-7qf98   1/1     Running   0          10m
frontend-6755d95766-vhztn   1/1     Running   0          10m
```

**Step 2**: Open TWO PowerShell windows and watch logs from EACH Pod

**Window 1** (watch first Pod):
```powershell
kubectl logs -f frontend-6755d95766-7qf98
```

**Window 2** (watch second Pod):
```powershell
kubectl logs -f frontend-6755d95766-vhztn
```

**THE FLAG**: `-f` means "follow" (like `tail -f` in Linux). It keeps the logs streaming in real-time.

**Step 3**: Make requests from your browser
- Visit `http://localhost:30080` 
- Refresh the page multiple times (F5)
- Open it in different browser tabs

**WHAT TO OBSERVE**:
You'll see nginx access logs appearing in BOTH windows, showing that different Pods are handling different requests!

**Example Logs:**
```
10.42.0.1 - - [05/Nov/2025:12:54:23 +0000] "GET / HTTP/1.1" 200 1234
10.42.0.1 - - [05/Nov/2025:12:54:25 +0000] "GET /api/todos HTTP/1.1" 200 567
```

**ANALOGY**: It's like watching two cashiers at a store. Customer 1 goes to Cashier A, Customer 2 goes to Cashier B. You can see both cashiers working simultaneously!

---

### Method 2: Add Unique Identifiers to Each Pod

**THE IDEA**: Modify nginx to return the Pod's hostname (which is unique per Pod) in a response header. Then you can see which Pod handled each request!

**Step 1**: Check which Pod you're hitting using curl
```powershell
# Make a request and show all response headers
curl -I http://localhost:30080
```

**Step 2**: Make multiple requests and watch the backend
```powershell
# Loop 10 times and show which API Pod responds
for ($i=1; $i -le 10; $i++) {
    Write-Host "Request $i :"
    kubectl logs --tail=1 -l app=dotnet-api | Select-String "GET"
    Start-Sleep -Milliseconds 500
}
```

**WHY THIS WORKS**: Each request to the API triggers a log entry in one of the 2 API Pods. By watching the logs, you can see which Pod handled which request.

---

### Method 3: Use kubectl proxy and Direct Pod Access

**THE POWER MOVE**: Access each Pod DIRECTLY (bypassing the Service) to prove they're both working.

**Step 1**: Get Pod IPs
```powershell
kubectl get pods -l app=frontend -o wide
```

**Expected Output:**
```
NAME                        READY   STATUS    RESTARTS   AGE   IP           NODE
frontend-6755d95766-7qf98   1/1     Running   0          15m   10.42.0.45   rld-mkd-j27jbk3
frontend-6755d95766-vhztn   1/1     Running   0          15m   10.42.0.46   rld-mkd-j27jbk3
```

**Step 2**: Use kubectl port-forward to access each Pod individually

**Access Pod 1:**
```powershell
kubectl port-forward frontend-6755d95766-7qf98 8081:80
```
Then open: `http://localhost:8081`

**Access Pod 2** (in a new PowerShell window):
```powershell
kubectl port-forward frontend-6755d95766-vhztn 8082:80
```
Then open: `http://localhost:8082`

**WHAT THIS PROVES**: Both Pods are running and serving the same content. You've directly accessed each one!

**ANALOGY**: It's like walking up to each cashier individually and saying "Hey, can you ring me up?" You're bypassing the line manager (Service) and talking directly to each worker (Pod).

**THE BACKSTORY**: 
- `kubectl port-forward` creates a tunnel from your machine to a specific Pod
- Port 8081 on your machine → Port 80 on Pod 1
- Port 8082 on your machine → Port 80 on Pod 2
- This lets you test each Pod independently

---

### Method 4: Watch Service Endpoints

**THE TECHNICAL VIEW**: See which Pod IPs the Service is routing to.

```powershell
kubectl describe service frontend-service
```

**Look for the "Endpoints" section:**
```
Name:                     frontend-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=frontend
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.31.208
IPs:                      10.43.31.208
Port:                     http  80/TCP
TargetPort:               80/TCP
NodePort:                 http  30080/TCP
Endpoints:                10.42.0.45:80,10.42.0.46:80  <-- THESE ARE YOUR 2 PODS!
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

**WHAT THIS SHOWS**: The Service has 2 endpoints (10.42.0.45:80 and 10.42.0.46:80), meaning it's load balancing between 2 Pods!

**THE BACKSTORY**:
- Each Pod gets a unique IP address when it starts
- The Service keeps a list of all healthy Pod IPs (these are the "Endpoints")
- When a request comes in, the Service picks one of these IPs using round-robin
- If a Pod dies, its IP is removed from the list automatically

**ANALOGY**: The Service is like a restaurant host with a list of available tables (Pods). "Table 45 and Table 46 are available - I'll seat you at one of them!"

---

### Summary: Which Method to Use?

| Method | What It Shows | Best For |
|--------|---------------|----------|
| **Watch Logs** | See which Pod handles each request | Understanding real-time load balancing |
| **Unique Identifiers** | Add headers to see Pod names | Debugging in production |
| **Direct Pod Access** | Access each Pod individually | Verifying both Pods work |
| **Service Endpoints** | See which IPs the Service uses | Technical understanding |

**RECOMMENDED**: Start with **Method 1** (watch logs) - it's the easiest and most visual way to see load balancing in action!

---

## Useful Kubernetes Commands

### View All Resources
```powershell
kubectl get all
```
Shows Pods, Services, Deployments, ReplicaSets in one view.

### Watch Pods in Real-Time
```powershell
kubectl get pods -w
```
The `-w` flag watches for changes (Ctrl+C to exit).

### View Deployment Details
```powershell
kubectl describe deployment dotnet-api
```
Shows events, replicas, conditions, and more.

### View Service Details
```powershell
kubectl describe service frontend-service
```
Shows endpoints (which Pod IPs the Service routes to).

### View Logs from a Pod
```powershell
kubectl logs <pod-name>

# Follow logs in real-time (like tail -f)
kubectl logs -f <pod-name>

# View logs from a specific container in a Pod
kubectl logs <pod-name> -c <container-name>
```

### Execute Commands Inside a Pod
```powershell
kubectl exec -it <pod-name> -- /bin/sh
```
Opens a shell inside the container (useful for debugging).

### Delete Everything
```powershell
kubectl delete -f k8s/
```
Deletes all resources defined in the k8s/ folder.

**Analogy**: Like closing the restaurant and sending everyone home.

### Port Forward (Alternative Access)
```powershell
kubectl port-forward service/frontend-service 8080:80
```
Access the frontend at `http://localhost:8080` (alternative to NodePort).

---

## Troubleshooting

### Pod Stuck in "Pending"
**Cause**: Kubernetes can't schedule the Pod (not enough resources or image pull issues).

**Check:**
```powershell
kubectl describe pod <pod-name>
```
Look at the "Events" section at the bottom.

---

### Pod in "CrashLoopBackOff"
**Cause**: Container starts but immediately crashes.

**Check:**
```powershell
kubectl logs <pod-name>
```
Look for error messages in the application logs.

---

### Pod in "ImagePullBackOff"
**Cause**: Kubernetes can't pull the Docker image.

**For Local Images:**
- Make sure `imagePullPolicy: Never` is set (we have this in dotnet-api.yaml)
- Verify the image exists locally: `docker images | grep dotnet-api`

**Fix:**
```powershell
# Rebuild the image
docker build -t dotnet-api:latest ./backend

# Then restart the deployment
kubectl rollout restart deployment dotnet-api
```

---

### Frontend Pods Stuck in "ContainerCreating"
**Symptom**: Pods stay in `ContainerCreating` status for more than 1 minute.

**Check Events:**
```powershell
kubectl describe pod -l app=frontend
```

**Common Error:**
```
FailedMount: MountVolume.SetUp failed for volume "frontend-files": 
hostPath type check failed: /tmp/frontend is not a directory
```

**THE PROBLEM:**
The `hostPath` volume points to `/tmp/frontend` inside the Rancher Desktop Linux VM, but the directory doesn't exist there yet or is empty.

**THE BACKSTORY:**
When you create `C:\tmp\frontend` on Windows, it exists on your Windows filesystem. But Kubernetes runs inside a WSL 2 Linux VM (Rancher Desktop). These are two SEPARATE filesystems!

Think of it like this: You stock a warehouse in New York, but your restaurant is in Los Angeles. The chef in LA can't access the New York warehouse - you need to ship the supplies to LA.

**THE SOLUTION:**
Copy files into the Rancher Desktop VM where Kubernetes can actually see them:

```powershell
# Create the directory in the Linux VM
wsl -d rancher-desktop mkdir -p /tmp/frontend

# Copy files from Windows (C:\tmp\frontend) to Linux VM (/tmp/frontend)
wsl -d rancher-desktop cp -r /mnt/c/tmp/frontend/* /tmp/frontend/

# Restart the frontend deployment to remount the volume
kubectl rollout restart deployment frontend

# Watch the Pods come back up
kubectl get pods -w
```

**WHY `/mnt/c/`?**
In WSL (Windows Subsystem for Linux), your Windows drives are mounted under `/mnt/`:
- `C:\` becomes `/mnt/c/`
- `D:\` becomes `/mnt/d/`

So `C:\tmp\frontend` is accessible from WSL as `/mnt/c/tmp/frontend`.

**ANALOGY**: The `/mnt/c/` is like a bridge between two islands (Windows and Linux). You walk across the bridge to move supplies from one island to the other.

---

### Can't Access http://localhost:30080
**Possible Causes:**
1. Frontend Pod not ready yet — Check: `kubectl get pods`
2. Wrong port — Verify: `kubectl get service frontend-service` shows `80:30080/TCP`
3. Rancher Desktop not forwarding ports — Restart Rancher Desktop
4. Frontend files not in Rancher Desktop VM — See "Frontend Pods Stuck" above

---

### API Can't Connect to DynamoDB
**Check Service Name:**
The API uses `DYNAMODB_ENDPOINT=http://dynamodb-service:8000`

**Verify:**
```powershell
# Check if dynamodb-service exists
kubectl get service dynamodb-service

# Check if DynamoDB Pod is running
kubectl get pods | grep dynamodb

# Test connection from API Pod
kubectl exec -it <dotnet-api-pod-name> -- curl http://dynamodb-service:8000
```

---

## What's Happening Under the Hood?

### Kubernetes Control Plane
Think of it as the restaurant's management office.

1. **API Server** — The receptionist who receives all requests
2. **Scheduler** — The HR manager who assigns workers to stations
3. **Controller Manager** — The supervisor who ensures everything runs smoothly
4. **etcd** — The filing cabinet with all restaurant records

### Your Application Flow

```
[You] kubectl apply -f k8s/
  ↓
[API Server] "Got it! Here are the blueprints."
  ↓
[etcd] Saves the desired state
  ↓
[Scheduler] "I'll put the Pods on nodes."
  ↓
[Kubelet] "I'm starting the containers now."
  ↓
[Pods Running] Your application is live!
  ↓
[Services] Route traffic to healthy Pods
```

**Analogy**: You hand blueprints to the manager → Manager saves them → HR assigns workers → Workers start their shifts → Receptionists direct customers to the right workers.

---

## Docker Compose vs Kubernetes

| Feature | Docker Compose | Kubernetes |
|---------|---------------|------------|
| **Where runs** | Single machine | Cluster (can span multiple machines) |
| **High Availability** | No (1 container = 1 instance) | Yes (replicas, auto-restart) |
| **Load Balancing** | No | Yes (Services distribute traffic) |
| **Auto-Healing** | No | Yes (replicas recreated if crashed) |
| **Scaling** | Manual | Manual or Auto (HorizontalPodAutoscaler) |
| **Service Discovery** | service name = container name | service name = DNS name |
| **Best For** | Local development | Production, staging, complex apps |

**Analogy**:
- **Docker Compose** = Home kitchen (you do everything yourself)
- **Kubernetes** = Restaurant chain (managers, backup staff, multiple locations)

---

## Summary

```powershell
# 1. Build the Docker image
docker build -t dotnet-api:latest ./backend

# 2. Prepare frontend files (Windows)
mkdir C:\tmp\frontend -Force
Copy-Item -Path .\frontend\* -Destination C:\tmp\frontend -Recurse -Force

# 3. Copy frontend files to Rancher Desktop VM
wsl -d rancher-desktop mkdir -p /tmp/frontend
wsl -d rancher-desktop cp -r /mnt/c/tmp/frontend/* /tmp/frontend/

# 4. Deploy to Kubernetes
kubectl apply -f k8s/

# 5. Check status
kubectl get pods
kubectl get services

# 6. If frontend Pods are stuck, restart them
kubectl rollout restart deployment frontend

# 7. Access your app
# Open browser: http://localhost:30080
```

**That's it!** Your restaurant is now open for business! 🎉

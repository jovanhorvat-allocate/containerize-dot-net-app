# ============================================================================
# MULTI-STAGE DOCKER BUILD FOR .NET APPLICATION
# ============================================================================
# This Dockerfile uses a "multi-stage build" pattern, which means we use
# multiple FROM statements to create separate build environments.
# 
# WHY? Because the SDK (Software Development Kit) needed to BUILD an app is
# HUGE (~1GB+), but we only need the smaller runtime (~200MB) to RUN it.
# 
# Think of it like this:
#   - Stage 1 (build): A full construction site with all tools and materials
#   - Stage 2 (runtime): Just the finished building, no construction equipment
#
# This makes our final Docker image much smaller and more secure!
# ============================================================================

# ============================================================================
# STAGE 1: BUILD STAGE
# ============================================================================
# This stage compiles our .NET code into executable files (DLLs)
# We call this stage "build" so we can reference it later with --from=build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# WORKDIR sets the working directory inside the container
# All subsequent commands (COPY, RUN) will execute from this directory
# Think of it like doing "cd /src" in a terminal
WORKDIR /src

# ============================================================================
# DEPENDENCY RESTORATION (Docker Layer Caching Optimization)
# ============================================================================
# We copy ONLY the .csproj file first, then run 'dotnet restore'
# 
# WHY COPY .csproj SEPARATELY?
# Docker uses a "layer caching" system. Each instruction (FROM, COPY, RUN)
# creates a new layer. Docker caches these layers and reuses them if nothing
# changed in that specific step.
#
# If we change our C# code but dependencies (packages) stay the same:
#   ✓ Docker reuses the cached "dotnet restore" layer (saves 30-60 seconds!)
#   ✗ If we copied ALL files first, changing ANY file would invalidate the
#     cache and force a full package restore every time
#
# ANALOGY: Imagine ordering groceries. If your grocery list (dependencies)
# hasn't changed, you just grab the same items quickly. But if you changed
# your recipe (code), you don't need to re-shop for all groceries!
COPY TodoApi.csproj .
RUN dotnet restore

# ============================================================================
# BUILD THE APPLICATION
# ============================================================================
# Now copy the actual C# source code file
COPY Program.cs .

# Compile and publish the application:
#   -c Release        = Build in Release mode (optimized, no debug symbols)
#   -o /app/publish   = Output the compiled files to /app/publish directory
# 
# This creates a self-contained set of DLL files that can run our application
RUN dotnet publish -c Release -o /app/publish

# ============================================================================
# STAGE 2: RUNTIME STAGE (Final Image)
# ============================================================================
# Now we start fresh with a new, smaller base image!
# This image only contains the .NET runtime (no SDK, no build tools)
# It's like moving from a construction site to a finished apartment
FROM mcr.microsoft.com/dotnet/aspnet:8.0

# Set working directory in the NEW container
WORKDIR /app

# ============================================================================
# INSTALL CURL FOR HEALTH CHECKS
# ============================================================================
# Docker Compose will use curl to check if our API is responding
# The aspnet image doesn't include curl by default, so we install it
#
# apt-get update           = Refresh package lists (like "check for updates")
# apt-get install -y curl  = Install curl without prompting for confirmation
# rm -rf /var/lib/apt/lists/* = Clean up package lists to reduce image size
#
# WHY THE CLEANUP? Every command adds size to the Docker image. By removing
# temporary files in the SAME RUN command (using &&), we keep the layer small.
# If we used separate RUN commands, the files would persist in earlier layers.
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# ============================================================================
# COPY COMPILED FILES FROM BUILD STAGE
# ============================================================================
# Remember Stage 1 (build stage)? We compiled our app there and put it in /app/publish
# Now we copy ONLY those compiled files from the build stage to this stage
#
# --from=build   = Copy from the "build" stage we named earlier
# /app/publish   = Source path in build stage
# .              = Destination (current WORKDIR, which is /app in runtime stage)
#
# MAGIC: The build stage container is discarded after this! We keep only the
# small runtime image + compiled files. The huge SDK is thrown away.
#
# SIZE COMPARISON:
#   SDK image:     ~1.2GB (includes compilers, build tools, libraries)
#   Runtime image: ~220MB (just what's needed to run the app)
#   Final savings: ~980MB! 🎉
COPY --from=build /app/publish .

# ============================================================================
# EXPOSE PORT (Documentation Only)
# ============================================================================
# EXPOSE tells Docker "this container listens on port 5000"
# 
# IMPORTANT: This does NOT actually publish the port to the host machine!
# It's purely documentation. The actual port mapping happens in docker-compose.yml
# with "ports: 5000:5000"
#
# Think of EXPOSE like putting a sign on a door: "Mail slot on door #5000"
# But you still need to actually create the mail slot (port mapping) to use it
EXPOSE 5000

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
# ENV sets environment variables that will be available when the container runs
#
# ASPNETCORE_URLS=http://+:5000
#   This tells ASP.NET Core to listen on ALL network interfaces (0.0.0.0) on port 5000
#   
#   + means "all interfaces" - both localhost AND the container's network interface
#   Without this, the app might only listen on localhost inside the container,
#   making it unreachable from outside the container!
#
# ANALOGY: It's like telling your phone to connect to WiFi on ANY available network,
# not just a specific one
ENV ASPNETCORE_URLS=http://+:5000

# ============================================================================
# SECURITY: CREATE NON-ROOT USER
# ============================================================================
# By default, containers run as root (superuser), which is dangerous!
# If an attacker exploits our app, they'd have full root privileges.
#
# BEST PRACTICE: Create a limited user account to run the application
#
# useradd -m -u 1001 appuser:
#   -m            = Create a home directory for this user
#   -u 1001       = Set user ID to 1001 (non-root)
#   appuser       = Username
#
# chown -R appuser:appuser /app:
#   -R            = Recursively change ownership
#   appuser:appuser = user:group (both named appuser)
#   /app          = Give appuser ownership of the /app directory
#
# ANALOGY: Instead of giving everyone in your house the master key (root),
# you create a guest account with limited access (appuser)
RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app

# Switch to the non-root user for all subsequent commands
# From this point on, the container runs with appuser privileges, not root
USER appuser

# ============================================================================
# ENTRYPOINT: THE COMMAND THAT RUNS WHEN CONTAINER STARTS
# ============================================================================
# ENTRYPOINT defines the main process that runs in the container
# When this process stops, the container stops
#
# dotnet TodoApi.dll = Run our compiled .NET application
#
# WHY ENTRYPOINT vs CMD?
#   - ENTRYPOINT: The main executable (harder to override)
#   - CMD: Default arguments (easier to override)
#   
# For a web API, we want ENTRYPOINT because this command should always run
#
# IMPORTANT: In a container, this process runs as PID 1 (Process ID 1)
# If it crashes, the whole container exits. Docker Compose will restart it
# based on the restart policy (which we set to "unless-stopped")
ENTRYPOINT ["dotnet", "TodoApi.dll"]

# ============================================================================
# HOW THIS ALL WORKS TOGETHER
# ============================================================================
# When you run "docker-compose build" or "docker build":
#
# 1. Docker reads this file line by line
# 2. Stage 1 (build): Downloads SDK image, restores packages, compiles code
# 3. Stage 2 (runtime): Downloads runtime image, copies compiled files from
#    Stage 1, installs curl, creates appuser
# 4. Stage 1 is discarded! Only Stage 2 becomes the final image
# 5. The final image is tagged (e.g., "dotnet-api:latest")
#
# When you run "docker-compose up":
# 1. Docker creates a container from this image
# 2. Runs as appuser (not root) ✓ Security
# 3. Executes "dotnet TodoApi.dll" as the main process
# 4. The app starts listening on port 5000 inside the container
# 5. Docker maps container port 5000 to host port 5000
# 6. Your app is now accessible at http://localhost:5000
# ============================================================================

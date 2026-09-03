# Dockerfiles & Images: DevOps Homework

A practical deep-dive into Docker image architecture, Dockerfile instructions, layer caching mechanisms, multi-stage builds, and container image optimization.

---

## Table of Contents

- [Overview & Container Image Principles](#overview--container-image-principles)
- [Image vs Container Architecture](#image-vs-container-architecture)
- [Dockerfile Instructions Deep-Dive](#dockerfile-instructions-deep-dive)
- [Layer Caching & Optimization Strategies](#layer-caching--optimization-strategies)
- [Multi-Stage Builds](#multi-stage-builds)
- [Essential Docker Image Commands](#essential-docker-image-commands)
- [Hands-on Practical Implementations](#hands-on-practical-implementations)
  - [Example 1: Node.js Microservice Image](#example-1-nodejs-microservice-image)
  - [Example 2: Python Web Application Image](#example-2-python-web-application-image)
  - [Example 3: Multi-Stage Production Build (Go / React)](#example-3-multi-stage-production-build-go--react)
- [Verification & Screenshots](#verification--screenshots)
- [Security & Production Best Practices](#security--production-best-practices)

---

## Overview & Container Image Principles

In containerized DevOps environments, a **Docker Image** is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries, and settings.

Images are built from declarative configuration files called **Dockerfiles**. Every instruction in a Dockerfile creates an immutable read-only layer in the storage driver (typically `overlay2`).

---

## Image vs Container Architecture

```text
+-------------------------------------------------------------+
| Container: Writable Container Layer (Copy-on-Write / CoW)   | <-- ephemeral
+-------------------------------------------------------------+
| Layer 4: CMD ["node", "server.js"]                          | <-- Read-only
+-------------------------------------------------------------+
| Layer 3: COPY . /app                                        | <-- Read-only
+-------------------------------------------------------------+
| Layer 2: RUN npm install --production                       | <-- Read-only
+-------------------------------------------------------------+
| Layer 1: Base Image (node:18-alpine)                        | <-- Read-only
+-------------------------------------------------------------+
```

- **Image:** An immutable, static blueprint composed of stacked read-only layers.
- **Container:** A runnable instance of an image with a thin writable container layer added on top via Copy-on-Write (CoW).
- When multiple containers run from the same base image, they share the underlying read-only layers, saving immense disk and memory overhead.

---

## Dockerfile Instructions Deep-Dive

| Instruction | Purpose | Best Practice / Common Usage |
|---|---|---|
| `FROM` | Specifies parent/base image | Always use specific tags (e.g., `node:18-alpine`) instead of mutable `:latest` |
| `WORKDIR` | Sets active working directory | Always use absolute paths (e.g., `WORKDIR /app`). Avoid multiple `cd` commands |
| `COPY` | Copies files from host context to image | Preferred over `ADD` for copying local files into the image |
| `ADD` | Copies files, extracts tar archives, downloads URLs | Use only when automatic tarball extraction is required |
| `RUN` | Executes commands during image build time | Chain commands using `&& \` and clean package caches (`rm -rf /var/cache/apk/*`) in the same layer |
| `ENV` | Sets persistent environment variables | Available during build and at container runtime |
| `ARG` | Defines build-time variables | Passed via `--build-arg`, not persisted in final running container |
| `EXPOSE` | Documents ports intended for publishing | Informational documentation for runtime port mapping (`-p`) |
| `ENTRYPOINT` | Configures container default executable | Defines the base command that cannot be easily overridden |
| `CMD` | Default arguments or command | Provides default arguments to `ENTRYPOINT` or default standalone command |
| `USER` | Switches execution user | Switch to non-root user (e.g., `USER node`) for least-privilege security |
| `VOLUME` | Creates a designated mount point | Specifies paths intended to hold persistent or host-mounted data |

---

## Layer Caching & Optimization Strategies

Docker caches intermediate layers during `docker build`. If an instruction and its inputs haven't changed, Docker reuses the cached layer (`Using cache`), reducing build times from minutes to seconds.

### The Ordering Principle: Least Frequently Changed First

#### ❌ Inefficient Order (Cache Invalidation on Every Code Edit):
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .                   # Invalidates cache whenever any code file changes!
RUN npm install            # Re-runs expensive package download every time!
CMD ["node", "index.js"]
```

#### ✅ Optimized Order (Leveraging Cache for Dependencies):
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./      # Cached unless dependencies change
RUN npm install --omit=dev # Reused from cache if package.json didn't change
COPY . .                   # Fast copy of code changes only
CMD ["node", "index.js"]
```

---

## Multi-Stage Builds

Multi-stage builds allow using multiple `FROM` statements in a single Dockerfile. Heavy compilers, SDKs, and build tooling are confined to builder stages, leaving only minimal runtime binaries in the final production image.

```dockerfile
# Stage 1: Build & Compile
FROM golang:1.21-alpine AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/app .

# Stage 2: Minimal Production Image
FROM alpine:3.19
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /bin/app /app/app
USER appuser
EXPOSE 8080
CMD ["/app/app"]
```

**Result:** Image size drops from **~850 MB** (Go SDK) to **~15 MB** (Alpine + Binary).

---

## Essential Docker Image Commands

| Command | Description |
|---|---|
| `docker build -t <name>:<tag> <dir>` | Builds an image from a Dockerfile in the specified context |
| `docker images` / `docker image ls` | Lists all local images, tags, IDs, and sizes |
| `docker image history <image>` | Shows each layer, instruction, size, and creation timestamp |
| `docker image inspect <image>` | Returns full JSON metadata (env, ports, entrypoint, architecture) |
| `docker tag <source> <target>` | Creates a new tag pointing to an existing image |
| `docker rmi <image>` | Removes one or more local images |
| `docker image prune -a` | Removes all unused/dangling images not referenced by containers |
| `docker save -o <file.tar> <image>` | Exports image to a portable tar archive |
| `docker load -i <file.tar>` | Loads image from a tar archive |

---

## Hands-on Practical Implementations

### Example 1: Node.js Microservice Image

**`docker-images/nodejs-app/index.js`:**
```javascript
const http = require('http');
const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'success',
    message: 'Hello from Docker Image Node.js Microservice!',
    timestamp: new Date().toISOString()
  }));
});

server.listen(PORT, () => {
  console.log(`Node server running on port ${PORT}`);
});
```

**`docker-images/nodejs-app/Dockerfile`:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY index.js .
EXPOSE 3000
USER node
CMD ["node", "index.js"]
```

**Build & Run:**
```bash
docker build -t nodejs-microservice:1.0 ./nodejs-app
docker run -d --name node-service -p 3000:3000 nodejs-microservice:1.0
curl http://localhost:3000
```

---

### Example 2: Python Web Application Image

**Dockerfile:**
```dockerfile
FROM python:3.9-alpine
WORKDIR /app
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

---

## Verification & Screenshots

### Screenshot 1: Docker Image Build & Layer Cache Proof
Demonstrates building the image using `docker build -t <tag> .` and showing intermediate build steps and cache hits.

![Docker Build](screenshots/docker-build.png)

---

### Screenshot 2: Local Images Listing & Size Verification (`docker images`)
Terminal output displaying the built images, repository tags, image IDs, and optimized image sizes.

![Docker Images List](screenshots/docker-images.png)

---

### Screenshot 3: Image Layer History (`docker history`)
Detailed inspection of individual layers, size contributions, and Dockerfile instruction mapping using `docker history`.

![Docker History](screenshots/docker-history.png)

---

## Security & Production Best Practices

1. **Use Minimal Base Images:** Choose Alpine (`alpine`) or Distroless over standard Ubuntu/Debian bases to minimize Common Vulnerabilities and Exposures (CVEs).
2. **Never Run as Root:** Explicitly set a non-root user (`USER node` or `USER 1001`).
3. **Use `.dockerignore`:** Exclude `.git`, `node_modules`, test files, `.env`, and local build artifacts from the build context.
4. **Pin Specific Image Digests/Tags:** Avoid mutable `:latest` tags in production to guarantee deterministic builds.
5. **Scan for Vulnerabilities:** Run `docker scout cves <image>` or `trivy image <image>` in CI pipelines before deployment.

---

*Maintained by mdkaif — DevOps Homework Submission*

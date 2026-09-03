# Docker Networking: DevOps Homework

A comprehensive guide and practical hands-on laboratory exploring Docker networking drivers, container-to-container communication, user-defined bridge networks, DNS service discovery, and port forwarding.

---

## Table of Contents

- [Overview & Container Network Model (CNM)](#overview--container-network-model-cnm)
- [Docker Network Drivers Breakdown](#docker-network-drivers-breakdown)
  - [1. Bridge Network (Default & User-Defined)](#1-bridge-network-default--user-defined)
  - [2. Host Network](#2-host-network)
  - [3. None Network](#3-none-network)
  - [4. Overlay Network](#4-overlay-network)
  - [5. Macvlan Network](#5-macvlan-network)
- [Default Bridge vs User-Defined Custom Bridge](#default-bridge-vs-user-defined-custom-bridge)
- [Docker Network Command Reference](#docker-network-command-reference)
- [Hands-on Practical Experiments](#hands-on-practical-experiments)
  - [Experiment 1: Inspecting Default Networks](#experiment-1-inspecting-default-networks)
  - [Experiment 2: Creating a User-Defined Bridge Network](#experiment-2-creating-a-user-defined-bridge-network)
  - [Experiment 3: Container-to-Container DNS Resolution](#experiment-3-container-to-container-dns-resolution)
  - [Experiment 4: Multi-Network Multi-Tier Architecture](#experiment-4-multi-network-multi-tier-architecture)
- [Port Publishing & NAT (Network Address Translation)](#port-publishing--nat-network-address-translation)
- [Verification & Screenshots](#verification--screenshots)
- [Troubleshooting & DevOps Best Practices](#troubleshooting--devops-best-practices)

---

## Overview & Container Network Model (CNM)

In microservices and containerized environments, isolated applications must communicate securely with each other, with databases, and with external clients over the internet.

Docker provides network virtualization using the **Container Network Model (CNM)**:
- **Sandbox:** An isolated network stack containing container network interfaces, routing tables, and DNS settings (Linux network namespace).
- **Endpoint:** Attaches a sandbox to a network (virtual ethernet pair `veth`).
- **Network:** An isolated collection of endpoints that communicate directly with one another.

---

## Docker Network Drivers Breakdown

| Driver | Description | Use Case | Isolation Level |
|---|---|---|---|
| **`bridge`** | Default driver; creates a private internal software bridge on the host (`docker0`). | Standalone microservices running on a single host. | High (isolated subnet with NAT). |
| **`host`** | Bypasses network isolation; container shares host's network namespace and ports directly. | High-performance networking (low latency, high throughput). | None (shares host IP and ports). |
| **`none`** | Disables all external networking. Only loopback (`lo`) interface is available. | Isolated batch tasks, security-sensitive operations. | Complete isolation. |
| **`overlay`** | Enables multi-host networking across different Docker daemons / Swarm nodes. | Swarm clusters, multi-host microservices. | High (VXLAN encapsulation). |
| **`macvlan`** | Assigns a unique MAC address directly from the physical network to the container. | Legacy apps requiring physical LAN IP addresses. | Routed directly via LAN. |

---

## Default Bridge vs User-Defined Custom Bridge

The difference between the default `bridge` and a user-defined custom bridge is one of the most critical Docker networking concepts:

| Feature | Default `bridge` (`bridge`) | User-Defined Bridge (`my-net`) |
|---|---|---|
| **DNS Name Resolution** | ❌ Containers can only reach each other by **IP address** | ✅ **Automatic embedded DNS resolution** by container name |
| **Isolation** | ⚠️ All containers attach by default unless configured | ✅ Isolated; only explicit containers join the network |
| **Live Connect/Disconnect** | ❌ Must restart/recreate container | ✅ Attach/detach running containers dynamically |
| **Environment Variables** | ❌ Static linking required (`--link`, deprecated) | ✅ Dynamic sharing and discovery |

> [!IMPORTANT]
> **Production Best Practice:** Never use the default bridge for production microservices. Always create dedicated user-defined bridge networks so services can discover each other reliably via container names (e.g., `web` reaching `db:5432`).

---

## Docker Network Command Reference

| Command | Purpose | Example |
|---|---|---|
| `docker network ls` | List all available Docker networks | `docker network ls` |
| `docker network create` | Create a new user-defined network | `docker network create --driver bridge my-network` |
| `docker network inspect` | View detailed network subnet, gateway, and connected containers | `docker network inspect my-network` |
| `docker network connect` | Connect a running container to an existing network | `docker network connect my-network my-container` |
| `docker network disconnect` | Disconnect a container from a network | `docker network disconnect my-network my-container` |
| `docker network rm` | Remove one or more unused networks | `docker network rm my-network` |
| `docker network prune` | Remove all unused networks | `docker network prune -f` |

---

## Hands-on Practical Experiments

### Experiment 1: Inspecting Default Networks

List out the out-of-the-box networks created by Docker:

```bash
docker network ls
```

Inspect the default bridge configuration (subnet, gateway, and IPAM driver):

```bash
docker network inspect bridge
```

---

### Experiment 2: Creating a User-Defined Bridge Network

Create an isolated bridge network with a custom subnet:

```bash
docker network create --driver bridge devops-net

# Verify the network was registered
docker network ls
```

Inspect the created network to observe the assigned Subnet and Gateway (e.g., `172.18.0.0/16` and `172.18.0.1`):

```bash
docker network inspect devops-net
```

---

### Experiment 3: Container-to-Container DNS Resolution

Launch two isolated Alpine containers attached to `devops-net` and test embedded DNS resolution:

```bash
# 1. Run container A
docker run -d --name service-alpha --network devops-net alpine sleep 3600

# 2. Run container B
docker run -d --name service-beta --network devops-net alpine sleep 3600

# 3. Test ping from service-alpha to service-beta by NAME (Automatic DNS!)
docker exec -it service-alpha ping -c 3 service-beta

# 4. Test ping from service-beta to service-alpha by NAME
docker exec -it service-beta ping -c 3 service-alpha
```

**Observation:** Docker's embedded DNS server (`127.0.0.11`) automatically resolves the container hostname `service-beta` to its private container IP address.

---

### Experiment 4: Multi-Network Multi-Tier Architecture

In production multi-tier architecture, the database should never be exposed to the public frontend network:

```text
+-----------------------+              +-----------------------+              +-----------------------+
|   frontend-service    |              |    backend-service    |              |   database-service    |
|   (Public Facing)     |              |    (API Layer)        |              |   (Private DB)        |
+-----------------------+              +-----------------------+              +-----------------------+
            \                                      /       \                                      /
             \                                    /         \                                    /
              +----------------------------------+           +----------------------------------+
              |          frontend-net            |           |           backend-net            |
              +----------------------------------+           +----------------------------------+
```

```bash
# Create separated networks
docker network create frontend-net
docker network create backend-net

# Deploy services
docker run -d --name frontend-app --network frontend-net -p 80:80 nginx:alpine
docker run -d --name backend-api --network frontend-net alpine sleep 3600
docker run -d --name database-store --network backend-net alpine sleep 3600

# Connect backend-api to backend-net as well (Dual-Homed)
docker network connect backend-net backend-api

# Verification:
# 1. backend-api CAN reach database-store
docker exec -it backend-api ping -c 2 database-store   # SUCCESS

# 2. frontend-app CANNOT reach database-store (Full Network Isolation!)
docker exec -it frontend-app ping -c 2 database-store  # UNREACHABLE (Safe!)
```

---

## Port Publishing & NAT (Network Address Translation)

Containers have private IP addresses on their bridge network that cannot be routed directly from outside host machines. Docker uses `iptables` NAT rules on the host:

```bash
# Map host port 8080 to container port 80
docker run -d --name web-server -p 8080:80 nginx:alpine

# Test access from host
curl http://localhost:8080
```

- `-p <host_port>:<container_port>`: Explicit binding.
- `-p 127.0.0.1:8080:80`: Restricts listening to localhost only (prevents public internet access).
- `-P`: Dynamically binds all `EXPOSE` ports to high ephemeral host ports (`32768`–`60999`).

---

## Verification & Screenshots

### Screenshot 1: Docker Network Listing & Inspect Proof
Terminal output of `docker network ls` and `docker network inspect devops-net` displaying the active subnet, gateway, and connected container endpoints.

![Docker Network List & Inspect](screenshots/docker-network-ls.png)

---

### Screenshot 2: Automatic DNS & Ping Resolution
Terminal output verifying `service-alpha` successfully pinging `service-beta` using its container hostname rather than IP address.

![Docker DNS Ping Proof](screenshots/docker-dns-ping.png)

---

### Screenshot 3: Port Forwarding & Host Curl Test
Output demonstrating external host connectivity via port mapping (`curl http://localhost:8080`).

![Docker Port Mapping](screenshots/docker-port-curl.png)

---

## Troubleshooting & DevOps Best Practices

1. **Extract Container IP Instantly:**
   ```bash
   docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_name>
   ```
2. **Inspect Embedded DNS Resolution:**
   ```bash
   docker exec -it <container> nslookup <target_container>
   ```
3. **Port Conflict Diagnosis:**
   If `port is already allocated`, check which process holds the port:
   ```bash
   # On macOS:
   lsof -i :<port>
   # On Linux:
   ss -tulnp | grep :<port>
   ```
4. **Isolate Sensitive Workloads:** Place backend databases in private user-defined networks without external host port bindings (`-p`).
5. **Clean Up Orphaned Networks:** Regularly run `docker network prune` to remove dangling virtual networks.

---

*Maintained by mdkaif — DevOps Homework Submission*

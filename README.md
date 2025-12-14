# Titan Infrastructure

**Status:** ACTIVE
**Phase:** 4 (Observability & Stabilization)
**Method:** Ansible (IaC) + Docker Compose
**Hypervisor:** Synology VMM

## 1. Operational Overview
**Titan Infrastructure** is the Infrastructure-as-Code (IaC) repository for the **Titan Cyber Range**. It facilitates the transition from fragile, GUI-dependent proprietary systems to a headless, reproducible Ubuntu architecture.

The primary objective is **Disaster Recovery (DR) reduction**: Rebuilding the entire media, proxy, security, and monitoring stack takes <10 minutes via Ansible.

## 2. Architecture & Stack
* **Infrastructure:** Synology VMM (Hypervisor) hosting Ubuntu Server 22.04 LTS (Defense) and Kali Linux (Attack).
* **Provisioning:** Ansible (Modular Roles).
* **Orchestration:** Docker Compose v2 (Microservices).
* **Traffic Control:** Traefik v2.11 (Edge Router & Reverse Proxy).
* **Observability:** Prometheus (Metrics), Grafana (Viz), Node Exporter (Telemetry).
* **Security:** Wazuh (SIEM), Suricata (NIDS), UFW (Default Deny).

## 3. Project Structure
The repository utilizes a modular role-based architecture segmented by function:

```text
.
├── inventory.ini       # Host definitions (Defense Node vs. Attack Platform)
├── site.yml            # Main playbook entry point
└── roles/
    ├── common/         # Base packages (vim, git, curl, htop)
    ├── security/       # Hardening (Wazuh, UFW, Fail2Ban)
    ├── docker/         # Docker Engine & Network Bridges
    ├── media/          # Application Stack (Sonarr, Radarr, SABnzbd)
    ├── proxy/          # Traefik Edge Router configuration
    ├── observability/  # Monitoring Stack (Prometheus, Grafana)
    └── attack_base/    # Red Team provisioning (Kali Linux tools)
```
## 4. Security & Governance
* Zero Trust: SSH Password auth disabled. Access via Ed25519 keys only.
* Firewall: UFW "Default Deny" ingress policy.
  * Allowed (Edge): 80/443 (Traefik).
  * Allowed (Internal): 3000 (Grafana), 9090 (Prometheus).
* Resource Governance: Strict JVM Heap limits applied to Wazuh/OpenSearch to prevent I/O thrashing on limited hardware.

## 5. Usage
**Prerequisites:**
* Ansible (sudo apt install ansible)
* SSH Access to Target
**Deployment:**
```bash
# Provision the full Defense Stack
ansible-playbook -i inventory.ini site.yml -l defense
# Surgical Deployment: Observability Only
ansible-playbook -i inventory.ini site.yml -l defense --tags observability
# Provision Red Team Platform
ansible-playbook -i inventory.ini site.yml -l attack_platform
```

## 6. Verification

After the playbook completes, verify services are active:
```bash

# Check Docker Container Status on Defense Node
ssh titanadmin@192.168.1.240 "sudo docker ps"

# Expected Output:
# - traefik (0.0.0.0:80->80/tcp)
# - grafana (0.0.0.0:3000->3000/tcp)
# - prometheus (0.0.0.0:9090->9090/tcp)
# - wazuh.manager / wazuh.indexer
# - linuxserver/sonarr
```
## 7. License

MIT License - Copyright (c) 2025 Titan Architecture

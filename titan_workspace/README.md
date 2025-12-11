# Titan Infrastructure

## 1. Operational Overview
**Titan Infrastructure** is the Infrastructure-as-Code (IaC) repository for the **Titan Core** environment. It facilitates the transition from fragile, GUI-dependent proprietary systems to a headless, reproducible Ubuntu architecture.

The primary objective is **Disaster Recovery (DR) reduction**: Rebuilding the entire media and application stack takes <10 minutes via Ansible, compared to hours of manual configuration.

## 2. Architecture & Stack
* **Infrastructure:** Synology VMM (Hypervisor) hosting Ubuntu Server 22.04 LTS.
* **Provisioning:** Ansible (Modular Roles).
* **Orchestration:** Docker Compose v2 (Microservices).
* **Security:** ED25519 SSH Keys, UFW (Default Deny), Fail2Ban.

## 3. Project Structure
The repository utilizes a modular role-based architecture:

```text
.
├── inventory.ini       # Host definitions (Titan Core)
├── site.yml            # Main playbook entry point
└── roles/
    ├── common/         # Base packages (vim, git, curl, htop)
    ├── security/       # Hardening (UFW Firewall, Fail2Ban, SSH Config)
    └── docker/         # Docker Engine & Repository Management
```
## 4. Security Hardening
A "Zero Trust" baseline is enforced on the node via the security role:
* SSH: Password authentication disabled. Access restricted to cryptographic keys only.
* Firewall: UFW configured with a "Default Deny" ingress policy.
    * Allowed: Port 22 (SSH), 8989 (Sonarr), 7878 (Radarr), 8085 (SABnzbd).
* Intrusion Prevention: Fail2Ban active on SSH logs to ban IPs after 3 failed auth attempts.

## 5. Usage
**Prerequisites:**
* Ansible (sudo apt install ansible)
* SSH Access to Target
**Deployment:**
```bash
# Provision the full stack (Common -> Security -> Docker)
ansible-playbook -i inventory.ini site.yml --ask-become-pass
```
## 6. Verification

After the playbook completes, verify your containers are active:
```bash

# Check Docker Container Status
sudo docker ps

# Expected Output:
# - linuxserver/sonarr
# - linuxserver/radarr
# - linuxserver/sabnzbd
```
## 7. License

MIT License - Copyright (c) 2025 Titan Architecture

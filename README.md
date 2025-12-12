# Titan Infrastructure

## 1. Operational Overview
**Titan Infrastructure** is the Infrastructure-as-Code (IaC) repository for the **Titan Cyber Range**. It facilitates the transition from fragile, GUI-dependent proprietary systems to a headless, reproducible Ubuntu architecture.

The primary objective is **Disaster Recovery (DR) reduction**: Rebuilding the entire media, proxy, and application stack takes <10 minutes via Ansible, compared to hours of manual configuration.

## 2. Architecture & Stack
* **Infrastructure:** Synology VMM (Hypervisor) hosting Ubuntu Server 22.04 LTS (Defense) and Kali Linux (Attack).
* **Provisioning:** Ansible (Modular Roles).
* **Orchestration:** Docker Compose v2 (Microservices).
* **Traffic Control:** Traefik v2.11 (Edge Router & Reverse Proxy).
* **Security:** ED25519 SSH Keys, UFW (Default Deny), Fail2Ban.

## 3. Project Structure
The repository utilizes a modular role-based architecture segmented by function:

```text
.
├── inventory.ini       # Host definitions (Defense Node vs. Attack Platform)
├── site.yml            # Main playbook entry point
└── roles/
    ├── common/         # Base packages (vim, git, curl, htop)
    ├── security/       # Hardening (UFW Firewall, Fail2Ban, SSH Config)
    ├── docker/         # Docker Engine & Network Bridge (media_net)
    ├── media/          # Application Stack (Sonarr, Radarr, SABnzbd)
    ├── proxy/          # Traefik Edge Router configuration
    └── attack_base/    # Red Team provisioning (Kali Linux tools)
```
## 4. Security Hardening
* A "Zero Trust" baseline is enforced via the security role:
* SSH: Password authentication disabled. Access restricted to cryptographic keys only.
* Firewall: UFW configured with a "Default Deny" ingress policy.
    * Allowed (Edge): Ports 80 (HTTP), 443 (HTTPS), 8080 (Traefik Dashboard).
    * Allowed (Direct): Port 8085 (SABnzbd - Direct Access).
* Intrusion Prevention: Fail2Ban active on SSH logs to ban IPs after 3 failed auth attempts.

## 5. Usage
**Prerequisites:**
* Ansible (sudo apt install ansible)
* SSH Access to Target
**Deployment:**
```bash
# Provision the full stack (Common -> Security -> Docker)
ansible-playbook -i inventory.ini site.yml -l defense
ansible-playbook -i inventory.ini site.yml -l attack_platform
```

## 6. Verification

After the playbook completes, verify your containers are active:
```bash

# Check Docker Container Status
ssh titanadmin@192.168.1.240 "sudo docker ps"

# Expected Output:
# - traefik (0.0.0.0:80->80/tcp, 0.0.0.0:8080->8080/tcp)
# - linuxserver/sonarr
# - linuxserver/radarr
# - linuxserver/sabnzbd (0.0.0.0:8085->8080/tcp)
```
## 7. License

MIT License - Copyright (c) 2025 Titan Architecture

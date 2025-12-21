# Titan Infrastructure

**Status:** ACTIVE
**Phase:** 5 (Hardening & Optimization)
**Method:** Ansible (IaC) + Docker Compose
**Hypervisor:** Synology VMM

## 1. Operational Overview
**Titan Infrastructure** is the Infrastructure-as-Code (IaC) repository for the **Titan Cyber Range**. It facilitates the transition from fragile, GUI-dependent proprietary systems to a headless, reproducible Ubuntu architecture.

The primary objective is **Operational Efficiency**: The stack has been optimized to perform strictly within IOPS constraints, utilizing lightweight database structures (GVM/Postgres) while hardening the ingress layer via Traefik.

## 2. Architecture & Stack
* **Infrastructure:** Synology VMM (Hypervisor) hosting Ubuntu Server 22.04 LTS (Defense) and Kali Linux (Attack).
* **Provisioning:** Ansible (Modular Roles) + Ansible Vault (AES256 Encryption).
* **Orchestration:** Docker Compose v2 (Microservices).
* **Traffic Control:** Traefik v2.11 (Edge Router & Reverse Proxy).
* **Observability:** Prometheus (Metrics), Grafana (Viz), Node Exporter (Telemetry).
* **Security Data:** GVM Postgres (Vulnerability Data), Suricata (NIDS), UFW (Default Deny).
* **Legacy/Decommissioned:** Wazuh SIEM (Deprecated due to storage IOPS constraints).

## 3. Project Structure
The repository utilizes a modular role-based architecture segmented by function, with strict separation of configuration and credentials:

~~~text
.
├── inventory.ini           # Host definitions
├── group_vars/
│   └── defense.yml         # Encrypted Secrets (Ansible Vault)
├── site.yml                # Main playbook entry point
└── roles/
    ├── common/             # Base packages (vim, git, curl, htop)
    ├── security/           # Hardening (GVM DB, Suricata, UFW)
    ├── docker/             # Docker Engine & Network Bridges
    ├── media/              # Application Stack (Sonarr, Radarr)
    ├── proxy/              # Traefik Edge Router configuration
    ├── observability/      # Monitoring Stack (Prometheus, Grafana)
    └── attack_base/        # Red Team provisioning (Kali Linux tools)
~~~

## 4. Security & Governance
* **Secret Management:** All credentials (API keys, DB passwords) are encrypted at rest using **Ansible Vault (AES256)**. No plaintext secrets exist in the repo.
* **Zero Trust:** SSH Password auth disabled. Access via Ed25519 keys only.
* **Firewall:** UFW "Default Deny" ingress policy.
  * Allowed (Edge): 80/443 (Traefik).
  * Allowed (Internal): 3000 (Grafana), 9090 (Prometheus).
* **Resource Governance:**
  * Strict `shm_size` and JIT compilation tuning applied to Postgres containers.
  * Heavy IOPS loads (ElasticStack) successfully decoupled from the storage layer.

## 5. Usage
**Prerequisites:**
* Ansible (`sudo apt install ansible`)
* SSH Access to Target

**Deployment (Vault Password Required):**
Since credentials are encrypted, you must provide the Vault password during execution.

~~~bash
# Provision the full Defense Stack
ansible-playbook -i inventory.ini site.yml -l defense --ask-vault-pass

# Surgical Deployment: Security Databases Only
ansible-playbook -i inventory.ini site.yml -l defense --tags security --ask-vault-pass

# Provision Red Team Platform
ansible-playbook -i inventory.ini site.yml -l attack_platform --ask-vault-pass
~~~

## 6. Verification
After the playbook completes, verify services are active:

~~~bash
# Check Docker Container Status on Defense Node
ssh titanadmin@192.168.1.240 "sudo docker ps"

# Expected Output:
# - traefik (0.0.0.0:80->80/tcp)
# - grafana (0.0.0.0:3000->3000/tcp)
# - gvm-postgres (Internal Vault Net)
# - prometheus (0.0.0.0:9090->9090/tcp)
~~~

## 7. License
MIT License - Copyright (c) 2025 Titan Architecture

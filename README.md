# Titan Infrastructure

**Status:** ACTIVE
**Phase:** 6 (Control Node Integration & CI/CD)
**Method:** Ansible (IaC) + Docker Compose + GitHub Actions
**Targets:** Ubuntu Server (Defense), Kali Linux (Attack), Fedora (Control Node)

## 1. Operational Overview
**Titan Infrastructure** is an Infrastructure-as-Code (IaC) ecosystem designed to provision, harden, and manage the **Titan Cyber Range**. It has evolved from a single-server stack into a distributed management platform capable of automating both the **Reactor Core** (Server) and the **Control Node** (Workstation).

The system utilizes **Structural Honesty** to enforce security at the edge via Traefik and internal persistence via systemd offloading.

## 2. Architecture & Stack
* **Infrastructure:** Synology VMM (Hypervisor) for servers; Fedora Linux for the Control Node.
* **Provisioning:** Ansible (Modular Roles) + Ansible Vault (AES256).
* **CI/CD:** GitHub Actions for YAML linting and automated logic validation.
* **Observability:** Prometheus, Grafana, and Node Exporter (IaC Provisioned).
* **Security:** GVM (Postgres), Suricata (NIDS), UFW (Default Deny), and NIC-Offload persistence.

## 3. Project Structure
The repository is segmented by function, separating node-specific logic from global infrastructure roles:

~~~text
.
├── .github/workflows/      # CI/CD Pipelines (YAML Validation)
├── docs/                   # Operational SOPs & Red Team AARs
├── scripts/                # V3 Backup & Exfiltration logic
├── host_vars/              # Node-specific overrides (Laptop/Server/NAS)
├── group_vars/
│   ├── all.yml             # Encrypted Global Secrets
│   └── defense.yml         # Server-specific Encrypted Secrets
├── roles/
│   ├── workstation_core/   # Control Node (Laptop) automation
│   ├── network_core/       # VLAN & Interface logic
│   ├── common/             # Base packages (vim, git, htop)
│   ├── security/           # Hardening (GVM, Suricata, NIC Offload)
│   ├── observability/      # Grafana Provisioning & Telemetry
│   ├── predator_response/  # Active Defense protocols
│   └── attack_base/        # Red Team provisioning (Kali tools)
└── site.yml                # Main entry point
~~~

## 4. Security & Governance
* **Secret Management:** 100% of credentials are encrypted at rest via **Ansible Vault**.
* **Zero Trust:** SSH Password auth disabled; Traefik Ingress enforced via `prom-auth`.
* **CI/CD Integrity:** GitHub Actions must pass before logic is merged to `main`.

## 5. Usage
**Provisioning the Control Node (Local Laptop):**
~~~bash
ansible-playbook -i inventory.ini site.yml -l workstation --ask-vault-pass
~~~

**Provisioning the Defense Stack (Server):**
~~~bash
ansible-playbook -i inventory.ini site.yml -l defense --ask-vault-pass
~~~

## 6. License
MIT License - Copyright (c) 2025 Titan Architecture

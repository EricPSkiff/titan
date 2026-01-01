# Titan Infrastructure

**Status:** ACTIVE
**Phase:** 7.5 (Full Stack Integration & Observability Remediation)
**Method:** Ansible (IaC) + Libvirt + Firewalld + GitHub Actions
**Architectural Goal:** Sacrifice efficiency to ensure the Daughter's successful launch.

## 1. Operational Overview
**Titan Infrastructure** serves as the "Master Source of Truth" for a hardened, distributed cyber environment. This ecosystem automates the lifecycle of two distinct operational tiers:
1.  **The Reactor Core:** A high-availability defense stack hosted on Synology VMM.
2.  **The Control Node:** A local Fedora-based hypervisor utilized for "Thunderdome" (Attack/Isolation) operations.

## 2. Global Architecture & Security Stack
The project enforces **Structural Honesty** through deep-tier isolation and automated hardening:
* **Infrastructure:** Distributed compute across Synology VMM and Local KVM/Libvirt.
* **Airlock Security:** Software-defined "Kill Zone" (`172.16.99.0/24`) for offensive operations, physically segregated from the Family LAN via Firewalld Rich Rules.
* **Secret Governance:** 100% of credentials (Traefik, DBs, Internal IPs) are encrypted via **Ansible Vault (AES256)** within `group_vars/all.yml` and `defense.yml`.
* **CI/CD Pipeline:** GitHub Actions automate YAML linting and logic validation on every push to `main`.
* **Observability:** Traefik-managed ingress with Uptime Kuma and Gotify alerting.

## 3. Project Structure (Expansive)
The repository is segmented into modular roles to allow for node-specific or global provisioning:

~~~text
.
├── .github/workflows/      # Automated CI/CD (YAML/Ansible Linting)
├── docs/                   # Sanitized Network Maps & Red Team AARs
├── group_vars/             # Encrypted Global and Stack-specific secrets
├── host_vars/              # Target-specific overrides (e.g., kali_node, titan-core-01)
├── playbooks/              # High-level logic validation
├── scripts/                # V3 Backup & Cold Storage exfiltration logic
├── roles/                  # Functional Modules
│   ├── workstation_core/   # Local Fedora Control Node Hardening
│   ├── control_node/       # Thunderdome Bridge & Libvirt Provisioning
│   ├── security/           # NIC Offload persistence & NIDS Deployment
│   ├── observability/      # Grafana/Prometheus IaC Provisioning
│   ├── attack_base/        # Kali Linux Red Team Toolset
│   └── proxy/              # Traefik Ingress & Middleware
└── site.yml                # Main Orchestration Entry Point
~~~

## 4. Phase-Specific Status
| Phase | Focus | Status |
| :--- | :--- | :--- |
| **5** | Hardening & Optimization | **COMPLETE** |
| **6** | Control Node & CI/CD | **STABLE** |
| **7** | Thunderdome Network Isolation | **ACTIVE** |
| **8** | Observability Remediation | **IN-PROGRESS** |

## 5. Deployment Protocols
**Provisioning the Entire Range:**
~~~bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
~~~

**Targeting the Control Node (Workstation):**
~~~bash
ansible-playbook -i inventory.ini site.yml -l workstation --ask-vault-pass
~~~

## 6. Known Issues & Remediation
* **Docker API Mismatch:** Forced `DOCKER_API_VERSION=1.45` in proxy configs to maintain compatibility with modern engines.
* **HSTS Redirection:** SSL currently managed via manual HTTP overrides; `mkcert` hardening is the next operational objective.

## 7. License
MIT License - Copyright (c) 2025-2026 Titan Architecture

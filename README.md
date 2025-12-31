# Titan Infrastructure

**Status:** ACTIVE
**Phase:** 7 (Network Isolation & Thunderdome Deployment)
**Method:** Ansible (IaC) + Libvirt + Firewalld
**Target Node:** Control Node (Hypervisor - Fedora)

## 1. Operational Overview
**Titan Infrastructure** is the Master Source of Truth for the Titan Cyber Range. This ecosystem has transitioned into a hybrid management platform, automating the **Reactor Core** (Synology VMM) and the **Control Node** (Local Hypervisor). 

Phase 7 successfully established the **Thunderdome Bridge**, an isolated software-defined network for offensive operations.

## 2. Architecture & Stack
* **Infrastructure:** Synology VMM (Defense) + Fedora Libvirt/KVM (Control/Attack).
* **Network Isolation:** Thunderdome Bridge (`virbr1`) operating at `172.16.99.0/24`.
* **Security:** Firewalld "Airlock" Rich Rules enforcing a total DROP policy between Thunderdome and the Family LAN.
* **DNS Strategy:** Decommissioned local BIND; hardwired to Cloudflare (1.1.1.1) to resolve Port 53 contention.

## 3. Project Structure
~~~text
.
├── .github/workflows/      # CI/CD Validation
├── roles/
│   ├── control_node/       # Hypervisor & Security Bridge logic
│   │   ├── templates/      # Jinja2 XML for Thunderdome
│   │   └── handlers/       # Firewalld state management
│   ├── workstation_core/   # Local environment automation
│   └── security/           # Server-side NIDS & Hardening
├── docs/                   # Red Team After-Action Reports (AAR)
└── site.yml                # Entry point
~~~

## 4. Security Perimeter (The Airlock)
The system enforces a strict isolation policy:
* **Source:** `172.16.99.0/24` (Thunderdome)
* **Destination:** `192.168.1.0/24` (Family LAN)
* **Action:** `DROP`

## 5. Usage
**Deploy Isolated Network Infrastructure:**
~~~bash
ansible-playbook -i inventory.ini site.yml -l workstation --tags network --ask-vault-pass
~~~

## 6. License
MIT License - Copyright (c) 2025 Titan Architecture

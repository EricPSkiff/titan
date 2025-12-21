# Titan Infrastructure Topology (Sanitized)

## 1. Core Switching (Layer 2/3)
| Device | IP Address | Function | Status |
| :--- | :--- | :--- | :--- |
| **[GATEWAY_NODE]** | `[MGMT_SUBNET].1` | Firewall / VLAN Controller | [ACTIVE] |
| **[CORE_SWITCH]** | `[MGMT_SUBNET].2` | Backbone Infrastructure | [ACTIVE] |
| **[WAP_01]** | `[MGMT_SUBNET].3` | Wireless Access Point | [ACTIVE] |

## 2. Server Infrastructure (VLAN 10 - MGMT)
| Hostname | IP Address | OS | Services |
| :--- | :--- | :--- | :--- |
| **titan-core-01** | `[MGMT_SUBNET].240` | Linux Server (LTS) | Docker / Ansible Control |
| **titan-storage** | `[MGMT_SUBNET].200` | NAS / SAN | ISCSI / Storage Targets |

## 3. Client Segments (VLAN 20 - USER)
* **DHCP Range:** `[USER_SUBNET].100 - .200`
* **Security:** Restricted access to MGMT VLAN via State-Aware Firewall Rules.

## 4. Security Zone (VLAN 30 - DMZ)
* **Status:** STRICT. No outbound WAN access allowed without Proxy.

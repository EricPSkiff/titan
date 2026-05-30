# Titan Node Audit

**Date:** 2026-05-30
**Scope:** Ansible IaC for the managed nodes — `titan-core-01` (defense) and
`kali-node-01` (attack platform) — plus shared roles, inventory, CI, and the
backup script.
**Method:** Static review of the tracked repository contents (`ansible` is not
installed in the audit environment, so `--syntax-check`/`ansible-lint` were not
run here; findings below are confirmed by direct file inspection).

---

## Summary

| # | Severity | Finding |
|---|----------|---------|
| 1 | **High** | CI lints `workstation.yml`, which does not exist in the repo — the lint job will error/fail |
| 2 | Medium | `host_key_checking = False` in `ansible.cfg` disables SSH host-key verification (MITM exposure) |
| 3 | Low | `roles/minecraft` is wired into `site.yml` but its `tasks/main.yml` is empty — a no-op role |
| 4 | Low | Suricata NIC-offload step hardcodes interface `ens3` and is non-persistent (admitted in a comment) |
| 5 | Low | `roles/common` frees port 80 via `shell: fuser -k 80/tcp` with `ignore_errors` — non-idempotent |
| 6 | Info | `deprecation_warnings = False` in `ansible.cfg` suppresses upgrade signals |
| 7 | Info | `scripts/backup_volumes.sh` writes unencrypted archives and takes stacks offline during backup |

**Good practices observed (no action needed):**
- `group_vars/all.yml` and `group_vars/defense.yml` are AES256 `$ANSIBLE_VAULT`
  encrypted; `.vault_pass` is **not** tracked in git.
- `predator_response` is gated behind the `never` tag and a target-defined safety
  check, so it only runs on explicit invocation.
- Network isolation is enforced (Thunderdome `172.16.99.0/24` blocked from the
  family LAN via a firewalld rich rule).

---

## Findings

### 1. High — CI lints a non-existent playbook (`workstation.yml`)
`.github/workflows/lint.yml` runs:

```yaml
ansible-lint --force-color site.yml workstation.yml roles/
```

There is no `workstation.yml` at the repo root (only `site.yml`). `ansible-lint`
treats an unreadable path as an error, so the lint job fails on every push/PR to
`main`. The git history (`fix(ci): Add workstation.yml to lint scope`) shows the
path was added to the lint command, but the playbook itself was never committed.

**Remediation (one of):**
- Create the intended `workstation.yml` play (running `workstation_core` against
  a workstation host), **or**
- Drop `workstation.yml` from the lint command if workstation provisioning is
  meant to run via `site.yml -l workstation`.

*(This is a design choice; see the open question at the end.)*

### 2. Medium — SSH host-key checking disabled
`ansible.cfg` sets `host_key_checking = False`. Convenient for ephemeral lab
hosts, but it removes protection against SSH MITM on the control path to the
defense node.

**Remediation:** enable host-key checking and manage `known_hosts`, or scope the
override to the Thunderdome lab inventory only.

### 3. Low — `minecraft` role is a no-op
`site.yml` includes `roles/minecraft` (tags `utility`, `tribe`), but
`roles/minecraft/tasks/main.yml` contains only a comment — no tasks. The role
ships a `templates/docker-compose.yml.j2` that is never deployed, so the
Minecraft stack is silently not provisioned.

**Remediation:** implement the deploy tasks (template + `docker_compose_v2`) or
remove the role from the play until it is ready.

### 4. Low — Suricata NIC offload is hardcoded and non-persistent
`roles/suricata_nids/tasks/main.yml` runs `ethtool -K ens3 rx off tx off` with
`changed_when: false`. The interface name `ens3` is hardcoded (breaks on hosts
with different NIC names) and a comment notes it is not persistent across
reboots.

**Remediation:** derive the interface from facts
(`ansible_default_ipv4.interface`) and persist the setting (systemd unit or
`/etc/network` hook).

### 5. Low — Non-idempotent port-80 cleanup
`roles/common/tasks/main.yml` uses `shell: "fuser -k 80/tcp || true"` with
`ignore_errors: yes` to free port 80. This always reports changed, kills
arbitrary processes, and will draw an `ansible-lint` `command-instead-of-shell`
/ idempotency warning.

**Remediation:** rely on the explicit `apache2`/`nginx` removal already present,
or guard the kill with a `register`/`when` check.

### 6. Info — Deprecation warnings suppressed
`deprecation_warnings = False` hides signals about modules/syntax slated for
removal, making future Ansible upgrades riskier.

### 7. Info — Backup script hardening
`scripts/backup_volumes.sh` correctly quiesces stacks (`docker compose down`)
before archiving and restarts them afterward, but the resulting `.tar.gz`
(containing Docker secrets) is written unencrypted to `/mnt/backups`, and the
stacks are offline for the duration of the backup.

**Remediation:** encrypt archives at rest (`gpg`/`age`); consider per-volume
snapshots to shorten/avoid the downtime window.

---

## Suggested remediation order
1. Resolve the `workstation.yml` CI reference (#1) so the lint gate is green.
2. Decide on host-key checking policy (#2).
3. Complete or remove the `minecraft` role (#3); de-hardcode the Suricata NIC
   (#4); tidy the port-80 task (#5).
4. Address the informational items (#6, #7) as convenient.

## Open question for the operator
For #1, should `workstation.yml` be **created** (a dedicated workstation play) or
**removed** from the lint scope (workstation handled via `site.yml -l
workstation`)? The fix differs depending on intent.

*This audit reports only; no infrastructure code was modified.*

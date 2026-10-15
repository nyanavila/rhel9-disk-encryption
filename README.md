# Enterprise RHEL 9 Hard Drive Encryption Automation

This repository provides production-ready Ansible playbooks, Kickstart templates, and operational scripts to deploy, manage, and convert Red Hat Enterprise Linux 9 physical servers and virtual machines to LUKS2 full-disk encryption.

## Architecture Highlights
- **Physical Hosts (Bare-Metal):** Automated boot unlocking via discrete/firmware **TPM 2.0** chips (`clevis-pin-tpm2`) sealed against PCR 0 (firmware) and PCR 7 (Secure Boot).
- **Virtual Machines:** Automated boot unlocking via **Network-Bound Disk Encryption (NBDE)** connecting to a high-availability Tang server cluster using static IP early-boot networking.
- **In-Place Migration:** Offline conversion of existing LVM volumes using `cryptsetup reencrypt --resilience journal`.
- **Key Escrow & Recovery:** Administrative break-glass passphrases (Keyslot 0) and binary LUKS headers backed up to HashiCorp Vault.
- **Kdump Reliability:** Dynamic crashkernel reservation adjustments ensuring crash dumps succeed on encrypted storage.

## Execution Order
1. Run preflight checks and verify bare-metal backups:
   `ansible-playbook playbooks/00_preflight_and_backup_check.yml`
2. Deploy Tang NBDE servers (if supporting VMs without vTPM):
   `ansible-playbook playbooks/01_deploy_tang_cluster.yml`
3. Configure physical bare-metal systems with TPM 2.0:
   `ansible-playbook playbooks/02_configure_physical_tpm2.yml`
4. Configure virtual machines with static IP early-boot Tang bindings:
   `ansible-playbook playbooks/03_configure_vm_tang_static_ip.yml`
5. Convert existing unencrypted volumes during an approved maintenance window:
   `ansible-playbook playbooks/04_inplace_reencrypt_lvm.yml`
6. Enforce kdump memory budgets:
   `ansible-playbook playbooks/05_configure_kdump_memory.yml`

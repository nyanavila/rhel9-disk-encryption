# RHEL 9 Unattended Installation with LUKS2 & TPM 2.0 Binding
text
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
timezone America/New_York --utc

zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=600
part /boot --fstype=xfs --size=1024
part pv.01 --size=10000 --grow --encrypted --luks-version=luks2 --cipher=aes-xts-plain64 --passphrase=TemporarySetupKey123!

volgroup vg00 pv.01
logvol / --vgname=vg00 --size=20480 --name=lv_root --fstype=xfs
logvol swap --vgname=vg00 --size=4096 --name=lv_swap --fstype=swap

%packages
@^minimal-environment
clevis-luks
clevis-dracut
tpm2-tools
kexec-tools
%end

%addon com_redhat_kdump --enable --reserve-mb=652
%end

%post --erroronfail
clevis luks bind -y -k - -d /dev/nvme0n1p3 tpm2 '{"pcr_bank":"sha256","pcr_ids":"0,7"}' <<< "TemporarySetupKey123!"
cryptsetup luksRemoveKey /dev/nvme0n1p3 <<< "TemporarySetupKey123!"

dracut -fv --regenerate-all
%end

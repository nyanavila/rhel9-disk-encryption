# RHEL 9 VM Installation with Unique Master Key and Static IP Tang Binding
text
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
timezone UTC

network --bootproto=static --ip=192.0.2.51 --netmask=255.255.255.0 --gateway=192.0.2.1 --nameserver=192.0.2.100 --device=ens3 --activate

zerombr
clearpart --all --initlabel
part /boot --fstype=xfs --size=1024
part pv.01 --size=10000 --grow --encrypted --luks-version=luks2 --cipher=aes-xts-plain64 --passphrase=VMTempSetupKey123!

volgroup rhel pv.01
logvol / --vgname=rhel --size=15360 --name=root --fstype=xfs
logvol swap --vgname=rhel --size=2048 --name=swap --fstype=swap

%packages
@^minimal-environment
clevis-luks
clevis-dracut
%end

%addon com_redhat_kdump --enable --reserve-mb=652
%end

%post --erroronfail
cat << 'DRAC_EOF' > /etc/dracut.conf.d/static_ip.conf
kernel_cmdline="ip=192.0.2.51::192.0.2.1:255.255.255.0:rhel-vm01:ens3:none nameserver=192.0.2.100 rd.neednet=1"
hostonly_cmdline="yes"
DRAC_EOF

clevis luks bind -y -k - -d /dev/vda2 sss '{"t":1,"pins":{"tang":[{"url":"http://192.0.2.20:7500"},{"url":"http://192.0.2.21:7500"}]}}' <<< "VMTempSetupKey123!"
cryptsetup luksRemoveKey /dev/vda2 <<< "VMTempSetupKey123!"

dracut -fv --regenerate-all
%end

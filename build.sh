#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Add Repos
dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-kernel/repo/fedora-41/lukenukem-asus-kernel-fedora-41.repo
dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-linux/repo/fedora-41/lukenukem-asus-linux-fedora-41.repo

# Install Kernel
KERNEL_VERSION=`dnf5 list --showduplicates kernel --quiet | grep "x86_64" | grep rog | awk '{print $2}'`
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs ; 
  do rpm --erase $pkg --nodeps ; 
done
rm -r /root

dnf5 -y install --allowerasing \
  kernel-$KERNEL_VERSION \
  kernel-core-$KERNEL_VERSION \
  kernel-devel-$KERNEL_VERSION \
  kernel-devel-matched-$KERNEL_VERSION \
  kernel-modules-$KERNEL_VERSION \
  kernel-modules-core-$KERNEL_VERSION \
  kernel-modules-extra-$KERNEL_VERSION \
  kernel-tools-$KERNEL_VERSION \
  kernel-tools-libs-$KERNEL_VERSION \
  kernel-uki-virt-$KERNEL_VERSION \
  kernel-uki-virt-addons-$KERNEL_VERSION \
  asusctl \
  asusctl-rog-gui

# Install GPU Switcher
curl -o gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip https://extensions.gnome.org/extension-data/gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
gnome-extensions install ./gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
rm gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip

QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

chmod 0600 /lib/modules/$QUALIFIED_KERNEL/initramfs.img
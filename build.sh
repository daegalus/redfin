#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Add Repos
dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-kernel/repo/fedora-41/lukenukem-asus-kernel-fedora-41.repo
dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-linux/repo/fedora-41/lukenukem-asus-linux-fedora-41.repo

# Install Kernel
KERNEL_VERSION=dnf list --showduplicates kernel --quiet | grep "x86_64" | grep rog | awk '{print $2}'
dnf5 -y remove kernel* && rm -r /root
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
  asusctl \
  supergfxctl \
  xone-kmod-common \
  v4l2loopback \
  virtualbox-guest-additions

# If SUFFIX contains "nvidia", install Nvidia Drivers
if [[ $SUFFIX == *"nvidia"* ]]; then
  dnf5 -y install --allowerasing \
    nvidia-driver \
    nvidia-driver-cuda \
    nvidia-settings \
    nvidia-kmod-common \
    kmod-nvidia
fi

# Install GPU Switcher
curl -o gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip https://extensions.gnome.org/extension-data/gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
gnome-extensions install ./gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
rm gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip

# Refresh Drivers (primarily Nvidia) for new Kernel
sudo akmods
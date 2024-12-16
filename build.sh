#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Add Repos
dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-kernel/repo/fedora-41/lukenukem-asus-kernel-fedora-41.repo
dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-linux/repo/fedora-41/lukenukem-asus-linux-fedora-41.repo

# Install Kernel
dnf5 -y remove kernel* && rm -r /root
dnf5 dnf5 -y install --allowerasing kernel asusctl supergfxctl

# Install GPU Switcher
curl -o gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip https://extensions.gnome.org/extension-data/gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
gnome-extensions install ./gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
rm gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip

# Refresh Drivers (primarily Nvidia) for new Kernel
sudo akmods
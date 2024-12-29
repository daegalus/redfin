#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Add Repos
dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-kernel/repo/fedora-41/lukenukem-asus-kernel-fedora-41.repo
dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-linux/repo/fedora-41/lukenukem-asus-linux-fedora-41.repo

# Install Kernel
KERNEL_VERSION=`dnf5 list --showduplicates kernel --quiet | grep "x86_64" | grep rog | awk '{print $2}'`
# for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs ; 
#   do rpm --erase $pkg --nodeps ; 
# done

# Replace kernel with rpm-ostree
rpm-ostree override replace \
    --experimental \
        /tmp/kernel-rpms/kernel-[0-9]*.rpm \
        /tmp/kernel-rpms/kernel-core-*.rpm \
        /tmp/kernel-rpms/kernel-modules-*.rpm \
        /tmp/kernel-rpms/kernel-tools-*.rpm \
        /tmp/kernel-rpms/kernel-devel-*.rpm \
        /tmp/kernel-rpms/kernel-uki-virt-*.rpm

sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

rpm-ostree install \
    /tmp/akmods-rpms/kmods/*kvmfr*.rpm \
    /tmp/akmods-rpms/kmods/*xone*.rpm \
    /tmp/akmods-rpms/kmods/*openrazer*.rpm \
    /tmp/akmods-rpms/kmods/*v4l2loopback*.rpm \
    /tmp/akmods-rpms/kmods/*wl*.rpm \
    /tmp/akmods-rpms/kmods/*framework-laptop*.rpm \
    /tmp/akmods-extra-rpms/kmods/*gcadapter_oc*.rpm \
    /tmp/akmods-extra-rpms/kmods/*nct6687*.rpm \
    /tmp/akmods-extra-rpms/kmods/*zenergy*.rpm \
    /tmp/akmods-extra-rpms/kmods/*vhba*.rpm \
    /tmp/akmods-extra-rpms/kmods/*gpd-fan*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ayaneo-platform*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ayn-platform*.rpm \
    /tmp/akmods-extra-rpms/kmods/*bmi260*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ryzen-smu*.rpm \
    /tmp/akmods-extra-rpms/kmods/*evdi*.rpm

rpm-ostree insall \
    /tmp/akmods-nvidia-open/*nvidia*.rpm

# rpm-ostree override remove \
#   kernel \
#   kernel-core \
#   kernel-modules \
#   kernel-modules-core \
#   kernel-modules-extra \
#   kernel-tools \
#   kernel-tools-libs \
#   kernel-devel-matched \
#   kernel-devel \
#   kmod-framework-laptop \
#   --install kernel-$KERNEL_VERSION \
#   --install kernel-core-$KERNEL_VERSION \
#   --install kernel-devel-$KERNEL_VERSION \
#   --install kernel-devel-matched-$KERNEL_VERSION \
#   --install kernel-modules-$KERNEL_VERSION \
#   --install kernel-modules-core-$KERNEL_VERSION \
#   --install kernel-modules-extra-$KERNEL_VERSION \
#   --install kernel-tools-$KERNEL_VERSION \
#   --install kernel-tools-libs-$KERNEL_VERSION \
#   --install kernel-uki-virt-$KERNEL_VERSION \
#   --install kernel-uki-virt-addons-$KERNEL_VERSION

dnf5 -y install --allowerasing \
  asusctl \
  asusctl-rog-gui
  # kernel-$KERNEL_VERSION \
  # kernel-core-$KERNEL_VERSION \
  # kernel-devel-$KERNEL_VERSION \
  # kernel-devel-matched-$KERNEL_VERSION \
  # kernel-modules-$KERNEL_VERSION \
  # kernel-modules-core-$KERNEL_VERSION \
  # kernel-modules-extra-$KERNEL_VERSION \
  # kernel-tools-$KERNEL_VERSION \
  # kernel-tools-libs-$KERNEL_VERSION \
  # kernel-uki-virt-$KERNEL_VERSION \
  # kernel-uki-virt-addons-$KERNEL_VERSION \

# Install Firmware
git clone https://gitlab.com/asus-linux/firmware.git --depth 1 /tmp/asus-firmware
cp -rf /tmp/asus-firmware/* /usr/lib/firmware/
rm -rf /tmp/asus-firmware

# Install GPU Switcher
curl -o gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip https://extensions.gnome.org/extension-data/gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
gnome-extensions install ./gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
rm gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip

QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+)' | grep 'rog' | sed -E 's/kernel-//')"
/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

chmod 0600 /lib/modules/$QUALIFIED_KERNEL/initramfs.img
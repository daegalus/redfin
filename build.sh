#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# Add Repos
# dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-kernel/repo/fedora-41/lukenukem-asus-kernel-fedora-41.repo
# dnf5 config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/lukenukem/asus-linux/repo/fedora-41/lukenukem-asus-linux-fedora-41.repo
dnf5 -y copr enable lukenukem/asus-kernel
dnf5 -y copr enable lukenukem/asus-linux
dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable ublue-os/akmods
dnf5 -y copr enable rok/cdemu

RPM_FUSION=(
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
)

dnf5 install -y "${RPM_FUSION[@]}"

skopeo copy docker://ghcr.io/ublue-os/asus-kernel:"${RELEASE}" dir:/tmp/kernel-rpms
KERNEL_TARGZ=$(jq -r '.layers[].digest' < /tmp/kernel-rpms/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/kernel-rpms/"$KERNEL_TARGZ" -C /
mv /tmp/rpms/* /tmp/kernel-rpms/

skopeo copy docker://ghcr.io/ublue-os/akmods:asus-"${RELEASE}" dir:/tmp/akmods-rpms
AKMODS_TARGZ=$(jq -r '.layers[].digest' < /tmp/akmods-rpms/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods-rpms/"$AKMODS_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods-rpms/

skopeo copy docker://ghcr.io/ublue-os/akmods-extra:asus-"${RELEASE}" dir:/tmp/akmods-extra-rpms
AKMODS_EXTRA_TARGZ=$(jq -r '.layers[].digest' < /tmp/akmods-extra-rpms/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods-extra-rpms/"$AKMODS_EXTRA_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods-extra-rpms/

if [[ $SUFFIX == *"nvidia"* ]]; then
  skopeo copy docker://ghcr.io/ublue-os/akmods-nvidia-open:asus-"${RELEASE}" dir:/tmp/akmods-nvidia-open-rpms
  AKMODS_NVIDIA_OPEN_TARGZ=$(jq -r '.layers[].digest' < /tmp/akmods-nvidia-open-rpms/manifest.json | cut -d : -f 2)
  tar -xvzf /tmp/akmods-nvidia-open-rpms/"$AKMODS_NVIDIA_OPEN_TARGZ" -C /tmp/
  mv /tmp/rpms/* /tmp/akmods-nvidia-open-rpms/

  rpm --erase kmod-nvidia --nodeps ; 
fi

# Install Kernel
KERNEL_VERSION=$(dnf5 list --showduplicates kernel --quiet | grep "x86_64" | grep rog | awk '{print $2}')
for pkg in kmod-kvmfr kmod-openrazer kmod-v4l2loopback kmod-xone kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-devel kernel-devel-matched; 
  do rpm --erase $pkg --nodeps ; 
done

# Replace kernel with rpm-ostree
rpm-ostree override replace \
    --experimental \
        /tmp/kernel-rpms/kernel-[0-9]*.rpm \
        /tmp/kernel-rpms/kernel-core-*.rpm \
        /tmp/kernel-rpms/kernel-modules-*.rpm \
        /tmp/kernel-rpms/kernel-devel-*.rpm \
        /tmp/kernel-rpms/kernel-uki-virt-*.rpm

rpm-ostree override replace --experimental \
    /tmp/akmods-rpms/kmods/*kvmfr*.rpm \
    /tmp/akmods-rpms/kmods/*xone*.rpm \
    /tmp/akmods-rpms/kmods/*openrazer*.rpm \
    /tmp/akmods-rpms/kmods/*v4l2loopback*.rpm \
    /tmp/akmods-rpms/kmods/*wl*.rpm \
    /tmp/akmods-extra-rpms/kmods/*gcadapter_oc*.rpm \
    /tmp/akmods-extra-rpms/kmods/*nct6687*.rpm \
    /tmp/akmods-extra-rpms/kmods/*vhba*.rpm \
    /tmp/akmods-extra-rpms/kmods/*bmi260*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ryzen-smu*.rpm
    #/tmp/akmods-extra-rpms/kmods/*evdi*.rpm
    #/tmp/akmods-extra-rpms/kmods/*zenergy*.rpm \

if [[ $SUFFIX == *"nvidia"* ]]; then
  rpm-ostree override replace --experimental \
    /tmp/akmods-nvidia-open-rpms/kmods/*nvidia*.rpm
fi


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

QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+)' | grep 'rog' | sed -E 's/kernel-//')"
/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

chmod 0600 /lib/modules/$QUALIFIED_KERNEL/initramfs.img

dnf5 -y copr disable lukenukem/asus-kernel
dnf5 -y copr disable lukenukem/asus-linux
dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable ublue-os/akmods
dnf5 -y copr disable rok/cdemu
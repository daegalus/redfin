#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

case "${IMAGE}" in
"bazzite"*|"bluefin"*)
    base_image="silverblue"
    ;;
"aurora"*)
    base_image="kinoite"
    ;;
"cosmic"*)
    base_image="${BASE_IMAGE}"
    ;;
"ucore"*)
    base_image="${BASE_IMAGE}"
    ;;
esac

image_flavor="main"
image_suffix="${SUFFIX:-}"

if [[ "$IMAGE" =~ dx ]]; then
    image_flavor="dx"
    #image_suffix="-dx"
fi
if [[ "$IMAGE" =~ nvidia ]]; then
    image_flavor="nvidia"
    #image_suffix="-nvidia"
fi

# Branding
cat <<<"$(jq ".\"image-name\" |= \"redfin${image_suffix}\" |
              .\"image-flavor\" |= \"${image_flavor}\" |
              .\"image-vendor\" |= \"daegalus\" |
              .\"image-ref\" |= \"ostree-image-signed:docker://ghcr.io/daegalus/redfin${image_suffix}\" |
              .\"image-tag\" |= \"${IMAGE}${BETA:-}\" |
              .\"base-image-name\" |= \"${base_image}\" |
              .\"fedora-version\" |= \"$(rpm -E %fedora)\"" \
    </usr/share/ublue-os/image-info.json)" \
>/tmp/image-info.json
cp /tmp/image-info.json /usr/share/ublue-os/image-info.json
compile:
    #!/usr/bin/env bash
    podman run --pull=newer --interactive --rm quay.io/coreos/butane:release \
       --pretty --strict < config.bu > config_template.ign

    source .env
    envsubst < config_template.ign > config.ign

coreos-installer disk: compile
    sudo podman run --pull=newer --privileged --rm \
        -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data \
        quay.io/coreos/coreos-installer:release \
        install -a aarch64 -s stable -i config.ign --append-karg nomodeset {{ disk }}

# https://docs.fedoraproject.org/en-US/fedora-coreos/provisioning-raspberry-pi4/
efi-workaround disk:
    #!/usr/bin/env bash
    sudo dnf5 install -y --downloadonly --forcearch=aarch64 --setopt=destdir=/tmp/RPi4boot/ uboot-images-armv8 bcm283x-firmware bcm283x-overlays
    for rpm in /tmp/RPi4boot/*rpm; do rpm2cpio $rpm | sudo cpio -idv -D /tmp/RPi4boot/; done
    sudo mv /tmp/RPi4boot/usr/share/uboot/rpi_arm64/u-boot.bin /tmp/RPi4boot/boot/efi/rpi-u-boot.bin

    FCOS_EFI_PARTITION=$(/usr/bin/lsblk {{ disk }} -J -oLABEL,PATH  | jq -r '.blockdevices[] | select(.label == "EFI-SYSTEM").path')
    sudo rm -rf /tmp/FCOSEFIpart
    mkdir /tmp/FCOSEFIpart
    sudo mount $FCOS_EFI_PARTITION /tmp/FCOSEFIpart
    sudo rsync -avh --ignore-existing /tmp/RPi4boot/boot/efi/ /tmp/FCOSEFIpart/
    sudo umount $FCOS_EFI_PARTITION

full-repro disk:
    just coreos-installer {{ disk }}
    just efi-workaround {{ disk }}
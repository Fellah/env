#!/bin/bash

set -e

## update the system clock
timedatectl set-ntp true

## partition the disk
parted /dev/sda <<EOF
mklabel gpt
mkpart ESP fat32 1MiB 513MiB
set 1 boot on
mkpart primary ext4 513MiB 100%
quit
EOF

## format the partitions
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

## mount the file systems
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

## install the base packages
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt hwclock --systohc

arch-chroot /mnt mkinitcpio -p linux

# passwd
arch-chroot /mnt passwd <<EOF
root
root
EOF

## config UEFI boot
arch-chroot /mnt bootctl install

PARTUUID=$(blkid -s PARTUUID -o value /dev/sda2)
cat <<EOF > /mnt/boot/loader/loader.conf
default  arch
timeout  4
editor  0
EOF

cat <<EOF > /mnt/boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$PARTUUID rw
EOF

## config network
cat <<EOF > /mnt/etc/netctl/nat
Description='VirtualBox NAT'
Interface=enp0s3
Connection=ethernet
IP=dhcp
EOF

cat <<EOF > /mnt/etc/netctl/host-only
Description='VirtualBox Host-Only'
Interface=enp0s8
Connection=ethernet
IP=static
Address='192.168.56.101/24'
Gateway='192.168.56.1'
EOF

arch-chroot /mnt netctl enable nat
arch-chroot /mnt netctl enable host-only
arch-chroot /mnt netctl start nat
arch-chroot /mnt netctl start host-only

pacstrap /mnt openssh

install --directory --mode=700 /mnt/root/.ssh
cat <<EOF > /mnt/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGaZuQwbB39E+55YRalyxu9ZkWsz7UkXFUatR+MNjBoqwGTl7y52PsnbtJJwH7n3nkj3EtxohX7w8UbGFfT+q5o0d7k8z4kTtKpyu2zzToydHnkScmn3EShOwCEcnzZFcen+tN8vWvgsmF5H4j/Ala4+p4QU5UpoqxYQbtiG8FFTS6t52XX4rGGvFSwWrDUC1aXiwLveRmZVR++kF4wRED42MYfmlLueqWgVYGylz7vkcAqIUBRlUt3piZ6hKwy4Ty5FxBB0/7F7dBzDvOFs/qVZ4QqR9zct4tAtHS9lSPChWQ2hf3RhcITMsdTuh4XV2RwGrsaUzmCqeH9Ui0os6x Fellah
EOF

arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt systemctl start sshd

umount /mnt/boot /mnt

poweroff

# Arch Installation on a T460s

## first boot & prepare ssh access

Change the keyboard layout to German:

`loadkeys de-latin1`

Change the root password in order to connect via ssh:

`passwd`

Connect to Wi-Fi:

`wifi-menu`

Start the ssh server:

`systemctl start sshd.service`

## connect via ssh

Sync clock or something:

`timedatectl set-ntp true`

The following commands wipe the disk and create the required labels. It creates a 512mb partition for the EFI bootloader and uses the remaining available space for root & user. A swap file will be created later on.
```
fdisk /dev/sda
g
n,enter,enter,+512M,
n,enter,enter,enter
t,1,1, (EFI)
t,2,24, (Linux Filesystem x86-64 root)
w
```

## LUKS Encryption
The following commands encrypt the system and mount the newly encrypted partition.
```
cryptsetup -y -v luksFormat /dev/sda2
cryptsetup open /dev/sda2 cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
```
Prepare and mount the boot partition:
```
mkfs.fat -F32 /dev/sda1
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```
The following command downloads and installs Arch Linux, the Linux kernel and vim (vim can be replaced by any editor, nano for example).

`pacstrap /mnt base base-devel linux linux-firmware vim`

Create the fstab file:

`genfstab -U /mnt >> /mnt/etc/fstab`

You can now chroot into the installed system.

`arch-chroot /mnt`

## Configure the bootloader for encrypted partitions

Install the bootloader:

`bootctl install`

Add the following HOOKS=(base **udev** autodetect **keyboard** **keymap** consolefont modconf block **encrypt** filesystems fsck) to:

`vim /etc/mkinitcpio.conf`

Configure the boot loader:

```
cd /boot/loader
vim loader.conf
```
Replace entries with:
```
timeout 3
default arch
```
Create a new entry for Arch:
```
cd entries
vim arch.conf
```
Add the following lines. Use `:r !blkid` in VIM to find the correct UUID for dev/sda2 (or the encrypted partition)
```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options rw cryptdevice=UUID=xyz:cryptroot root=/dev/mapper/cryptroot
```
Then ceate the ramdisk with:

`mkinitcpio -p linux`

## Further setup
Create and mount a swapfile:
```
fallocate -l 8GB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
vim /etc/fstab
```
Add `/swapfile none swap defaults 0 0` at the end.

Set the correct timezone:
```
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
```
Set the correct locale:
```
vim /etc/locale.gen
(uncomment en_US.UTF-8)
locale-gen
vim /etc/locale.conf
(LANG=en_US.UTF-8)
vim /etc/vconsole.conf
(KEYMAP=de-latin1)
```
Set hostname:
```
vim /etc/hostname
(T460s)
vim /etc/hosts
(127.0.0.1	localhost)
(::1		localhost)
(127.0.1.1	T460s.localdomain	T460s)
```
Set the root password again:

`passwd`

Install the network manager and some other useful tools:

`pacman -S efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant mtools dosfstools linux-headers`

`exit`

```
umount -a
reboot
```

## User creation and Desktop Environment installation

Make sure that the network manager is active and starts on boot from now on. Use nmtui to connect to Wi-Fi.
You can install openssh. Start it with systemctl start sshd.
```
systemctl start NetworkManager
nmtui
systemctl enable NetworkManager
```
Create a user and give root privileges:
```
useradd -m -G wheel lars
passwd lars
EDITOR=vim visudo
(uncomment %wheel ALL=(ALL) ALL)
```
Install Intel video drivers:

`pacman -S xf86-video-intel xorg`

Install a display server:

`pacman -S xorg`

Install a desktop environment:

`pacman -S xfce4 xfce4-goodies`
# Arch Installation on a T460s

## first boot

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
Format the partitions:
```
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
```
Mount them:
```
mount /dev/sda2 /mnt
mkdir /mnt/boot
mkdir /mnt/boot/EFI
mount /dev/sda1 /mnt/boot/EFI
```
The following command downloads and installs Arch Linux, the Linux kernel and vim (vim can be replaced by any editor, nano for example).

`pacstrap /mnt base base-devel linux linux-firmware vim`

Create the fstab file:

`genfstab -U /mnt >> /mnt/etc/fstab`

## chroot into the installed system

`arch-chroot /mnt`

Create and mount a swapfile:
```
fallocate -l 8GB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
vim /etc/fstab
(add "/swapfile none swap defaults 0 0" at the end)
```
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

Install the bootloader, network manager and some other useful tools:

`pacman -S grub efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant os-prober mtools dosfstools linux-headers`

Configure grub:
```
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

`exit`

```
umount -a
reboot
```

## reboot and set up

Make sure that the network manager is active and starts on boot from now on. Use nmtui to connect to Wi-Fi.
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
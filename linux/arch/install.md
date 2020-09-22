### install

#### base config

```bash
timedate set-ntp true
timedate set-timezone Asia/Shanghai
timedate status

# config time zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc [--utc]

# localization
# en_US.UTF-8 zh_CN.UTF-8
vim /etc/locale.gen
sed -ri 's/#(en_US.UTF-8|zh_CN.UTF-8)(.*)$/\1\2/' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

# network configuration
echo "arch" > /etc/hostname

cat <<EOF >> /etc/hosts
127.0.0.1	localhost
::1			localhost
EOF

# LVM 支持
modprobe dm-mod
vgscan
vgchange -ay

# systemd based initramfs
vim /etc/mkinitcpio.conf
MODULES=(dm-raid raid0 raid1 raid10 raid456)
HOOKS=(dm-mod base systemd  udev autodetect modconf block lvm2 filesystems keyboard fsck)

mkinitcpio -P
```

#### system install

安装的软件列表 [packages.x86_64](https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/configs/releng/packages.x86_64)
参考 [blog](https://blog.csdn.net/r8l8q8/article/details/76516523)

```bash
# 系统分区
mkdir -p /mnt/boot/efi /mnt/home
# efi 分区格式化
mkfs.fat -F32 /dev/sda1

pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# 切换系统配置，配置时区，locale,network
arch-chroot /mnt

# network software
pacman -S net-tools networkmanager bind-tools
systemctl enable NetworkManager
# wifi
pacman -S netctl iw wpa_supplicant dialog

# 系统 grub 引导 (intel-ucode os-prober)
pacman -S efibootmgr grub dosfstools
# 建立引导
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=-ArchLinux
grub-mkconfig -o /boot/grub/grub.cfg

# 安装软件
pacman -S sudo vim

# 创建用户
useradd -m luck
passwd luck
# /etc/sudouser
luck	ALL=(ALL:)	NOPASSWD:	ALL

# 推出，解挂分区
exit
umount -R /mnt

桌面:
pacman -S xorg xorg-apps xorg-server xorg-xinit
pacman -S plasma (plasma-desktop)

KDE:
pacman -S kde-applications sddm (精简 kdebase)
systemctl endable sddm

GNOME:
pacman -S gnome gnome-tweak-tool gnome-shell gdm
systemctl endable gdm

# 字体:
pacman -S wqy-microhei wqy-microhei-lite adobe-noto-fonts-cjk

用户目录生成:
pacman -S xdg-user-dirs
```


```
在当前用户目录下建立 “.xinitrc” 这个文件(注意文件名前有一个点号，代表建立的是一个隐藏文件)，文件的内容就一行 startkde 或 gnome-session，根据自己的需要选择 KDE 或 GNOME。可以用这个命令建 .initrc 文件，默认启用 gnome

echo "gnome-session" >> ~/.xinitrc
默认启用kde

echo "exec startkde" >> ~/.xinitrc
然后启动对应的图形界面

startx
```
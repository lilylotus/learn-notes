## 安装


## 配置
1. 安装包
```
pacstrap /mnt base base-devel linux

arch-chroot /mnt
hwclock --systohc
pacman -S vim intel-ucode os-prober efibootmgr grub

建立引导:
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=-ArchLinux
grub-mkconfig -o /boot/grub/grub.cfg


桌面:
pacman -S xorg xorg-apps xorg-server xorg-xinit
pacman -S plasma (plasma-desktop)

KDE:
pacman -S kde-applications sddm (精简 kdebase)
systemctl endable sddm

GNOME:
pacman -S gnome gnome-tweak-tool gnome-shell gdm
systemctl endable gdm

通用软件:
pacman -S net-tools networkmanager plasma-nm
systemctl enable NetworkManager

字体:
pacman -S wqy-microhei wqy-microhei-lite adobe-noto-fonts-cjk

用户目录生成:
pacman -S xdg-user-dirs
```


```
在当前用户目录下建立“.xinitrc”这个文件(注意文件名前有一个点号，代表建立的是一个隐藏文件)，文件的内容就一行startkde或gnome-session，根据自己的需要选择KDE或GNOME。

可以用这个命令建.initrc文件

默认启用gnome

 echo "gnome-session" >> ~/.xinitrc
 默认启用kde

echo "exec startkde" >> ~/.xinitrc
 然后启动对应的图形界面

startx
```
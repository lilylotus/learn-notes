桌面优化

```shell
Theme:
Sweeet

Plasma Style:
Maia Transparent

Application Style:

Color:
Adapta Nokto

Icons:
McMojave-circle-dark
papirus

Wedigt:

Dock:
Plank / Latte Dock

software:
sudo pacman -Syu neofetch screenfetch

media:
mpv
spotify/clementine

terminal:
zsh/Oh my zsh/powerline
file:
----------------------------------
light theme configuration:

theme : breeze
plamsa stype : Helium (*)/Maia Transparent
window decorations : Yosemite Transparent / Breezemite (*)
icons : La Capitaine/ McMojave-circle (*)
```



##### zsh / powerline 安装

```shell
zsh:
sudo pacman -S --noconfirm zsh
chsh -s /usr/bin/zsh

on-my-zsh :
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

powerline:
sudo pacman -S --noconfirm powerline
sudo pacman -S --noconfirm powerline-fonts
sudo pacman -S --noconfirm powerline-vim

config:
bash : .bashrc
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/lib/python3.8/site-packages/powerline/bindings/bash/powerline.sh

zsh : .zshrc
powerline-daemon -q
. /usr/lib/python3.8/site-packages/powerline/bindings/zsh/powerline.zsh

vim : vim .vimrc
let g:powerline_pycmd="py3"
set laststatus=2
set t_Co=256
syntax on
```

##### 主题安装

```bash
theme : /usr/share/themes | /home/.local/share/themes
icons : /usr/share/icons
background : /usr/share/backgrounds

mkdir {themes,fonts,icons}
```

##### 字体

```
sudo pacman -S --noconfirm wqy-microhei wqy-zenhei
sudo pacman -S --noconfirm noto-fonts-cjk
sudo pacman -S --noconfirm ttf-meslo

sudo pacman -S --noconfirm wqy-microhei
sudo pacman -S --noconfirm wqy-microhei-lite
sudo pacman -S --noconfirm wqy-bitmapfont
sudo pacman -S --noconfirm wqy-zenhei
sudo pacman -S --noconfirm ttf-arphic-ukai
sudo pacman -S --noconfirm ttf-arphic-uming
sudo pacman -S --noconfirm adobe-source-han-sans-cn-fonts
sudo pacman -S --noconfirm adobe-source-han-serif-cn-fonts

复制 windows 字体，放在 /usr/share/fonts 目录下
```

##### 常用软件

```bash
sudo pacman -S --noconfirm remmina
sudo pacman -S --noconfirm google-chrome
sudo pacman -S --noconfirm dbeaver
sudo pacman -S wps-office
sudo pacman -S virtualbox
sudo pacman -S uget
sudo pacman -S --noconfirm okular gimp mpv 
```

##### 安装 windows 字体

```bash
windows 字体路径： C:\Windows\Fonts 打包
linux 字体路径：/usr/share/font/windows

建立字体索引信息，更新字体缓存
sudo mkfontscale
sudo mkfontdir
fc-cache -fv

--------------
中文字体推荐使用：文泉驿、思源字体。安装如下：
sudo pacman -S wqy-microhei wqy-bitmapfont wqy-zenhei wqy-microhei-lite
sudo pacman -S adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts

西文字体推荐使用dejavu、noto字体。
sudo pacman -S ttf-dejavu
sudo pacman -S noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk

-----------------
配置字体
在使用 winfonts 之后，电脑默认中文字体编程宋体，并不是很好看，我们把它转变成文泉驿正黑

mkdir ~/.config/fontconfig
vim ~/.config/fontconfig/fonts.conf

<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>

  <alias>
    <family>sans-serif</family>
    <prefer>
	  <family>WenQuanYi Micro Hei</family>
	  <family>WenQuanYi Zen Hei</family>
	  <family>WenQuanYi Zen Hei Sharp</family>
    </prefer>
  </alias>

  <alias>
    <family>serif</family>
    <prefer>
      <family>WenQuanYi Micro Hei Lite</family>
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
	  <family>WenQuanYi Micro Hei Mono</family>
	  <family>WenQuanYi Zen Hei Mono</family>
    </prefer>
  </alias>

</fontconfig>
```


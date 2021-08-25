## 安装后配置

### 换快速源

```bash
sudo pacman-mirrors -i -c China -m rank

# 手动添加，不建议使用 archlinuxcn 的源，因为并不一定兼容
sudo vim /etc/pacman.conf

[archlinuxcn]
Server = http://mirrors.163.com/archlinux-cn/$arch

# 更新系统
sudo pacman -Syyu
```

### 安装软件

yay 是一个用 Go 语言写的一个 AUR 助手，有些时候官方仓库没有你想要的软件，就需要通过 yay 来安装，有了 yay，以后就不用 sudo pacman 了。

```bash
sudo pacman -S yay
```

#### 安装拼音输入法

安装 fcitx5

```bash
sudo pacman -S fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool
```

然后配置 fcitx5 的环境变量，在 ~/.xprofile 写入

```
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS="@im=fcitx5"

export LANG="zh_CN.UTF-8"
export LC_CTYPE="zh_CN.UTF-8"
```

在 archlinux 下，安装 rime

```
sudo pacman -S fcitx5-rime
```

安装输入方案，fcitx5 - ~/.local/share/fcitx5/rime

无法安装，下载 [rime](https://github.com/fkxxyz/rime-cloverpinyin/releases) 解压到用户资料夹。如：clover.schema-1.1.0.zip

```bash
yay -S rime-cloverpinyin

# 在用户资料夹下创建 default.custom.yaml ，内容为
patch:
  "menu/page_size": 8
  schema_list:
    - schema: clover
```

写好该文件之后，点击右下角托盘图标右键菜单，点“重新部署”，然后再点右键，在方案列表里面应该就有“ 🍀️四叶草拼音输入法”的选项了。

配置主题：

```bash
yay -S fcitx5-material-color

# ~/.config/fcitx5/conf/classicui.conf
# 垂直候选列表
Vertical Candidate List=False
## 按屏幕 DPI 使用
PerScreenDPI=True
## Font (设置成你喜欢的字体)
Font="思源黑体 CN Medium 13"
## 主题
Theme=Material-Color-Pink

# 单行模式 (inline preedit)
# fcitx5-rime -> ~/.config/fcitx5/conf/rime.conf
# 可用时在应用程序中显示预编辑文本
PreeditInApplication=True
```

[rime 主题配置链接](https://github.com/hosxy/Fcitx5-Material-Color)

```bash
# 安装 fcitx5（输入法框架）
yay -S fcitx5-im

# 配置 fcitx5 的环境变量
vim ~/.pam_environment
## 内容为：
GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE  DEFAULT=fcitx
XMODIFIERS    DEFAULT=\@im=fcitx
SDL_IM_MODULE DEFAULT=fcitx

# 安装 fcitx5-rime（输入法引擎）
yay -S fcitx5-rime
# 安装 rime-cloverpinyin（输入方案）
yay -S base-devel
yay -S rime-cloverpinyin

# 创建并写入 rime-cloverpinyin 的输入方案
vim ~/.local/share/fcitx5/rime/default.custom.yaml
## 内容
patch:
  "menu/page_size": 5
  schema_list:
    - schema: clover
    
# 注销后配置
fcitx5-configtool 
```

[rime 输入法参考链接](https://github.com/fkxxyz/rime-cloverpinyin/wiki/linux)

## 显卡驱动安装

[安装参考链接地址](https://zhuanlan.zhihu.com/p/372587633)

### 自动检测和安装显卡驱动

检测和安装显卡驱动程序的推荐方法。自动安装方法的命令语法为：

```bash
sudo mhwd -a [pci或usb连接] [开源或闭源驱动程序] 0300

# 自动检测和安装pci连接显卡的最佳可用闭源驱动程序
sudo mhwd -a pci nonfree 0300

# 自动检测和安装用于pci连接显卡的最佳开源驱动程序
sudo mhwd -a pci free 0300
```

- **-a**：自动检测并安装适当的驱动程序
- **[pci或usb]**：为通过pci内部连接或通过usb外部连接的设备安装适当的驱动程序（同样，mhwd当前在其开发阶段仅支持pci连接）
- **[开源或闭源]**：安装开源驱动程序（例如，Linux 社区提供）或闭源驱动程序（例如，硬件制造商提供，尤其英伟达显卡）
- **0300**：代表安装显卡驱动程序（0300是显卡的代号，随着mhwd命令的发展，新的代号将用于其他硬件）

### 手动检测和安装显卡驱动

识别可用的显卡驱动程序，在手动安装显卡驱动程序之前，有必要确定哪些驱动程序可用于你的系统

```bash
mhwd -l [可选：详细视图] [可选：-pci或--usb连接]


# 获取所有已安装驱动程序的列表 [过滤 pci]
mhwd -l -d [--pci]
```

使用不带附加选项的此命令将列出连接到系统的设备的所有可用驱动程序的基本信息。

**驱动程序中，显卡驱动程序的名称都带有前缀（video-）**。

列出的驱动程序提供以下信息：

- 驱动名称
- 版本号
- 开源或闭源
- PCI或USB连接

**安装显卡驱动程序**

手动安装显卡驱动程序，命令语法是：

```bash
sudo mhwd -i pci [驱动程序名称]

# 安装专有的英伟达显卡驱动程序
sudo mhwd -i pci video-nvidia
```

- **-i**：安装驱动程序
- [pci]：为通过pci内部连接的设备（例如图形卡）安装驱动程序
- [驱动程序名称]：要安装的驱动程序名称



## 软件安装

#### 截屏软件

```bash
sudo pacman -S flameshot

$ flameshot gui
```

### 文本编辑

markdown 文本编辑

```text
# markdown
sudo pacman -S typora
```
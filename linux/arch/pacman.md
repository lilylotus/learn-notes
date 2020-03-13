##### 更新国内最快的软件源

```bash
1. pacman-mirrors 更新官方软件源,按照地区自动更新为最快最稳定的软件源镜像地址
sudo pacman-mirrors --country China
sudo pacman-mirrors -i -c China -m rank

/etc/pacman.conf
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch

2. 恢复默认软件源
sudo pacman-mirrors --interactive --default
3. 软件源更新后，系统更新
sudo pacman -Syyu
4. 查看所有可用地区信息
sudo pacman-mirrors -l

# pacman 软件管理
2.1 同步并且更新你的系统
sudo pacman -Syyu
2.2 软件仓库中搜索软件
sudo pacman -Ss [software package name]
2.3 查看已经安装的软件
sudo pacman -Qs [software package name]
sudo pacman -Qi [software package name] # 附带详细信息
sudo pacman -Qii [software package name] # 附带更加详细的包信息
sudo pacman -Ql # 列出所有安装的软件包

2.4 查看软件详细依赖
sudo pactree [software]
2.5 查看系统没有使用的软件依赖包
sudo pacman -Qdt
2.6 移除系统没有使用的软件依赖包
sudo pacman -Rs $(pacman -Qdtq)

3.1 下载安装软件
sudo pacman -Syu [software]
sudo pacman -U [software] # 更新

4.1 卸载软件
sudo pacman -R [software]
sudo pacman -Rs [software] # 同时删除依赖
sudo pacman -Rns [software] # 删除软件及其依赖，还有pacman生成的配置文件，即更彻底的删除

5.1 清空缓存
sudo pacman -Sc
sudo pacman -scc # 更彻底清理
```

###### 安装中文输入法

```bash
sudo pacman -Syu archlinuxcn-keyring
sudo pacman -S fcitx-rime
sudo pacman -S fcitx-im
sudo pacman -S fcitx-configtool

sudo vim ~/.xprofile
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"


sudo pacman -S visual-studio-code-bin
```


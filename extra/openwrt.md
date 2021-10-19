### OpenClash

[git 地址](https://github.com/vernesong/OpenClash/releases)

安装包列表

```bash
opkg update

opkg install coreutils-nohup bash iptables curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun

opkg install luci-app-openclash_0.43.07-beta_all.ipk

# 界面问题
opkg install luci luci-base luci-compat
```

### v2ray

[GIT 地址](https://github.com/kuoruan/openwrt-v2ray/releases)

[操作界面](https://github.com/kuoruan/luci-app-v2ray/releases)

[参考安装配置](http://www.freefacebookfan.com/p/2020519194918_3477_2648138093/home)

```bash
opkg install v2ray-core_4.42.2-1_x86_64.ipk
opkg install luci-app-v2ray_1.5.6_all.ipk

# 中文界面
opkg install luci-i18n-v2ray-zh-cn_git-20.120.34447-9737546_all.ipk
```

[v2ray 配置](https://www.v2ray.com/chapter_02/01_overview.html)

## **Shadowsocks**

[安装配置](https://linhongbo.com/posts/shadowsocks-on-openwrt/)

```bash
wget http://openwrt-dist.sourceforge.net/packages/openwrt-dist.pub
opkg-key add openwrt-dist.pub

vim /etc/opkg/customfeeds.conf
src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/x86_64
src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci

opkg update
opkg install shadowsocks-libev
opkg install luci-app-shadowsocks
opkg install luci-app-shadowsocks-libev

opkg install ChinaDNS luci-app-chinadns
wget https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt -O /tmp/china_ip_list.txt && mv /tmp/china_ip_list.txt /etc/chinadns_chnroute.txt

echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
sysctl -p
```

[ipk 下载网址](https://share.mianao.info/Router/X86-64/SSR-plus/)

[软件包下载](https://github.com/kenzok8/openwrt-packages)

[自编译 openwrt](https://github.com/Lienol/openwrt)

[安装 passwall](https://mianao.info/2020/05/05/%E7%BC%96%E8%AF%91%E6%9B%B4%E6%96%B0OpenWrt-PassWall%E5%92%8CSSR-plus%E6%8F%92%E4%BB%B6)
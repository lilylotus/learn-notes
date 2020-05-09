> WAP / WPA2 WiFi 密码加密协议。
> WEP 现在淘汰了。



可用网站：

> https://www.aircrack-ng.org/
> https://github.com/aircrack-ng/rtl8812au
> https://duckduckgo.com/
> 	->  reaver google code
> https://tools.kali.org/wireless-attacks/reaver

#### 1. 无线网络简介

Access Points (AP)，每个 AP 每秒发送约 10 个所谓的信标帧。这些数据包包含以下信息：

- Name of the network (ESSID)
- If encryption is used (and what encryption is used; pay attention, that may not be always true just because the AP advertises it)
- What MBit data rates are supported
- Which channel the network is on

每个AP都有一个唯一的MAC地址（48位，6对十六进制数字）。每个网络硬件设备都有一个这样的地址，并且网络设备通过使用此MAC地址相互通信。因此，它基本上就像一个唯一的名称。 MAC地址是唯一的，世界上没有两个网络设备具有相同的MAC地址。

##### 1.1 连接网络

如果要连接到无线网络，则有一些可能性。在大多数情况下，使用开放系统身份验证。

1. Ask the AP for authentication.
2. The AP answers: OK, you are authenticated.
3. Ask the AP for association
4. The AP answers: OK, you are now connected.

这是最简单的情况，但是如果您不合法连接，可能会出现一些问题：

- WPA/WPA2 is in use, you need EAPOL authentication. The AP will deny you at step 2.
- Access Point has a list of allowed clients (MAC addresses), and it lets no one else connect. This is called MAC filtering.
- Access Point uses Shared Key Authentication, you need to supply the correct WEP key to be able to connect. (See the [How to do shared key fake authentication? tutorial](https://www.aircrack-ng.org/doku.php?id=shared_key) for advanced techniques.)

#### 2. aircrack-ng

##### 2.1 安装

```bash
yum install aircrack-ng
```

##### 2.2 使用

```bash
ifconfig # 显示网络配置
# 关闭网卡
ifconfig wlp2s0 down / airmon-ng check kill
# 配置无线网卡为监听模式
iwconfig wlan0 mode monitor
# 启用网卡
ifconfig wlp2s0 up

airmon-ng start wlan0
airodump-ng wlan0mon # 监控
aireplay-ng --test wlan0 # Injection

airodump-ng -c 11 --bssid 00:01:02:03:04:05 -w dump wlan0mon # 连接
aireplay-ng --fakeauth 0 -e "your network ESSID" -a 00:01:02:03:04:05 wlan0mon # 干扰

aircrack-ng -w word_list dump.cap # 破解密码
crunch -t %%%%Thunder 1234567890 | aircrack-ng -w crack.cap -e BSSID
```



#### 3. reaver - (WAP)


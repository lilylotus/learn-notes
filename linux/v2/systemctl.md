### systemd
systemd 中每一個系統服務就稱為一個服務單位（unit），
而服務單位又可以區分為 service、socket、target、path、snapshot、timer 等多種不同的類型（type），
我們可以從設定檔的附檔名來判斷該服務單位所屬的類型，最常見的就是以 .service 結尾的系統服務，大部分的伺服器都是屬於這種。

### 开机自启 和 检查状态
```bash
# systemctl enable nginx    # 设定开启自启 nginx
# systemctl disable nginx   # 取消开启自启 nginx

# systemctl is-active nginx     # nginx 是否正在运行
# systemctl is-enabled nginx    # nginx 是否开机自启
# systemctl is-failed nginx     # nginx 是否启动失败

SHELL 指令
is_act=`systemctl is-active nginx.service`
if [ "$is_act" == "active" ]; then
    echo "Nginx is active."
else
    echo "Nginx is not active."
fi

```

### 列出服务
| 列出所有已经启动的服务
`systemctl list-units | systemctl`
| 欄位 | 說明 |
| :--: | :--: |
| UNIT | Systemd 服務單位（unit）名稱。|
| LOAD | 該服務單位設定檔是否有被 Systemd 載入至記憶體中。 |
| ACTIVE | 是否已經正常啟動。 |
| SUB | 更詳細的狀態說明，值會因為不同服務有所不同。|
| DESCRIPTION | 關於此服務的簡單說明。|

```bash
systemctl list-units --all      # 列出所有的服务,包括未启动的
systemctl list-units --all --state=inactive # 列出所有未启动的服务
systemctl list-units --type=service    # 仅列出类型为 Service 的服务
```

### 查看服务内部状态与设定
```bash
# systemctl cat sshd.service         # 查看服务内部设定
# systemctl list-dependencies sshd   # 查看指定服务的依赖关系
# systemctl show sshd                # 查看指定服务的底层设定值
```

### 屏蔽服务 服務被遮蔽之後，就會無法啟動
`屏蔽: systemctl mask nginx | 取消: systemctl unmask nginx`
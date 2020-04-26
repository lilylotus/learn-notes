## iptables 使用

#### netfilter 和 iptables

Netfilter: 是 Linux 操作系统核心层内部的一个数据包处理模块
Hook Point : 数据包在 Netfilter 的挂载点 (PRE_ROUTING, INPUT, OUTPUT, FORWARD, POST_ROUTING)

#### iptables 的规则组成

四张表 + 五条链 (每一条链可以放到具体的表里面)

> 四张表: filter, net, mangle, raw
> 五条链: INPUT, OUTPUT, FORWARD, PREROUTING, POSTROUTING
> 组成: 
>    数据包的访问控制: ACCEPT, DROP (不会有返回信息), REJECT (会有拒绝的返回信息)
>    数据包改写: SNAT (对发起目标的地址改写), DNAT (对目的目标的地址改写)
>    信息记录: LOG

![iptables](./iptables.png "iptables command")

`-m [tcp, state, multiport]`

`--sport`

`--dport`

`--dports`



**常用参数:**

`-n, --numeric: 不以主机名显示,显示地址和端口`

`-F, --flush [chain]: 删除此链中的所有规则`

`-L, --list [chain [rulenum]]: 列出链或者所以链中的规则`

**注意:** 连用仅能使用 `iptables -nL` 不能 `iptables -Ln`

> 默认 table 为 filter

```
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 10:21 -j ACCEPT

iptables -I INPUT -p icmp -j ACCEPT
```



**SNAT 和 DNAT 的使用示例, nat 表**

**注意:**  /etc/sysctl.conf 要配置 *net.ipv4.ip_forward=1*  -->  *sysctl -p*

1. SNAT

   ```bash
   iptables -t nat -A POSTROUTING -s 172.18.0.0/16 -j SNAT --to 172.20.0.2 (多张网卡的堡垒机)
   a (18.0.2)  ---  bastion (18.0.3, 20.0.3) --- b (20.0.2)  [ b -> a ]
   在客户机添加 
   ip route add 0.0.0.0 via 172.18.0.3
   ip route add default via 172.18.0.3
   ```

2. DNAT

   ```
   iptables -t nat -A PREROUTING -d 172.18.0.3 -p tcp --dport 80 -j DNAT --to 172.20.0.2:80
   ```

3. 完整示例
```bash
控制 ssh 的访问, A(138), B(131), C(132)
target: (C)
    iptabels -t filter -A INPUT -s 10.10.37.138 -p tcp -m tcp --dport 22 -j REJECT

forward: (B)
    iptables -t nat -A PREROUTING -s 10.10.37.138 -p tcp -dport 4000 --to-destination 10.10.37.132:22
    iptables -t nat -A POSTROUTING -s 10.10.37.138 --to-source 10.10.37.131

```

---

#### iptables command in Linux with Examples

* *Tables* is the name for a set of chains.
* *Chain* is a collection of rules.
* *Rule* is condition used to match packet.
* *Target* is action taken when a possible rule matches. Examples of the target are ACCEPT, DROP, QUEUE.
* *Policy* is the default action taken in case of no match with the inbuilt chains and can be ACCEPT or DROP.

**Syntax**

```
iptables --table TABLE -A/-C/-D ... CHAIN rule --jump target
```

​                                                                    **TABLE**

There are five possible tables:

- **filter:** Default used table for packet filtering. It includes chains like INPUT, OUTPUT and FORWARD.
- **nat :** Related to Network Address Translation. It includes PREROUTING and POSTROUTING chains.
- **mangle :** For specialised packet alteration. Inbuilt chains include PREROUTING and OUTPUT.
- **raw :** Configures exemptions from connection tracking. Built-in chains are PREROUTING and OUTPUT.
- **security :** Used for [Mandatory Access Control](https://en.wikipedia.org/wiki/Mandatory_access_control)

​                                                              **CHAINS**

There are few built-in chains that are included in tables. They are:

- **INPUT :**set of rules for packets destined to localhost sockets.
- **FORWARD :**for packets routed through the device.
- **OUTPUT :**for locally generated packets, meant to be transmitted outside.
- **PREROUTING :**for modifying packets as they arrive.
- **POSTROUTING :**for modifying packets as they are leaving.



**target** ACCEPT, DROP, REJECT, DNAT, SNAT



​                                                               **OPTIONS**

**Common:**  `iptables -L --line-number`

1. **-A, -append:** Append to the chain provided in parameters.

   **syntax:**

   `iptables [-t table] --append [chain] [parameters]`

   **Example:** This command drops all the traffic comming any port.

   `iptables -t filter --append INPUT -j DROP`

2. **-D, --delete:** Delete rule from the specified chain.

   **Syntax:**

   `iptables [-t table] --delete [chain] [rule_number]`

   **Example:** This command deletes the rule 2 from INPUT chain.

   `iptables -t filter --delete INPUT 2`

3. **-C, --check:** Check if a rule is present in the chain or not. It returns 0 if the rule exists and returns 1 if it does not.

   **Syntax: **

   `ipables [-t table] --check [chain] [parameters]`

   **Example:** This command checks whether the specified rule is present in the INPUT chain.

   `iptables -t filter --check INPUT -s 192.168.1.123 -j DROP`

   ​                                                             **PARAMETERS**

   The parameters provided with the *iptables* command is used to match the packet and perform the specified action. The common parameters are:

1. **-p, --proto:** is the protocol that the packet follows. Possible values maybe: ***tcp, udp, icmp, ssh*** etc.

   **Syntax**

   `iptables [-t table] -A [chain] -p [protocol_name] [target]`

   **Example:** This command appends a rule in the INPUT chain to drop all udp packets.

   `iptables -t filter -A INPUT -p udp -j DROP`

2.  **-s, --source:** is used to match with the source address of the packet.

   **Syntax**

   `iptables [-t table] -A [chain] -s {sousrce_address} [target]`

   **Example:** This command appends a rule in the INPUT chain to accept all packets originating from 192.168.1.230.

   `iptables -t filter -A INPUT -s 192.168.1.123 -j ACCEPT`

3. **-d, --destination:** is used to match with the destination address of the packet.

   **Syntax**

   `iptables [-t table] -A [chain] -d {destination_address} [target]`

   **Example:** This command appends a rule in the OUTPUT chain to drop all packets destined for 192.168.1.123.

   `iptables -t filter -A OUTPUT -d 192.168.1.123 -j DROP`

4. **-i, --in-interface:** matches packets with the specified in-interface and takes the action.

   **Syntax**

   `iptables [-t table] -A [chain] -i {interface} [target]`

   **Example:** This command appends a rule in the INPUT chain to drop all packets destined for wireless interface.

   `iptables -t filter -A INPUT -i wlan0 -j DROP`

5. **-o, --out-interface:** matches packets with the specified out-interface.

6. **-j, --jump:** this parameter specifies the action to be taken on a match.

   **Syntax:**

   `iptables [-t table] -A [chain] [parameters] -j {target}`

   **Example:** This command adds a rule in the FORWARD chain to drop all packets.

   `iptables -t filter -A FORWARD -j DROP`

   
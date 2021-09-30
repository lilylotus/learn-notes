```bash
1. Local 端口转发 (a -> b -> c)
  a: ssh -CNf -L a_address:a_port:c_address:c_port b_user@b_address
  a: curl a_address:a_port  -> c_address:c_port

2. Remote 端口转发 (a -> b -> c)
  b: ssh -CNf -R b_address:b_port:c_address:c_port a_user@a_address
  a: curl localhost:b_port -> c_address:c_port

3. Dynamic 端口转发 (a -> b -> c)
  a: ssh -CNf -D a_port b_address
  a: curl --socks5 a_address:a_port c_address:c_port
```

## 仅支持密钥登录

```
# 开启 RSA 验证
RSAAuthentication yes
# 是否使用公钥验证
PubkeyAuthentication yes
#  禁止使用密码验证登录
PasswordAuthentication no

#  公钥的保存位置
AuthorizedKeysFile .ssh/authorized_keys
#HostKey /etc/ssh/ssh_host_rsa_key
```


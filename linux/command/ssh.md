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


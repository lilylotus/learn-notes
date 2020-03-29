##### 述

> *NIO* 主要有三大核心：*Channel* (通道)，*Buffer*（缓冲区），Selector（选择器）。
> 传统的 *IO* 基于字节流或字符流操作，而 *NIO* 基于 *Channel* 和 *Buffer* 操作数据。
> 数据从通道读取到缓冲区，或者从缓冲区写到通道。*Selector*（选择器）用于监听多个通道的事件，如：通道的打开、数据到达。因此，单个线程可以监听多个数据通道。
>
> *NIO* 和传统 *IO* 一个最大的区别在于，*IO* 是面向流而 *NIO* 是面向缓冲区的。*Java IO* 意味着每次从流中读取一个或多个字节，直到读取完所有字节，它们没有被缓存的地方，此外还不能前后移动流中的数据。如果需要前后移动数据，需要把它缓存到一个缓冲区。*NIO* 是把数据读取到一个它稍后处理的缓冲区，需要时可以在缓冲区中前后移动，这就增加了处理过程当中的灵活性。但是，还需要检查该缓冲区时候有所需要的数据，而且，需要确保更多的数据读入到缓冲区时不要覆盖未处理的数据。
>
> *IO* 的各种操作是阻塞的，这意味着，当一个线程调用 `read()/write()` 的时候，该线程被阻塞，直到数据读取完或数据完全写入。该线程在此期间不能做任何事情。
> *NIO* 是非阻塞模式， 使一个线程从某通道发送请求读取数据，但是它仅能得到目前可用的数据，如果目前没有数据可用时，就什么都不会获取。而不是保持线程阻塞，所以直至数据变得可以读取之前，该线程可以继续做其他的事情。非阻塞写也是如此。一个线程请求写入一些数据到某通道，但不需要等待它完全写入，这个线程同时可以去做别的事情。 线程通常将非阻塞 IO 的空闲时间用于在其它通道上执行 IO 操作，所以一个单独的线程现在可以管理多个输入和输出通道（channel）。



###### Channel [通道，双向操作]

*IO* 中 *Stream* 是单向的，而 *NIO* 中 *Channel* 是双向的，可以用来同时做读写操作。
*NIO* 中的 *Channel* 主要有：
`FileChannel`（文件），`DatagramChannel`（UDP），`SocketChannel`（TCP-Client），`ServerSocketChannel`（TCP-Server）

###### Buffer

*NIO* 中主要 *Buffer* 实现有：
`Buffer`，`ByteBuffer`，`ByteOrder`，`CharBuffer`，`DoubleBuffer`，`FloatBuffer`，`IntBuffer`，`LongBuffer`，`MappedByteBuffer`，`ShortBuffer`

###### Selector

运行单线程处理多个 *Channel*，向 *Selector* 注册 *Channel*，然后调用 *select()* 方法，这个方法会一直阻塞到某个注册的通道有事件就绪，一旦此方法返回，线程就可以处理这个事件，事件如新的连接进入、数据接受等。

`SelectableChannel` 对象的多路复用 (multiplexor) 器



###### SocketChannel

```java
socketChannel = SocketChannel.open();
socketChannel.configureBlocking(false); // 配置为非阻塞方式
socketChannel.connect(new InetSocketAddress(ADDRESS, PORT));

--- 关闭
socketChannel.close();
```

读取数据

```java
buffer.clear();
buffer.put(message.getBytes(Charset.forName("UTF-8")));
buffer.flip();
while (buffer.hasRemaining()) {
    System.out.println(buffer);
    socketChannel.write(buffer);
}
```

> 注意：`SocketChannel.write()` 方法的调用是在一个 `while` 循环中的。`write()` 方法无法保证能写多少字节到 `SocketChannel`。所以，我们重复调用 `write()` 直到 `Buffer` 没有要写的字节为止。
>
> 非阻塞模式下,`read()` 方法在尚未读取到任何数据时可能就返回了。所以需要关注它的 `int` 返回值，它会告诉你读取了多少字节。

Server 端

```java
Socket socket = serverSocket.accept();
SocketAddress remoteSocketAddress = socket.getRemoteSocketAddress();
System.out.println("Handling client address " + remoteSocketAddress);
in = socket.getInputStream();
// 这里要循环读取，因为不知道有多少数据
while ((recvMsgSize = in.read(buffer)) != -1) { }
```

###### NIO

```java
ssc = ServerSocketChannel.open();
ssc.socket().bind(new InetSocketAddress(SocketChannelClient.PORT));
ssc.configureBlocking(false);

ssc.register(selector, SelectionKey.OP_ACCEPT);
```

与 Selector 一起使用时，Channel 必须处于非阻塞模式下。
触发事件：某个 channel 成功连接到另一个服务器称为“连接就绪”。一个 erver socket channel 准备好接收新进入的连接称为“接收就绪”。一个有数据可读的通道可以说是“读就绪”。等待写数据的通道可以说是“写就绪”。
`SelectionKey.OP_CONNECT`,`SelectionKey.OP_ACCEPT`,`SelectionKey.OP_READ`,`SelectionKey.OP_WRITE`
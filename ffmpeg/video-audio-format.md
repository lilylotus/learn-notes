#### mpeg4 封装的音频视频格式，音视频基础知识

###### 基础：

> 封装、解码、重采样、像素格式

###### 音视频标准 **MPEG-4**

MPEG-4 是一套用于音频、视频信息的压缩编码格式标准
MPEG-4 Part 14 MPEG-4 文件格式
Part 15  AVC 文件格式
Part 10 AVC H264 格式

*常用封装格式*

- AVI 压缩标准可任意选择
- FLV (ts 流媒体格式，视频在线)
- ASF
- MP4

*编码格式：*
视频 H264 (AVC Part 10), WMV, XviD (Part 2)
mjpeg (每一帧都独立，视频大，压缩率低)  --> 视频都是有损压缩

音频： ACC, MP3 (有损压缩), ape(基于无损压缩), flac (无损压缩)
*无损压缩：*编码压缩后不会丢失任何信息

*封装格式和编码格式：*
1封装格式(格式头)|2视频编码帧|3音频编码帧|4视频编码帧...|5音频编码帧...
1: [mp3 (part 14) flv mov avi ] box 音视频信息(编码和格式关键帧索引)
2: 音频帧和视频帧交替的，音频帧和视频帧的速率是不一样的
视频压缩帧压缩算法：  --> 压缩解码后为 Y(明亮)UV(色欲)  -> RGB 三原色
	h264 mpeg-4-10
	NAL(网络提取层) VCL(视频编码层)
	SPS (序列参数) PPS(图像参数)
	I B P (I 帧、B 帧、P 帧)
*注意：*解码时间的 RGB 复制、转换有时间内存开销， CPU  软解， CPU 硬解 (软解比硬解好)
CPU 硬解码写在电路板上，运行效率高，但是限制好了。

音频解码：
	AAC 	->  解码为 PCM FLT (方便运算) -> 转为声卡支持的 16 位播放
	APE、FLAC 无损压缩
	PCM 原始音频
**像素格式** 显示的时候转码内存占用大
*BGRA  RGBA  ARGB32  RGB32  YUV420*

YUV 转 RGB
R = Y + 1.4075 * (V - 128)
G = Y - 0.3455 * (U - 128) - 0.7169 * (V - 128)
B = Y + 1.779 * (U - 128)

**3*3 RGB 图像存放格式 (连续)**

<img src="..\images\rgb-format.png" alt="RGB格式" style="zoom: 80%;" />

**YUV**
Y 表示明亮度，也就是灰度值，U 和 V 表示的则是色度
硬解码、软解码 (高速解码)
**PCM 音频参数**
采用率 sample_rate 44100 (CD) 48000(DVD)  频段，一秒钟采样多少次音频数据
通道 channels (左右声道) ：双声道采样
样本大小 (格式) sample_size
AV_SAMPLE_FMT_S16 (16 位) | AV_SAMPLE_FMT_FLTP (float 32 位，浮点运算快)
一般 32 位播放不了，需要重采样转换为 16 位
**MP4 格式**
<img src="..\images\MP4-format.png" alt="MP4 format" style="zoom:80%;" />

**H.264 / AVC 视频编码标准**
视频编码层面 (VCL) : 视频数据内容
网络抽象层面 (NVL) : 格式化数据并提供头信息
NAL 单元： 平时每帧数据就是 NAL 单元 (SPS 与 PPS 除外)，实际 H264 数据帧中，往往帧前面带有 00 00 00 01 或 00 00 001 分隔符，一般来说编码器编出的首帧数据位 PPS 与 SPS ，接着位 I 帧。

---

###### ffmpeg SDK 软解码基础

> 解封装、软硬件解码、像素格式转换、重采样、pts/dts、同步策略

*解封装*

```c++
av_register_all() ： 调用一次，在 open 之前，解封装
avformat_netwrok_init() : rtsp 网络流视频
avformat_open_input(...) : 打开
avformat_find_stream_info(..) : 查找文件格式和索引
av_find_best_stream(...) : 找到音频和视频流
av_read_frame(...) : 读取关键帧

// 涉及到的结构体
AVFormatContext
AVStream
AVPacket
    
1. int avformat_open_input
确保 av_register_all avformat_network_init 已经调用
AVFormatContext **ps
const char *url // 地址：网络，本地，rtsp，可以重连接
AVInputFormat *fmt // 指定封装格式，一般不用
AVDictionary **options // 字典数据
```

**vs 报错 av_register_all was declared deprecated**

> 将 VS 的 SDL 检查关闭
> C/C++ -> SDL 检查 -> no
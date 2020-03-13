#### 1. wget

```bash
wget [OPTION]... [URL]...

-b,  --background        go to background after startup.

Logging and input file:
-o,  --output-file=FILE    log messages to FILE.
-a,  --append-output=FILE  append messages to FILE.
-q,  --quiet               quiet (no output).

Download:
-O,  --output-document=FILE    write documents to FILE.
-c,  --continue                resume getting a partially-downloaded file.

示例：
# wget -b -o compose.log -O docker-compose -c https://github.com/docker/compose/releases/download/1.25.3/docker-compose-Linux-x86_64
```

#### 2. curl

```bash
curl [options...] <url>

-L, --location      Follow redirects (H)
-o, --output FILE   Write output to <file> instead of stdout

# curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

-v, --verbose       Make the operation more talkative # 显示更多的请求信息
-I, --head          Show document info only # 仅显示 headers
-i, --include       Include protocol headers in the output (H/F) #显示 header 和数据

-X, --request COMMAND  Specify request command to use # 指定请求方法， GET、POST
-H, --header LINE   Custom header to pass to server (H) # 指定请求头
-d, --data DATA     HTTP POST data (H) # 设置请求体
```

在 <font color="red">`post`</font> 请求中，一般只使用 <font color="red">`-d,--data`</font> 选项，因为此时默认 *POST* 请求，*Content-Type* 为 *application/x-www-form-urlencoded*；如果想模拟表单文件上传，可使用 *-F,-form* 选项，它默认 POST 请求，*Content-Type* 为 *multipart/form-data*

```bash
1. --data
	# curl -v --data "name=tom&password=12 3 是的456" http://localhost:8080/test
	> 会自动进行 url 编码
	# curl -v -d "name=tom" -d "passwd=12 34" http://localhost:8080/test

2. --data-binary <data>：数据直接填充，没有额外的数据处理过程(即 url 编码)
数据以@开头时，会被认定为文件，直接将文件的内容读入，但不进行 url 编码
	# curl --data-binary "@data.html" -H "Content-Type: text/*" http://localhost

3. -F,--form <name=content>：Content-Type 默认为 multipart/form-data
	# curl -F profile=@portrait.jpg https://example.com/upload
	> profile 为请求的参数名称，@ 指定上传的文件
	# curl -F "web=@index.html;type=text/html" example.com
	> 为 part 添加 Content-Type， 默认为 application/octet-stream
	# curl -F "file=@localFile;filename=upload-file" example.com
	> 更换 http 请求显示的名称
	
4. -b, --cookie <data> 设置cookie，默认为上次请求设置的cookie。
	data 的格式为 NAME1=VALUE1;NAME2=VALUE2
```




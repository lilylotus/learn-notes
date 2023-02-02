# 常见注意事项

## 资源加载

参考 spring boot 默认资源加载器方法 `org.springframework.core.io.DefaultResourceLoader#getResource`

### classpath 资源加载

```java
public class ResourcesResolve {

    public static final String CLASSPATH_URL_PREFIX = "classpath:";
    public static final String URL_PROTOCOL_FILE = "file";
    public static final File[] EMPTY_RESOURCES = {};

    private static final Comparator<File> FILE_COMPARATOR = Comparator.comparing(File::getAbsolutePath);

    private static boolean isPatternLocation(String location) {
        return location.contains("*");
    }

    public static URI toURI(URL url) throws URISyntaxException {
        return toURI(url.toString());
    }

    public static URI toURI(String location) throws URISyntaxException {
        return new URI(StringUtils.replace(location, " ", "%20"));
    }

    public File getFile(URL resourceUrl, String description) throws FileNotFoundException {
        if (resourceUrl == null) {
            throw new IllegalArgumentException("Resource URL must not be null");
        }
        if (!URL_PROTOCOL_FILE.equals(resourceUrl.getProtocol())) {
            throw new FileNotFoundException(
                    description + " cannot be resolved to absolute file path " +
                            "because it does not reside in the file system: " + resourceUrl);
        }
        try {
            return new File(toURI(resourceUrl).getSchemeSpecificPart());
        } catch (URISyntaxException ex) {
            // Fallback for URLs that are not valid URIs (should hardly ever happen).
            return new File(resourceUrl.getFile());
        }
    }

    public static URL resolveURL(String path, Class<?> clazz, ClassLoader classLoader) throws FileNotFoundException {
        URL url;
        if (clazz != null) {
            url = clazz.getResource(path);
        } else if (classLoader != null) {
            url = classLoader.getResource(path);
        } else {
            url = ClassLoader.getSystemResource(path);
        }
        if (url == null) {
            throw new FileNotFoundException(path + " cannot be resolved to URL because it does not exist");
        }
        return url;
    }

    public String getDescription(String path) {
        StringBuilder builder = new StringBuilder("class path resource [");
        String pathToUse = path;
        if (pathToUse.startsWith("/")) {
            pathToUse = pathToUse.substring(1);
        }
        builder.append(pathToUse);
        builder.append(']');
        return builder.toString();
    }

    private File getResourceByPath(String path) throws FileNotFoundException {
        String pathToUse = path;
        if (pathToUse.startsWith("/")) {
            pathToUse = pathToUse.substring(1);
        }
        URL url = resolveURL(pathToUse, null, ResourcesResolve.class.getClassLoader());
        return getFile(url, getDescription(path));
    }

    public File getResource(String location) throws FileNotFoundException {
        if (location.startsWith("/")) {
            return getResourceByPath(location);
        } else if (location.startsWith(CLASSPATH_URL_PREFIX)) {
            return getResourceByPath(location.substring(CLASSPATH_URL_PREFIX.length()));
        }
        return null;
    }

    private File[] getResourcesFromPatternLocation2(String location) throws IOException {
        String directoryPath = location.substring(0, location.indexOf("*/"));
        File resource = getResource(directoryPath);
        File[] files = resource.listFiles(File::isDirectory);
        if (files != null) {
            String fileName = location.substring(location.lastIndexOf("/") + 1);
            Arrays.sort(files, FILE_COMPARATOR);
            return Arrays.stream(files)
                    .map(file -> file.listFiles((dir, name) -> name.equals(fileName)))
                    .filter(Objects::nonNull)
                    .flatMap((Function<File[], Stream<File>>) Arrays::stream)
                    .toArray(File[]::new);
        }
        return EMPTY_RESOURCES;
    }

    private File[] getResourcesFromPatternLocation(String location) throws IOException {
        String directoryPath = location.substring(0, location.indexOf("*/"));
        File resource = getResource(directoryPath);
        Set<File> resources = new HashSet<>(8);
        String fileName = location.substring(location.lastIndexOf("/") + 1);
        recursiveResourcesFromPatternLocation(resource, fileName, resources);
        return resources.toArray(new File[0]);
    }

    private void recursiveResourcesFromPatternLocation(File location, String fileName, Set<File> resources) {
        if (null == location || !location.exists()) {
            return;
        }
        if (location.isDirectory()) {
            // 搜索文件
            File[] files = location.listFiles(((dir, name) -> fileName.equals(name)));
            if (null != files && files.length > 0) {
                resources.addAll(Arrays.asList(files));
            }
            // 递归目录
            File[] dirs = location.listFiles(File::isDirectory);
            if (dirs != null && dirs.length > 0) {
                Arrays.sort(dirs, FILE_COMPARATOR);
                Arrays.stream(dirs).forEach(f -> recursiveResourcesFromPatternLocation(f, fileName, resources));
            }
        } else if (location.isFile() && fileName.equals(location.getName())) {
            resources.add(location);
        }
    }

    private File[] getResources(String location) {
        try {
            if (isPatternLocation(location)) {
                return getResourcesFromPatternLocation(location);
            }
            return new File[]{getResource(location)};
        } catch (Exception ex) {
            ex.printStackTrace();
            return EMPTY_RESOURCES;
        }
    }

    public static void main(String[] args) throws FileNotFoundException {
//        String location = "classpath:/application.yml";
//        String location = "/application.yml";
        String location = "/*/LoaderDemo.class";
        ResourcesResolve resolve = new ResourcesResolve();
        File[] resources = resolve.getResources(location);
        Arrays.stream(resources).map(File::getAbsolutePath).forEach(System.out::println);
    }
}
```

### 外置资源加载

```java
public static InputStream getInputStream(URL url) throws IOException {
    URLConnection con = url.openConnection();
    ResourceUtils.useCachesIfNecessary(con);
    try {
        return con.getInputStream();
    } catch (IOException ex) {
        // Close the HTTP connection (if applicable).
        if (con instanceof HttpURLConnection) {
            ((HttpURLConnection) con).disconnect();
        }
        throw ex;
    }
}

public static void test() throws MalformedURLException {
    // String location = "file:D:/load_path.txt";
    // String location = "file:resource.log";
    String location = "https://www.baidu.com/";
    URL url = new URL(location);
    try (BufferedReader reader = new BufferedReader(new InputStreamReader(getInputStream(url), StandardCharsets.UTF_8))) {
        String line;
        while ((line = reader.readLine()) != null) {
            System.out.println("line = " + line);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```



## 类获取路径问题

Java 中 Class 类的 getResource() 和 getResourceAsStream() 方法的使用

```java
获取配置文件的方法
1. File file = new File("c:/test.txt");
2. File file1 = new File(Test.class.getResource("/com/file1.txt").getFile());
3. File file4 = new File(Test.class.getResource("/file2.txt").getFile());

示例:
3. StringTest.class.getResource("file").getFile());
4. StringTest.class.getResource("/file").getFile());
5. StringTest.class.getClassLoader().getResource("cn/file").getFile());
6. StringTest.class.getClassLoader().getResource("file").getFile());

// -> 3. /E:/coding/bin/cn/file
// -> 4. /E:/coding/bin/file
// -> 5. /E:/coding/bin/cn/file
// -> 6. /E:/coding/bin/file
```

**注意：** `Test.class.getResource();`  没有加 **"/"** 是获取当前类路径, 加了 **"/"** 是获取根目录开始    `Test.class.getClassLoader().getResource()` 是获取根目录开始, 但是不用加 **"/"** (cn/test/test.txt 或者 test.txt)

还有一个 getResourceAsStream() 方法，参数是与 getResouce() 方法是一样的，
它相当于你用 getResource() 取得 File 文件后，再 new InputStream(file) 获取到输入流。

## url 和 uri 的区别

```java
http://localhost:8080/myweb/hello.html

URL = http://localhost:8080/myweb/hello.html
URI = /myweb/hello.html
```

URL：uniform resource location 统一资源定位符
URI：uniform resource identifier 统一资源标识符 (以 "/" 开始)
基本的 URL 格式为 "协议://IP地址/路径和文件名"，如：ftp://ftp.is.co.za/rfc/rfc1808.txt

```java
String path = request.getContextPath();  
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/"; 

request.getSchema() -- 返回的是当前连接使用的协议，一般应用返回的是http、SSL返回的是https；
request.getServerName() -- 返回当前页面所在的服务器的名字；
request.getServerPort() -- 返回当前页面所在的服务器使用的端口，80；
request.getContextPath() -- 返回当前页面所在的应用的名字。

以访问的 jsp 为：http://localhost:8080/dmsd/course/index.jsp，工程名为 /dmsd 为例

request.getContextPath() : 得到工程名：/dmsd
request.getServletPath() : 返回当前页面所在目录下全名称：/course/index.jsp
request.getRequestURL() : 返回IE地址栏地址：http://localhost:8080/dmsd/course/index.jsp
request.getRequestURI() : 返回包含工程名的当前页面全路径：/dmsd/course/index.jsp
```



## oracle jdbc

```java
jdbc:oracle:thin:@//host:port/service_name
例如: jdbc:oracle:thin:@//localhost:1521/orcl.city.com
注意这里的格式，@后面有//, port后面:换成了/,这种格式是 Oracle 推荐的格式，因为对于集群来说，每个节点的SID 是不一样的，但是SERVICE_NAME 确可以包含所有节点。

你的oracle的service_name可以通过以下方式获得：
sqlplus / as sysdba
select value from v$parameter where name='service_names';
```

```java
jdbc:oracle:thin:@host:port:SID
例如: jdbc:oracle:thin:@localhost:1521:orcl

sqlplus / as sysdba
select value from v$parameter where name='instance_name';
```

## java IO

```java
一: bytes流

OutputStream (abstract)
    FileOutputStream (File),(String) : write(byte[] b, int off, int len) 
    FilterOutputStream
        BufferedOutputStream (OutputStream) : write(byte[] b, int off, int len)
        DataOutputStream (OutputStream)
        PrintStream (File, String csn), (OutputStream), (String)
    ObjectOutputStream (OutputStream)
    ByteArrayOutputStream (int)

InputStream (abstract)
    FileInputStream (File), (String) : read(byte[] b, int off, int len)
    FilterInputStream
        BufferedInputStream (InputStream in, int size)
        DataInputStream (InputStream in)
        ObjectInputStream (InputStream in)
    ByteArrayInputStream (byte[] buf, int offset, int length)

二: 字符流

Writer (abstract)
    BufferedWriter (Writer)
    FilterWriter
    OutputStreamWriter (OutputStream, Charset), (OutputStream, String)
    PrintWriter (File), (OutputStream), (String), (Writer)

Reader (abstract)
    BufferedReader (Reader in)
    InputStreamReader (InputStream, Charset), (InputStream in, String charsetName)
    FilterReader
```


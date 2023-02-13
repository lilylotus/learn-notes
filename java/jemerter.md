# Jemeter

## 中文乱码

新增 “BeanShell PostProcessor” ，添加脚本。

```
prev.setDataEncoding("UTF-8");
```

## 删除 cookie

新增 “JSR223 PreProcessor” 处理器，添加脚本。

```groovy
import org.apache.jmeter.protocol.http.control.CookieManager;
import org.apache.jmeter.protocol.http.control.Cookie;

CookieManager cManager = sampler.getCookieManager();
int count = cManager.getCookieCount();
for (int index = 0; index < count; index++){
	cManager.remove(0);
}
```


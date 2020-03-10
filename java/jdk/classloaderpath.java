import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;

/**
 * Class 类的加载路径
 * 1. BootstrapClassLoader 纯的 C++ 实现的类加载器，没有对应的 java 类，主要加载路径是 jre/lib 目录下的核心类库
 * 2. ExtClassLoader 类全名是 cn.misc.Launcher$ExtClassLoader, 主要加载 jre/lib/ext 目录的拓展包
 * 3. AppClassLoader 类全名是 sum.misc.Launcher$AppClassLoader, 主要加载 CLASSPATH 路径下的包
 * @author muscari
 */
public class ClassLoaderPath {

    public static void main(String[] args) {

        // 1. 获取 ClassLoaderPath 的类加载器
        Class<?> mainClass = ClassLoaderPath.class;
        ClassLoader mainClassLoader = mainClass.getClassLoader();
        System.out.println("ClassLoaderPath ClassLoader: " + mainClassLoader.toString());

        // 2. 获取 AppClassLoader 的加载路径
        URL[] appUrls = ((URLClassLoader)mainClassLoader).getURLs();
        printUrls(appUrls);
        System.out.println("--------------------------------");

        // 3. 获取 ClassLoaderPath 的 parent loader
        ClassLoader parentClassLoader = mainClassLoader.getParent();
        System.out.println("parent's ClassLoader : " + parentClassLoader.toString());

        // 4. 获取 Launcher$ExtClassLoader 的加载路径
        URL[] extUrls = ((URLClassLoader)parentClassLoader).getURLs();
        printUrls(extUrls);
        System.out.println("--------------------------------");

        // 5. 获取 ClassLoaderPath 的 parent loader 的 parent ClassLoader
        ClassLoader parentClassLoaderParent = parentClassLoader.getParent();
        System.out.println("ExtClassLoader parent's ClassLoader : " + parentClassLoaderParent);

        // 6. 获取 BootstrapClassLoader
        try {
            Class<?> launcherClass = Class.forName("sun.misc.Launcher");
            Method methodGetClassPath = launcherClass.getDeclaredMethod("getBootstrapClassPath", null);
            if (null != methodGetClassPath) {
                methodGetClassPath.setAccessible(true);
                Object mObj = methodGetClassPath.invoke(null, null);
                if (null != mObj) {
                    Method methodGetURLs = mObj.getClass().getDeclaredMethod("getURLs", null);
                    if (null != methodGetURLs) {
                        methodGetURLs.setAccessible(true);
                        URL[] bootUrls = (URL[]) methodGetURLs.invoke(mObj, null);
                        printUrls(bootUrls);
                    }

                }
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }

    }

    public static void printUrls(URL[] urls) {
        for (URL url : urls) {
            System.out.println(url);
        }
    }

}

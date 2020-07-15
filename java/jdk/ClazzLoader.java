package cn.nihility.jvm;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.net.URLStreamHandler;

/**
 * @author yzx
 * @date 2019-10-17 15:30
 */
public class ClazzLoader {

    public static void main(String[] args) throws ClassNotFoundException, NoSuchMethodException, InvocationTargetException, IllegalAccessException, IOException, InstantiationException {
        System.out.println(System.getProperty("user.dir"));
        String path = System.getProperty("user.dir") + File.separator + "out" + File.separator + "production" + File.separator + "classess";
        System.out.println(path);

        ClazzLoader cl = new ClazzLoader();
//        cl.loadClazz();
        cl.loadJar();
        System.out.println("Hello Jar");

        ClassLoader classLoader = cl.getClass().getClassLoader();
        System.out.println("main class loader " + classLoader);
        ClassLoader parent = classLoader.getParent();
        System.out.println("main parent class loader " + parent);
    }


    public void loadClazz() throws IOException, ClassNotFoundException, NoSuchMethodException, InvocationTargetException, IllegalAccessException, InstantiationException {

        // String path = System.getProperty("user.dir") + File.separator + "out" + File.separator + "production" + File.separator + "classess";
        String path = "D:\\libs\\jvm";

        File clazzPath = new File(path);
        URL[] urls = new URL[1];

        String repository = (new URL("file", null, clazzPath.getCanonicalPath() + File.separator)).toString();
        System.out.println(repository);

        urls[0] = new URL(repository);
        URLClassLoader loader = new URLClassLoader(urls);

        Class<?> clazz = loader.loadClass("cn.nihility.jvm.Hello");
        Object instance = clazz.newInstance();
        Method method = clazz.getDeclaredMethod("say");
        method.invoke(instance);

        // 加载， 校验， 准备， 解析， 初始化， 使用， 卸载
    }

    public void loadJar() throws IOException, ClassNotFoundException, IllegalAccessException, InstantiationException, NoSuchMethodException, InvocationTargetException {
        String path = "D:\\libs\\jvm";
        File clazzPath = new File(path);
        URL[] urls = new URL[1];

        String repository = (new URL("file", null, clazzPath.getCanonicalPath() + File.separator + "util.jar")).toString();
        System.out.println(repository);

        urls[0] = new URL(repository);

        URLClassLoader loader = new URLClassLoader(urls);

        Class<?> clazz = loader.loadClass("cn.nihility.remote.RemoteSay");
        Method method = clazz.getDeclaredMethod("say");
        Object instance = clazz.newInstance();

        ClassLoader classLoader = clazz.getClassLoader();
        System.out.println("current " + classLoader);

        ClassLoader parent = classLoader.getParent();
        System.out.println("parent " + parent);

        method.invoke(instance);

    }

}



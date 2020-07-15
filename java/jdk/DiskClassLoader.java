package cn.nihility.jvm;

import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * @author yzx
 * @date 2019-10-17 14:03
 */
public class DiskClassLoader extends ClassLoader {


    public static void main(String[] args) throws ClassNotFoundException, IllegalAccessException, InstantiationException, NoSuchMethodException, InvocationTargetException, InterruptedException {

        String libPath = DiskClassLoader.class.getResource("").getFile();
        System.out.println(libPath);



        while (true) {
            DiskClassLoader dcl = new DiskClassLoader("D:\\libs\\jvm");
            Class<?> clazz = dcl.loadClass("cn.nihility.jvm.Hello");

            if (clazz != null) {
                Object instance = clazz.newInstance();
                Method method = clazz.getDeclaredMethod("say");
                method.invoke(instance);
            }

            Thread.sleep(2000L);
        }


    }

    private String libPath;

    public DiskClassLoader(String path) {
        libPath = path;
    }

    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {

        String fileName = getFileName(name);

        File file = new File(libPath, fileName);

        try {
            FileInputStream fis = new FileInputStream(file);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();

            int len = 0;
            byte[] buffer = new byte[1024 * 1024];

            while ( (len = fis.read(buffer)) != -1) {
                baos.write(buffer, 0, len);
            }

            byte[] data = baos.toByteArray();

            fis.close();
            baos.close();

            return defineClass(name, data, 0, data.length);

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return super.findClass(name);
    }

    private String getFileName(String name) {
        int index = name.lastIndexOf('.');
        if (index == -1) {
            return name + ".class";
        } else {
            return name.substring(index + 1) + ".class";
        }
    }
}

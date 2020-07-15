package cn.nihility.jvm;

import jdk.internal.org.objectweb.asm.ClassWriter;
import jdk.internal.org.objectweb.asm.MethodVisitor;
import jdk.internal.org.objectweb.asm.Opcodes;

import java.util.ArrayList;
import java.util.List;

/**
 * @author yzx
 * @date 2019-10-10 15:37
 */
public class Metaspace extends ClassLoader {

    public static void main(String[] args) throws InterruptedException {

        // 类持有
        List<Class<?>> clazzList = new ArrayList<>();

        // 循环 1000w 次， 生成 1000W 个不同的类
        for (int i = 0; i < 10000000; i++) {
            ClassWriter cw = new ClassWriter(0);

            // 定义一个类的名称为 class{i}
            cw.visit(Opcodes.V1_1, Opcodes.ACC_PUBLIC, "Class" + i, null, "java/lang/Object", null);

            // 定义构造函数 <init> 方法
            MethodVisitor mw = cw.visitMethod(Opcodes.ACC_PUBLIC, "<init>", "()V", null, null);

            // 第一个指令加载 this
            mw.visitVarInsn(Opcodes.ALOAD, 0);

            // 第二个指令调用父级 Object 构造函数
            mw.visitMethodInsn(Opcodes.INVOKESPECIAL, "java/lang/Object", "<init>", "()V", false);

            // 第三条指令 return
            mw.visitInsn(Opcodes.RETURN);
            mw.visitMaxs(1, 1);
            mw.visitEnd();

            Metaspace test = new Metaspace();
            byte[] code = cw.toByteArray();

            // 定义类
            Class<?> clazz = test.defineClass("Class" + i, code, 0, code.length);
            clazzList.add(clazz);
            Thread.sleep(200L);
        }


    }

}

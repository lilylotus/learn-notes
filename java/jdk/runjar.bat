sed -i "s/Init.*\"/Init NNN\"/" Hello.java
javac -d D:\libs\jvm *.java
jar cvfm util.jar mymanifest cn

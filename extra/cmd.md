```cmd
@echo off

start /d "C:\kits\JetBrains\IntelliJ IDEA 2019.3.5\bin\" idea64.exe
choice /T 1 /C ync /CS /D y /n

start /d "D:\bat" nacos.bat
choice /T 1 /C ync /CS /D y /n


start /d "D:\bat" redis.bat
choice /T 1 /C ync /CS /D y /n

exit
```


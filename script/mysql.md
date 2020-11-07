## bat batch script

### mysql export

```cmd
@echo off
set DIR=%date:~0,4%%date:~5,2%%date:~8,2%
set DAY=%date:~5,2%%date:~8,2%
set BIZ=kiam-biz-1022
set CFG=kiam-cfg-1022
set CMDB=kiam-cmdb-1022

set HOST=127.0.0.1
set PASSWORD=mysql
set USER=root
set suffix=local

echo %DIR%
if not exist %DIR% ( md %DIR% )

echo "export %BIZ%"
mysqldump -u%USER% -p%PASSWORD% -h%HOST% %BIZ% > %DIR%\%DAY%_biz_%suffix%.sql
echo "export %CFG%"
mysqldump -u%USER% -p%PASSWORD% -h%HOST% %CFG% > %DIR%\%DAY%_cfg_%suffix%.sql
echo "export %CMDB%"
mysqldump -u%USER% -p%PASSWORD% -h%HOST% %CMDB% > %DIR%\%DAY%_cmdb_%suffix%.sql
echo DUMP LOG : BIZ=%BIZ% CFG=%CFG% CMDB=%CMDB% > %DIR%\dump_%suffix%.log
PAUSE
```

### mysql import

```cmd
@echo off
rem set /p BASE_DIR=Please input base dir:

set BASE_DIR=20201106
set CREATE_DIR=create
set DAY=%date:~5,2%%date:~8,2%
echo %BASE_DIR%

if not exist %BASE_DIR% ( md %BASE_DIR% )

REM 替换str中的XXX为YYY
REM set str2=%str:XXX=YYY%

REM %1 %2 %3 %4 ... %9 - 专门保存外部参数的, 如：exec.bat param1 param2
REM 为什么批处理中用两个 %%，其实是编译器编译的时候要屏蔽一个 %

REM 打开延迟扩展设置： setlocal enabledelayedexpansion
REM 使用!k!（2个感叹号夹1个变量）来读取变量，不开启延迟扩展时，读取方式是 %k%（2个百分号夹1个变量）

IF EXIST %BASE_DIR% ( 
    echo "Dir [%BASE_DIR%] Exists"
	for %%f in (%BASE_DIR%\*.sql) do (
		echo "---------- File Name %%f ----------"
		echo "Short File Name : [%%~nf]"
		echo "File Suffix     : [%%~xf]"
		echo "Full File Name  : [%%~nxf]"
		echo "File Dir        : [%%~dpnf]"
		
		echo DROP DATABASE IF EXISTS `%%~nf_%DAY%`; > %CREATE_DIR%/%%~nf_create.sql
		echo CREATE DATABASE `%%~nf_%DAY%` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; >> %CREATE_DIR%/%%~nf_create.sql
		
		echo @echo off>%CREATE_DIR%/%%~nf_import.bat
		echo echo CREATE DATABSE [%%~nf_%DAY%]>>%CREATE_DIR%/%%~nf_import.bat
		echo mysql -uroot -pmysql ^<^ %%~nf_create.sql>>%CREATE_DIR%/%%~nf_import.bat
		echo echo IMPORT DATABASE [../%BASE_DIR%/%%~nxf]>>%CREATE_DIR%/%%~nf_import.bat
		echo mysql -uroot -pmysql %%~nf_%DAY% ^<^ ../%BASE_DIR%/%%~nxf>>%CREATE_DIR%/%%~nf_import.bat
		echo PAUSE>>%CREATE_DIR%/%%~nf_import.bat
	)
) ELSE (
	echo "Dir [%BASE_DIR%] Not Exists"
)
PAUSE
```

### Windows Startup Excution Script

目录： `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp`

> CHOICE：[/C[:]按键表] [/N] [/S] [/T[:]选择值,秒数] [显示文本]
其中，/C 表示可选则的按键，/N 表示不要显示提示信息，/S 表示大小写字符敏感方式，/T 表示若在批定的时间内没有选择的话，自动执行 /C 中定义的某个选择值。

```cmd
@echo off
start /d "C:\install\DingDing\" DingtalkLauncher.exe
choice /T 1 /C ync /CS /D y /n

start /d "C:\kits\JetBrains\IntelliJ IDEA 2019.3.5\bin\" idea64.exe
choice /T 1 /C ync /CS /D y /n

start /d "C:\Program Files\PremiumSoft\Navicat Premium 15\" navicat.exe
choice /T 1 /C ync /CS /D y /n

start /d "C:\Program Files (x86)\Microsoft Bing Dictionary\" BingDict.exe
choice /T 1 /C ync /CS /D y /n

exit
```
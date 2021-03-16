@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:: 使用方式：
:: 解压缩释放到jmeter的根目录（不是bin）
:: 执行注册|反注册时，需以管理员身份运行

::  将jmeter注册到系统，可以实现以下功能：
:: - 双击.jmx文件可打开jmeter并加载脚本
:: - 右击.jmx文件可选择用后台模式运行并生成测试报告
:: - 开始-运行中输入jmeter可快速开启jmeter新实例或快速打开最近的jmx
:: - 包含注册和反注册


:begin

::初始化jmeter路径
if not exist "%~dp0\bin\jmeter.bat" ( echo runJmeter必须在jmeter主目录下运行！
pause
goto :EOF
)

set RUNJMETER=%~s0
set JMETER_HOME=%~dp0
set JMETER_HOME=%JMETER_HOME:~0,-1%
::读取jmx文件编辑历史
set CLASSPATH=%JMETER_HOME%/pathparser.jar;%CLASSPATH%
for /f "tokens=1,* delims=/ skip=2" %%i in ('reg QUERY HKCU\Software\JavaSoft\Prefs\org\apache\jmeter\gui\action /v recent_file_0') do   set recentFile_reg=%%j
for /f "tokens=*" %%i in ('java com.tzutils.UnicodeStrParser "%recentFile_reg%"') do set recentFile=%%i


title=%JMETER_HOME%
set path=%JMETER_HOME%\bin;%PATH%
set jmxFilePath=%1
::防止jmx路径包含空格截断，传入前指定双引号扩起，例如 jmeter.bat "d:\programe files\1.jmx" --nogui


if [%jmxFilePath%]==[] goto :REG
::默认传入有jmx，如果无，则跳转主菜单。

:openJmx
if "%2"=="--nogui" goto :openWithNoGUI
echo 图形界面打开脚本：%jmxFilePath%
jmeter.bat -t %jmxFilePath%
goto :EOF 

:runOnlyJmeter
echo 仅启动图形界面jmeter
jmeter.bat
goto :EOF 

:openWithNoGUI
echo 以后台方式运行jmeter脚本：%jmxFilePath%
set /p resFile="指定结果文件名(*.jtl)："
set /p webReportFolder="指定测试报告输出的目录名"
jmeter.bat -n -t %jmxFilePath% -l "%resFile%" -e -o "%webReportFolder%"
pause
goto :EOF

:REG
echo 1.未指定参数，打开空白Jmeter（5秒后默认选择）
echo 2.打开上次编辑的脚本(%recentFile%)
echo 3.注册当前jmeter到系统关联
echo 4.注销当前jmeter的系统关联
choice /C 1234  /T 5 /D 1 /N /M "请选择"  
if %ERRORLEVEL% equ 2 ( 
	cls
	set jmxFilePath="%recentFile%"
	goto :openJmx
)


if %ERRORLEVEL% equ 3 (
	cls
	net.exe session 1>NUL 2>NUL || ( 
		echo 需要管理员身份,请在新窗口中重执行
		goto UACPrompt
	)
	echo 1.在注册表关联.jmx文件
	::默认打开方式为cmd.exe /c "%RUNJMETER% \"%%1\""
	reg add "HKCR\Software\Microsoft\Command Processor" /v "DisableUNCCheck" /t "REG_DWORD" /d "1" /f
	reg add "HKCR\.jmx" /ve /d "jmeterTestFile" /f
	reg add "HKCR\jmeterTestFile\shell\open\command" /ve /d "cmd.exe /c \"%RUNJMETER% \"%%1\"\"" /f
	reg add "HKCR\jmeterTestFile\shell\以jmeter后台模式执行\command" /ve /d "cmd.exe /c \"%RUNJMETER% \"%%1\"\" --nogui" /f
	echo 已完成设置，可双击打开jmx文件和右键以后台模式运行
	echo 2.设置快捷启动关键字jmeter到系统运行菜单
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\jmeter.exe" /ve /d "%JMETER_HOME%\runJmeter.bat" /f
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\jmeter.exe" /v "Path" /d "%JMETER_HOME%" /f
	pause
	goto :EOF
)
if %ERRORLEVEL% equ 4 ( 
	cls
	net.exe session 1>NUL 2>NUL || ( 
		echo 需要管理员身份,请在新窗口中重执行
		goto UACPrompt
	)
	net.exe session 1>NUL 2>NUL || goto UACPrompt
	echo 清理.jmx脚本文件关联
	reg delete "HKCR\.jmx"  /f
	reg delete "HKCR\jmeterTestFile"  /f
	echo 清理jmeter的开始运行关联
	reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\jmeter.exe" /f
	pause
	goto :EOF
)

cls
goto :runOnlyJmeter

:UACPrompt  
	if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" 
    "%temp%\getadmin.vbs" 
    exit /B  

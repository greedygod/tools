@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:: ʹ�÷�ʽ��
:: ��ѹ���ͷŵ�jmeter�ĸ�Ŀ¼������bin��
:: ִ��ע��|��ע��ʱ�����Թ���Ա�������

::  ��jmeterע�ᵽϵͳ������ʵ�����¹��ܣ�
:: - ˫��.jmx�ļ��ɴ�jmeter�����ؽű�
:: - �һ�.jmx�ļ���ѡ���ú�̨ģʽ���в����ɲ��Ա���
:: - ��ʼ-����������jmeter�ɿ��ٿ���jmeter��ʵ������ٴ������jmx
:: - ����ע��ͷ�ע��


:begin

::��ʼ��jmeter·��
if not exist "%~dp0\bin\jmeter.bat" ( echo runJmeter������jmeter��Ŀ¼�����У�
pause
goto :EOF
)

set RUNJMETER=%~s0
set JMETER_HOME=%~dp0
set JMETER_HOME=%JMETER_HOME:~0,-1%
::��ȡjmx�ļ��༭��ʷ
set CLASSPATH=%JMETER_HOME%/pathparser.jar;%CLASSPATH%
for /f "tokens=1,* delims=/ skip=2" %%i in ('reg QUERY HKCU\Software\JavaSoft\Prefs\org\apache\jmeter\gui\action /v recent_file_0') do   set recentFile_reg=%%j
for /f "tokens=*" %%i in ('java com.tzutils.UnicodeStrParser "%recentFile_reg%"') do set recentFile=%%i


title=%JMETER_HOME%
set path=%JMETER_HOME%\bin;%PATH%
set jmxFilePath=%1
::��ֹjmx·�������ո�ضϣ�����ǰָ��˫������������ jmeter.bat "d:\programe files\1.jmx" --nogui


if [%jmxFilePath%]==[] goto :REG
::Ĭ�ϴ�����jmx������ޣ�����ת���˵���

:openJmx
if "%2"=="--nogui" goto :openWithNoGUI
echo ͼ�ν���򿪽ű���%jmxFilePath%
jmeter.bat -t %jmxFilePath%
goto :EOF 

:runOnlyJmeter
echo ������ͼ�ν���jmeter
jmeter.bat
goto :EOF 

:openWithNoGUI
echo �Ժ�̨��ʽ����jmeter�ű���%jmxFilePath%
set /p resFile="ָ������ļ���(*.jtl)��"
set /p webReportFolder="ָ�����Ա��������Ŀ¼��"
jmeter.bat -n -t %jmxFilePath% -l "%resFile%" -e -o "%webReportFolder%"
pause
goto :EOF

:REG
echo 1.δָ���������򿪿հ�Jmeter��5���Ĭ��ѡ��
echo 2.���ϴα༭�Ľű�(%recentFile%)
echo 3.ע�ᵱǰjmeter��ϵͳ����
echo 4.ע����ǰjmeter��ϵͳ����
choice /C 1234  /T 5 /D 1 /N /M "��ѡ��"  
if %ERRORLEVEL% equ 2 ( 
	cls
	set jmxFilePath="%recentFile%"
	goto :openJmx
)


if %ERRORLEVEL% equ 3 (
	cls
	net.exe session 1>NUL 2>NUL || ( 
		echo ��Ҫ����Ա���,�����´�������ִ��
		goto UACPrompt
	)
	echo 1.��ע������.jmx�ļ�
	::Ĭ�ϴ򿪷�ʽΪcmd.exe /c "%RUNJMETER% \"%%1\""
	reg add "HKCR\Software\Microsoft\Command Processor" /v "DisableUNCCheck" /t "REG_DWORD" /d "1" /f
	reg add "HKCR\.jmx" /ve /d "jmeterTestFile" /f
	reg add "HKCR\jmeterTestFile\shell\open\command" /ve /d "cmd.exe /c \"%RUNJMETER% \"%%1\"\"" /f
	reg add "HKCR\jmeterTestFile\shell\��jmeter��̨ģʽִ��\command" /ve /d "cmd.exe /c \"%RUNJMETER% \"%%1\"\" --nogui" /f
	echo ��������ã���˫����jmx�ļ����Ҽ��Ժ�̨ģʽ����
	echo 2.���ÿ�������ؼ���jmeter��ϵͳ���в˵�
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\jmeter.exe" /ve /d "%JMETER_HOME%\runJmeter.bat" /f
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\jmeter.exe" /v "Path" /d "%JMETER_HOME%" /f
	pause
	goto :EOF
)
if %ERRORLEVEL% equ 4 ( 
	cls
	net.exe session 1>NUL 2>NUL || ( 
		echo ��Ҫ����Ա���,�����´�������ִ��
		goto UACPrompt
	)
	net.exe session 1>NUL 2>NUL || goto UACPrompt
	echo ����.jmx�ű��ļ�����
	reg delete "HKCR\.jmx"  /f
	reg delete "HKCR\jmeterTestFile"  /f
	echo ����jmeter�Ŀ�ʼ���й���
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

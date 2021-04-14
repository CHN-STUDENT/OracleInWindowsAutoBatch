@ECHO OFF&&PUSHD %~DP0
@REM 源码 UTF8 编码，echo 无法输出中文，所以全部写成英语
setlocal EnableDelayedExpansion&&color 4f && cd /d "%~dp0"
TITLE Oracle Database Restore Script
@REM 变量设置开始，如有需要编辑以下部分
set ORCLSID="xe"
set SERVER="127.0.0.1"
set USERNAME="test"
set PASSWORD="test"
set PORT=1521
@REM 备份目录和日志目录设置
set BACKUPPATH="D:\backup\databases"
set NEWTIME=%date:~0,4%-%date:~5,2%-%date:~8,2%-%time:~0,2%-%time:~3,2%-%time:~6,2%
@REM %LOGNAME% 记录控制台输出日志 %IMPLOGNAME% 记录执行备份 imp 输出的日志 
set LOGNAME="D:\backup\logs\%NEWTIME%-restore-log.txt"
set IMPLOGNAME="D:\backup\logs\%NEWTIME%-restore-imp-log.txt"
@REM 发送邮件提醒消息设置
set title="%date%-%time% Oracle Database Restore Log"
set smtpserver="smtp.163.com"
set smtpport=25
set user="test@163.com"
set token="xxx"
set sendto="test@163.com"
@REM 变量设置结束，下部分请勿更改
echo. %date% - %time% Create log file %LOGNAME%.
echo. %date% - %time% Create imp log file %IMPLOGNAME%. >> %LOGNAME%
echo. > %IMPLOGNAME%
if exist %BACKUPPATH% (
    @REM 输出安全警告提示，防止把生产环境搞毁
    echo. %date% - %time% Warning. Do not use this in production environment, you must know what you will do.
    echo. %date% - %time% If you still need to do, please input 'unlock' or input others to exit.
    set /p input=  %date% - %time% Unlock is very dangerous. Please think it over. Your input:
    @REM 输入解锁判断
    if "!input!"=="unlock" (
        cd /d %BACKUPPATH%
        set /p i=  %date% - %time% Press Y To Start Restore or other to exit. Your input:
        if "!i!"=="Y" (
            @REM 调用路径处理函数，防止路径拼贴错误
            call :PathHandler !BACKUPPATH! "latest.dump"
            @REM 判断最新的备份还原文件是否存在
            if exist "%BACKUPPATH%" (
                imp %USERNAME%/%PASSWORD%@%SERVER%:%PORT%/%ORCLSID% file=latest.dump log=%IMPLOGNAME% full=y
                echo. %date% - %time% Restore end.
                echo. %date% - %time% Restore end. >> %LOGNAME%
            ) else (
                echo. %date% - %time% Can not Found The latest backup file, Restore failed.
                echo. %date% - %time% Can not Found The latest backup file, Restore failed. >> %LOGNAME%
            )  
        ) else (
            exit
        )    
    ) else (
        exit
    )
) else (
    echo. %date% - %time% Can not Found Backup Path,Restore failed.    
    echo. %date% - %time% Can not Found Backup Path,Restore failed. >> %LOGNAME%      
)

echo. %date% - %time% Thanks for your use. Press any key to exit.
echo. %date% - %time% Thanks for your use. Press any key to exit. >> %LOGNAME%



@REM 文件编码转换 & 两日志合一
cd /d "%~dp0"
echo. %date% - %time% Convert file encoding.
echo. %date% - %time% Convert file encoding. >> %LOGNAME%
copy %LOGNAME% sendlog.txt /Y 
echo ----------------------------------- >> sendlog.txt
rem echo "备份SQL执行结果:" >> sendlog.txt
type sendlog.txt > send.txt
more +1 %IMPLOGNAME% >> send.txt
ren send.txt send.old
iconv -f GB2312 -t UTF-8 < send.old > send.txt

@REM 发送日志
cd /d "%~dp0"
echo. %date% - %time% Send log file to mail.
echo. %date% - %time% Send log file to mail. >> %LOGNAME%
mailsend-go -sub %title% -smtp %smtpserver% -port %smtpport% auth  -user  %user% -pass %token% -to %sendto% -from %user% -subject %title% -cs "utf8" body -file send.txt

@REM 删除产生文件
echo. %date% - %time% Delete all send temp files.
echo. %date% - %time% Delete all send temp files. >> %LOGNAME%
del sendlog.txt /f /q /a
del send.old /f /q /a
del send.txt /f /q /a

echo. %date% - %time% Thanks for your use. Press any key to exit.
echo. %date% - %time% Thanks for your use. Press any key to exit. >> %LOGNAME%

exit



:PathHandler
@REM 由于直接进行拼贴路径变量会产生引号问题，使用该方法去掉引号。
@REM ref:http://www.bathome.net/viewthread.php?tid=2397
set "filepath=%~1\%~2"
goto:eof
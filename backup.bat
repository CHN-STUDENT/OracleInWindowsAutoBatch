@ECHO OFF&&PUSHD %~DP0
@REM 源码 UTF8 编码，echo 无法输出中文，所以全部写成英语
setlocal EnableDelayedExpansion&&color 3e && cd /d "%~dp0"
@REM 数据库连接变量设置
set ORCLSID="xe"
set SERVER="127.0.0.1"
set USERNAME="test"
set PASSWORD="test"
set PORT=1521
@REM 备份目录和日志目录设置
set BACKUPPATH="D:\backup\databases" 
set BACKUPLOGSPATH="D:\backup\logs" 
@REM 压缩设置
set RARARCHIVEPATH="C:\Program Files\WinRAR\Rar.exe"
@REM 日志输出时间，文件名设置
@REM 2021.4.15 修正日期无法正常使用的问题，参考https://www.cnblogs.com/daysme/p/6571926.html
for /f "tokens=2 delims==" %%a in ('wmic path win32_operatingsystem get LocalDateTime /value') do (set t=%%a)
set NEWTIME=%t:~0,4%-%t:~4,2%-%t:~6,2%-%t:~8,2%-%t:~10,2%-%t:~12,2%
@REM %LOGNAME% 记录控制台输出日志 %OSQLLOGNAME% 记录执行备份 backup.sql 输出的日志 
set LOGNAME="D:\backup\logs\%NEWTIME%-backup-log.txt"
set EXPLOGNAME="D:\backup\logs\%NEWTIME%-backup-exp-log.txt"
@REM 自动删除文件过期备份文件和日志设置，设置为0则不删除
set DAYS=30
@REM 发送邮件提醒消息设置
set title="%date%-%time% Oracle Database Backup Log"
set smtpserver="smtp.163.com"
set smtpport=25
set user="test@163.com"
set token="XXXXX"
set sendto="test@163.com"
@REM 拷贝到远程主机（通过共享映射驱动器实现）
set REMOTEPATH="\\172.16.172.1\backup\databases"
@REM 请勿更改下面的代码
cd /d %BACKUPPATH%
echo. %date% - %time% Now start to backup.
echo. %date% - %time% Now start to backup. >> %LOGNAME%
exp %USERNAME%/%PASSWORD%@%SERVER%:%PORT%/%ORCLSID% file=%NEWTIME%.dump log=%EXPLOGNAME%
@REM 进入工作目录，找到最新的备份文件，并复制为 latest.dump 为还原使用
cd /d %BACKUPPATH%
@REM for /f "tokens=*" %%f in ('dir /b /od /a-d') do (set f=%%f)
echo. %date% - %time% The latest backup file is %NEWTIME%.dump, copy it as latest.dump
echo. %date% - %time% The latest backup file is %NEWTIME%.dump, copy it as latest.dump >> %LOGNAME%
@REM 调用路径处理函数，防止路径拼贴错误
call :PathHandler !BACKUPPATH! %NEWTIME%.dump "latest.dump"
@REM 覆盖复制
copy "!filepath!" "!copypath!" /Y >> %LOGNAME%
echo. %date% - %time% Now start to archive file.
echo. %date% - %time% Now start to archive file. >> %LOGNAME%
%RARARCHIVEPATH% a %NEWTIME%.rar %NEWTIME%.dump >> %LOGNAME%
@REM 删除备份文件
del %NEWTIME%.dump
echo. %date% - %time% Backup end. >> %LOGNAME%
echo. %date% - %time% Backup end. >> %LOGNAME%
if %DAYS% neq 0 (
    echo. %date% - %time% Now start to clean old backup files.
    echo. %date% - %time% Now start to clean old backup files. >> %LOGNAME%
    @REM 根据时间自动删除 %DAYS% 以前的备份文件和日志，若 %DAYS% = 0 则不删除
    forfiles /p %BACKUPPATH% /s /m *.* /d -%DAYS% /c "cmd /c echo del /f /q /a @path" >> %LOGNAME%
    forfiles /p %BACKUPLOGSPATH% /s /m *.* /d -%DAYS% /c "cmd /c echo del /f /q /a @path" >> %LOGNAME%
    echo. %date% - %time% Clean old backup files end. 
    echo. %date% - %time% Clean old backup files end. >> %LOGNAME%
) 

if %COPYTOREMOTE%=="Y" (
    cd /d %BACKUPPATH%
    echo. %date% - %time% Now start to copy backup files to remote.
    echo. %date% - %time% Now start to copy backup files to remote. >> %LOGNAME%
    XCOPY %NEWTIME%.rar %REMOTEPATH%\ /S /E /Y  >>  %LOGNAME%
    echo. %date% - %time% Copy backup files to remote end.
    echo. %date% - %time% Copy backup files to remote end. >> %LOGNAME%
)

@REM 文件编码转换 & 两日志合一
cd /d "%~dp0"
echo. %date% - %time% Convert file encoding.
echo. %date% - %time% Convert file encoding. >> %LOGNAME%
copy %LOGNAME% sendlog.txt /Y 
echo ----------------------------------- >> sendlog.txt
rem echo "备份SQL执行结果:" >> sendlog.txt
type sendlog.txt > send.txt
more +1 %EXPLOGNAME% >> send.txt
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
set "copypath=%~1\%~3"
goto:eof
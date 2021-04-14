@ECHO OFF&&PUSHD %~DP0
@REM 源码 UTF8 编码，echo 无法输出中文，所以全部写成英语
setlocal EnableDelayedExpansion&&color 3e && cd /d "%~dp0"
@REM 数据库连接变量设置
set ORCLSID="xe"
set SERVER="127.0.0.1"
set USERNAME="ekp"
set PASSWORD="ekp"
set PORT=1521
@REM 备份目录和日志目录设置
set BACKUPPATH="D:\backup\databases" 
set BACKUPLOGSPATH="D:\backup\logs" 
@REM 压缩设置
set ARCHIVE=Y
set RARARCHIVEPATH="C:\Program Files\WinRAR\Rar.exe"
@REM 日志输出时间，文件名设置
set NEWTIME=%date:~0,4%-%date:~5,2%-%date:~8,2%-%time:~0,2%-%time:~3,2%-%time:~6,2%
@REM %LOGNAME% 记录控制台输出日志 %OSQLLOGNAME% 记录执行备份 backup.sql 输出的日志 
set LOGNAME="D:\backup\logs\%NEWTIME%-backup-log.txt"
set EXPLOGNAME="D:\backup\logs\%NEWTIME%-backup-exp-log.txt"
@REM 自动删除文件过期备份文件和日志设置，设置为0则不删除
set DAYS=30
@REM 请勿更改下面的代码
cd /d %BACKUPPATH%
echo. %date% - %time% Now start to backup.
echo. %date% - %time% Now start to backup. >> %LOGNAME%
exp %USERNAME%/%PASSWORD%@%SERVER%:%PORT%/%ORCLSID% file=%NEWTIME%.dump log=%EXPLOGNAME%
echo. %date% - %time% Now start to archive file.
echo. %date% - %time% Now start to archive file. >> %LOGNAME%
@REM 进入工作目录，找到最新的备份文件，并复制为 latest.dump 为还原使用
cd /d %BACKUPPATH%
for /f "tokens=*" %%f in ('dir /b /od /a-d') do (set f=%%f)
echo. %date% - %time% The latest backup file is !f!, copy it as latest.dump
echo. %date% - %time% The latest backup file is !f!, copy it as latest.dump >> %LOGNAME%
@REM 调用路径处理函数，防止路径拼贴错误
call :PathHandler !BACKUPPATH! !f! "latest.dump"
@REM 覆盖复制
copy "!filepath!" "!copypath!" /Y >> %LOGNAME%
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
    echo. %date% - %time% Clean old backup files end. >> %LOGNAME%
) 
echo. %date% - %time% Thanks for your use. Press any key to exit.
echo. %date% - %time% Thanks for your use. Press any key to exit. >> %LOGNAME%
pause > nul
exit


:PathHandler
@REM 由于直接进行拼贴路径变量会产生引号问题，使用该方法去掉引号。
@REM ref:http://www.bathome.net/viewthread.php?tid=2397
set "filepath=%~1\%~2"
set "copypath=%~1\%~3"
goto:eof
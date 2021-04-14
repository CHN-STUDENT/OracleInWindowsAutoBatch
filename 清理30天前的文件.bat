@ECHO OFF&PUSHD %~DP0
setlocal EnableDelayedExpansion&color 3e & cd /d "%~dp0"
@REM 备份目录和日志目录设置
set BACKUPPATH="D:\backup\databases" 
set BACKUPLOGSPATH="D:\backup\logs" 
@REM 自动删除文件过期备份文件和日志设置，设置为0则不删除
set DAYS=30
echo ----------------------------------- 
echo Start to delete backup files.
if %DAYS% neq 0 (
    @REM 根据时间自动删除 %DAYS% 以前的备份文件和日志，若 %DAYS% = 0 则不删除
    forfiles /p %BACKUPPATH% /s /m *.* /d -%DAYS% /c "cmd /c echo del /f /q /a @path" 
    forfiles /p %BACKUPLOGSPATH% /s /m *.* /d -%DAYS% /c "cmd /c echo del /f /q /a @path"
    echo. %date% - %time% Clean old backup files end. 
) 
pause > nul
exit
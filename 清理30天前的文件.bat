@ECHO OFF&PUSHD %~DP0
setlocal EnableDelayedExpansion&color 3e & cd /d "%~dp0"
@REM ����Ŀ¼����־Ŀ¼����
set BACKUPPATH="D:\backup\databases" 
set BACKUPLOGSPATH="D:\backup\logs" 
@REM �Զ�ɾ���ļ����ڱ����ļ�����־���ã�����Ϊ0��ɾ��
set DAYS=30
echo ----------------------------------- 
echo Start to delete backup files.
if %DAYS% neq 0 (
    @REM ����ʱ���Զ�ɾ�� %DAYS% ��ǰ�ı����ļ�����־���� %DAYS% = 0 ��ɾ��
    forfiles /p %BACKUPPATH% /s /m *.* /d -%DAYS% /c "cmd /c echo del /f /q /a @path" 
    forfiles /p %BACKUPLOGSPATH% /s /m *.* /d -%DAYS% /c "cmd /c echo del /f /q /a @path"
    echo. %date% - %time% Clean old backup files end. 
) 
pause > nul
exit
@ECHO OFF&PUSHD %~DP0
setlocal EnableDelayedExpansion&color 3e & cd /d "%~dp0"
echo ----------------------------------- 
echo �����Զ���ʱ����
schtasks  /create  /tn  backup /tr  D:\backup\backup.bat  /sc  DAILY /st  01:30:00
echo ----------------------------------- 
echo �鿴�Զ���ʱ����
schtasks  /Query  /tn backup 
echo ----------------------------------- 
rem ɾ���Զ���ʱ����
rem schtasks /Delete /tn backup 
pause > nul
exit
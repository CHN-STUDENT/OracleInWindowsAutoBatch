@ECHO OFF&PUSHD %~DP0
setlocal EnableDelayedExpansion&color 3e & cd /d "%~dp0"
echo ----------------------------------- 
echo 创建自动定时任务
schtasks  /create  /tn  backup /tr  D:\backup\backup.bat  /sc  DAILY /st  01:30:00
echo ----------------------------------- 
echo 查看自动定时任务
schtasks  /Query  /tn backup 
echo ----------------------------------- 
rem 删除自动定时任务
rem schtasks /Delete /tn backup 
pause > nul
exit
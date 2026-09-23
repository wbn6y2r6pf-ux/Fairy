@echo off
chcp 936 >nul
title Fairy 一键安装
setlocal

rem ============================================================
rem  Fairy 一键安装（Fairy-DSH 语音桌宠）
rem  双击本文件即可。需要管理员权限的地方一处也没有，
rem  直接双击运行即可，不要右键"以管理员身份运行"。
rem ============================================================

set "HERE=%~dp0"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if not exist "%PS%" goto no_ps
if not exist "%HERE%payload" goto no_payload
if not exist "%HERE%install.ps1" goto no_script

echo ============================================================
echo   Fairy 一键安装
echo ============================================================
echo.
echo   本安装包内容:
echo     payload/            程序文件(约 1.5GB)
echo     Fairy-Data-*.zip    数据包(GPT-SoVITS 11GB, 可选但语音必需)
echo.
echo   完整安装约需 13GB 磁盘空间、10-25 分钟。
echo   安装过程中请不要关闭本窗口。
echo.
pause

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%HERE%install.ps1"
set "RC=%errorlevel%"

echo.
if not "%RC%"=="0" goto failed
echo ============================================================
echo   安装结束 (退出码 0)
echo ============================================================
pause
exit /b 0

:failed
echo ============================================================
echo   安装未成功完成 (退出码 %RC%)
echo ============================================================
echo   请看上方红字提示。常见原因:
echo     1. 数据包没和本文件放在同一个目录
echo     2. 目标磁盘空间不足
echo     3. 安装目录被占用(先把 Fairy 服务全部停掉)
echo.
echo   详细日志: %TEMP%\fairy-install-*.log
echo.
pause
exit /b %RC%

:no_ps
echo [错误] 找不到 PowerShell: %PS%
echo       本安装器依赖 Windows 自带的 PowerShell 5.1
pause
exit /b 1

:no_payload
echo [错误] 安装包不完整: 缺少 payload 目录
echo       请确认 zip 已完整解压（不要直接在压缩包里运行本文件）
pause
exit /b 1

:no_script
echo [错误] 安装包不完整: 缺少 install.ps1
pause
exit /b 1

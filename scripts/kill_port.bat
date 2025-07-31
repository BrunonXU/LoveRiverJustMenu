@echo off
setlocal enabledelayedexpansion

if "%1"=="" (
    echo ❌ 错误：请指定端口号
    echo 用法: kill_port.bat [端口号]
    echo 示例: kill_port.bat 5001
    exit /b 1
)

set PORT=%1
echo 🔍 查找占用端口 %PORT% 的进程...
echo.

for /f "tokens=5" %%a in ('netstat -ano ^| findstr :%PORT%') do (
    set PID=%%a
    if !PID! NEQ 0 (
        echo 发现进程 PID: !PID!
        tasklist /fi "PID eq !PID!" 2>nul | findstr !PID! >nul
        if !errorlevel! EQU 0 (
            for /f "tokens=1" %%b in ('tasklist /fi "PID eq !PID!" ^| findstr !PID!') do (
                echo 进程名: %%b
            )
            echo 正在终止进程...
            taskkill /F /PID !PID! >nul 2>&1
            if !errorlevel! EQU 0 (
                echo ✅ 成功终止进程 !PID!
            ) else (
                echo ❌ 无法终止进程 !PID! (可能需要管理员权限)
            )
            echo.
        )
    )
)

echo ✅ 端口 %PORT% 清理完成！
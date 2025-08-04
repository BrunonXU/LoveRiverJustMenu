@echo off
echo 🚀 启动Flutter Web (固定端口5001)...
echo.

REM 先清理端口
echo 🧹 检查并清理端口5001...
call scripts\kill_port.bat 5001
echo.

echo 📌 启动地址: http://localhost:5001
echo.
echo ⚠️  重要提示：
echo    1. 确保在Google Console配置了以下URI:
echo       - http://localhost:5001
echo       - http://localhost:5001/__/auth/handler
echo.
echo    2. Firebase Console添加授权域名:
echo       - localhost
echo.
echo 🔥 正在启动Flutter Web...
echo.

flutter run -d chrome --web-port=5001
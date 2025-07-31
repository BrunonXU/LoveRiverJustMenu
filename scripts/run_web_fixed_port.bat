@echo off
echo 🚀 启动Flutter Web (固定端口5000)...
echo.
echo 📌 访问地址: http://localhost:5000
echo.
echo ⚠️  确保已在Google Console配置了:
echo    - http://localhost:5000
echo    - http://localhost:5000/__/auth/handler
echo.
flutter run -d chrome --web-port=5000
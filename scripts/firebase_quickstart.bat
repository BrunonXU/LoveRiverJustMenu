@echo off
echo 🔥 Firebase快速配置向导
echo =====================================

echo.
echo 📋 这个脚本将帮助你完成Firebase配置
echo.

echo 步骤1: 检查当前配置状态
dart scripts/check_firebase_setup.dart

echo.
pause
echo.

echo 步骤2: 更新Firebase配置（如果需要）
echo 如果上面的检查发现占位符配置，请运行：
echo dart scripts/update_firebase_config.dart
echo.

echo 步骤3: 构建并测试应用
echo flutter clean
echo flutter pub get
echo flutter build web --release
echo.

echo 步骤4: 运行应用测试
echo flutter run -d chrome --web-port 3000
echo.

echo 📖 详细配置说明请参考：FIREBASE_SETUP_GUIDE.md
echo.

pause
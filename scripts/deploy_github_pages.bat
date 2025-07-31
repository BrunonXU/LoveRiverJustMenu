@echo off
REM GitHub Pages 部署脚本 (Windows版本)
REM 用于构建和部署 Flutter Web 应用到 GitHub Pages

echo 🚀 开始部署到 GitHub Pages...

REM 1. 清理之前的构建
echo 🧹 清理旧的构建文件...
call flutter clean

REM 2. 获取依赖
echo 📦 获取项目依赖...
call flutter pub get

REM 3. 构建 Web 版本（使用正确的 base href）
echo 🔨 构建 Web 应用...
REM 注意：将 YOUR_GITHUB_USERNAME 替换为你的 GitHub 用户名
call flutter build web --release --base-href "/LoveRiverJustMenu/"

REM 4. 进入构建目录
echo 📁 准备部署文件...
cd build\web

REM 5. 初始化 git
git init

REM 6. 添加所有文件
git add -A

REM 7. 提交
git commit -m "Deploy to GitHub Pages"

REM 8. 推送到 gh-pages 分支
REM 注意：将 YOUR_GITHUB_USERNAME 替换为你的 GitHub 用户名
echo 📤 推送到 GitHub Pages...
git push -f https://github.com/YOUR_GITHUB_USERNAME/LoveRiverJustMenu.git master:gh-pages

echo ✅ 部署完成！
echo 🌐 请访问: https://YOUR_GITHUB_USERNAME.github.io/LoveRiverJustMenu
echo.
echo ⚠️  注意事项：
echo 1. 确保已在 Firebase Console 中添加授权域名: YOUR_GITHUB_USERNAME.github.io
echo 2. 第一次部署可能需要等待几分钟才能生效
echo 3. 如果遇到 404 错误，请检查 GitHub 仓库设置中的 Pages 配置

cd ..\..\
pause
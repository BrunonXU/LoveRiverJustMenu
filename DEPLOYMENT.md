# 🚀 Flutter Web应用部署指南

## 📋 目录
- [部署原理](#部署原理)
- [分支结构](#分支结构)
- [部署流程](#部署流程)
- [自定义域名配置](#自定义域名配置)
- [常见问题](#常见问题)
- [故障排除](#故障排除)

---

## 🔍 部署原理

### Flutter Web vs 传统网页
```
传统网页部署:
HTML + CSS + JS 文件 → 直接部署到服务器

Flutter Web部署:
Dart源代码 → Flutter编译 → HTML + CSS + JS静态文件 → 部署到服务器
```

**关键点**：
- Flutter Web应用最终都是**静态文件**（HTML/CSS/JavaScript）
- 无论使用GitHub Pages还是Cloudflare，本质都是托管静态文件
- `main.dart.js`是Flutter将Dart代码编译后的JavaScript文件

---

## 📂 分支结构

### main分支（开发分支）
```
LoveRiverJustMenu/
├── lib/              # Dart源代码
├── web/              # 模板文件
├── pubspec.yaml      # 依赖配置
├── CLAUDE.md         # 开发指南
└── DEPLOYMENT.md     # 本文档
```

### gh-pages分支（部署分支）
```
LoveRiverJustMenu/
├── index.html        # 从web/index.html生成
├── main.dart.js      # Flutter编译生成
├── manifest.json     # 从web/manifest.json生成
├── assets/           # 资源文件
├── canvaskit/        # Flutter Web引擎
└── flutter_service_worker.js # Service Worker
```

**重要理解**：
- `main`分支包含源代码，开发者在此工作
- `gh-pages`分支仅包含编译后的静态文件，用户访问的就是这些文件
- 两个分支内容完全不同，**不能直接合并**

---

## 🔄 部署流程

### 1. 开发阶段（main分支）
```bash
# 在main分支开发
git checkout main

# 修改源代码...
# 编辑 lib/ 目录下的Dart文件
# 编辑 web/ 目录下的模板文件
```

### 2. 构建阶段
```bash
# 构建Web版本
flutter build web --release --base-href="/"

# 生成的文件在 build/web/ 目录
```

**构建过程解析**：
```
web/index.html (模板) → build/web/index.html (实际文件)
web/manifest.json (模板) → build/web/manifest.json (实际文件)
lib/**/*.dart (源代码) → build/web/main.dart.js (编译后)
```

### 3. 部署阶段
```bash
# 切换到gh-pages分支
git checkout --orphan gh-pages

# 清空分支内容
git rm -rf .

# 复制构建文件
cp -r build/web/* .

# 提交部署
git add .
git commit -m "🚀 部署更新"
git push origin gh-pages
```

### 4. 自动化脚本
```bash
#!/bin/bash
# deploy.sh - 一键部署脚本

echo "🔄 开始部署流程..."

# 1. 构建
echo "🏗️ 构建应用..."
flutter build web --release --base-href="/"

# 2. 切换分支
echo "🔀 切换到gh-pages分支..."
git checkout gh-pages || git checkout --orphan gh-pages

# 3. 清理和复制
echo "📋 更新文件..."
git rm -rf . 2>/dev/null || true
cp -r build/web/* .

# 4. 提交
echo "📤 提交更改..."
git add .
git commit -m "🚀 自动部署 $(date)"
git push origin gh-pages

# 5. 返回主分支
git checkout main
echo "✅ 部署完成！"
```

---

## 🌐 自定义域名配置

### GitHub Pages设置
1. 仓库设置 → Pages → Custom domain → `xuziang.xyz`
2. 自动创建`CNAME`文件，内容为域名

### DNS配置（Cloudflare）
```
类型    名称    内容
CNAME   @       username.github.io
CNAME   www     username.github.io
```

### 关键配置文件

#### web/index.html (模板)
```html
<!-- 自定义域名使用根路径 -->
<base href="$FLUTTER_BASE_HREF">

<!-- 构建时会替换为 -->
<base href="/">
```

#### 错误示例
```html
<!-- ❌ 错误：仓库名路径（仅适用于 username.github.io/repo 格式） -->
<base href="/LoveRiverJustMenu/">

<!-- ✅ 正确：自定义域名使用根路径 -->
<base href="/">
```

---

## ❓ 常见问题

### Q1: 为什么需要两个分支？
**A**: 源代码和产品代码分离
- `main`分支：开发用，包含Dart源代码、配置文件等
- `gh-pages`分支：生产用，只包含浏览器能执行的HTML/CSS/JS

### Q2: 为什么要使用静态文件？
**A**: GitHub Pages和Cloudflare Pages都是**静态网站托管服务**
- 不支持运行服务器端代码（PHP、Node.js等）
- 只能托管静态文件（HTML、CSS、JavaScript）
- Flutter Web编译后就是静态文件，完美适配

### Q3: main.dart.js是什么？
**A**: Flutter编译产物
```
你的Dart代码 → Flutter编译器 → main.dart.js
包含了整个应用的逻辑
```

### Q4: web/目录和build/web/的区别？
**A**: 
- `web/`：模板文件，开发时编辑
- `build/web/`：构建产物，实际部署的文件

### Q5: 为什么图标会404？
**A**: 模板文件引用了不存在的文件
```html
<!-- ❌ 错误：引用外部文件 -->
<link rel="icon" href="favicon.png"/>

<!-- ✅ 正确：使用内联SVG -->
<link rel="icon" href="data:image/svg+xml,..."/>
```

---

## 🔧 故障排除

### 404错误：main.dart.js
**原因**：base href配置错误
```bash
# 检查build/web/index.html中的base href
# 自定义域名应该是 <base href="/">
# GitHub子页面应该是 <base href="/仓库名/">

# 重新构建
flutter build web --release --base-href="/"
```

### 404错误：图标文件
**原因**：引用了不存在的文件
```bash
# 检查web/index.html模板文件
# 将外部图标引用改为内联SVG
```

### 页面显示空白
**原因**：JavaScript加载失败
```bash
# 检查浏览器控制台错误
# 通常是路径配置问题
```

### 修改后没有生效
**解决步骤**：
```bash
# 1. 清理构建缓存
flutter clean

# 2. 重新获取依赖
flutter pub get

# 3. 重新构建
flutter build web --release

# 4. 重新部署到gh-pages
```

### DNS未生效
```bash
# 检查DNS配置
nslookup xuziang.xyz

# 清除浏览器缓存
# Cloudflare刷新缓存
```

---

## ⚡ 性能优化建议

### 1. 启用Web优化
```yaml
# flutter build web时的优化选项
flutter build web --release --web-renderer html --tree-shake-icons
```

### 2. 资源压缩
```html
<!-- 在index.html中启用压缩 -->
<script>
  // 启用Service Worker缓存
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('flutter_service_worker.js');
  }
</script>
```

### 3. CDN加速
- Cloudflare会自动提供CDN加速
- GitHub Pages在全球有CDN节点

---

## 📊 部署检查清单

### 部署前检查
- [ ] 源代码在main分支已提交
- [ ] `flutter build web`构建成功
- [ ] base href配置正确
- [ ] 图标文件使用内联SVG
- [ ] 本地测试通过

### 部署后检查
- [ ] 网站能正常访问
- [ ] 没有404错误（检查浏览器控制台）
- [ ] 图标正常显示
- [ ] 所有页面功能正常
- [ ] 移动端适配正常

---

## 🔄 更新流程

### 日常更新
1. 在`main`分支开发新功能
2. 测试完成后执行部署脚本
3. 验证线上功能正常

### 紧急修复
1. 在`main`分支修复问题
2. 立即构建并部署
3. 通知用户刷新页面

---

*最后更新：2025-08-08*  
*版本：1.0*  
*作者：Claude Code*
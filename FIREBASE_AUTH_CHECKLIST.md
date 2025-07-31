# Firebase 认证配置检查清单

## 🔥 Firebase Console 配置

### 1. Authentication → Settings → Authorized domains
- [ ] localhost (用于本地开发)
- [ ] brunonxu.github.io (用于GitHub Pages)
- [ ] 127.0.0.1 (某些情况下需要)

### 2. 确认启用的登录方式
- [ ] 电子邮件/密码
- [ ] Google
- [ ] 匿名登录

## 🌐 Google Cloud Console 配置

### 1. APIs & Services → Credentials → OAuth 2.0 Client IDs
找到你的Web客户端ID，编辑并添加：

**Authorized JavaScript origins (授权的JavaScript来源)：**
- [ ] http://localhost
- [ ] http://localhost:5000
- [ ] https://brunonxu.github.io

**Authorized redirect URIs (授权的重定向URI)：**
- [ ] http://localhost/__/auth/handler
- [ ] http://localhost:5000/__/auth/handler
- [ ] https://brunonxu.github.io/LoveRiverJustMenu/__/auth/handler
- [ ] https://brunonxu.github.io/LoveRiverJustMenu/

### 2. APIs & Services → OAuth consent screen
- [ ] 发布状态：Testing（测试模式）
- [ ] 测试用户：添加你的Gmail邮箱
- [ ] Authorized domains：添加 brunonxu.github.io

### 3. APIs & Services → Enabled APIs
确保已启用：
- [ ] Google+ API 或 People API
- [ ] Identity Toolkit API

## 🔧 代码配置检查

### 1. web/index.html
```html
<!-- 确保有Google Sign-In SDK -->
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

### 2. firebase_options.dart
确保配置正确，特别是：
- apiKey
- authDomain
- projectId
- appId

## 🧪 测试步骤

1. **本地测试**
   ```bash
   flutter run -d chrome --web-port=5000
   ```
   访问：http://localhost:5000

2. **线上测试**
   访问：https://brunonxu.github.io/LoveRiverJustMenu/

## ❌ 常见错误及解决方案

### 1. "redirect_uri_mismatch"
- 原因：重定向URI不匹配
- 解决：在Google Cloud Console添加正确的重定向URI

### 2. "popup_blocked_by_browser"
- 原因：浏览器阻止弹窗
- 解决：确保用户直接点击按钮触发登录

### 3. "People API has not been used"
- 原因：People API未启用
- 解决：在Google Cloud Console启用People API

### 4. "unauthorized domain"
- 原因：域名未授权
- 解决：在Firebase和Google Console添加域名

## 🚀 快速修复脚本

如果你看到具体的错误信息，请提供错误截图或文本，我可以给出精确的解决方案。
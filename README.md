# 爱心食谱 - Love Recipe

极简高级美食菜谱应用 - 为爱下厨，记录美食与情感

## 🎨 设计理念

- **95%黑白灰，5%彩色焦点**
- **零按钮设计，全手势操作**
- **大量留白，极致简约**
- **自然物理动画，呼吸感设计**

## 🚀 快速开始

### 环境要求

- Flutter 3.16.0 或更高版本
- Dart 3.0.0 或更高版本
- 支持 Web、iOS、Android 平台

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/BrunoXU/LoveRiverJustMenu.git
cd LoveRiverJustMenu
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行项目**

移动端：
```bash
flutter run
```

Web端：
```bash
flutter run -d chrome
```

构建Web版本：
```bash
flutter build web --release --web-renderer html
```

## 📱 功能特性

### 已完成
- ✅ 核心架构（Riverpod + GoRouter）
- ✅ 设计系统（95%黑白灰原则）
- ✅ 极简卡片组件（呼吸动画）
- ✅ 手势识别系统（轨迹可视化）
- ✅ Web自适应支持
- ✅ GitHub Pages部署配置

### 开发中
- 🔄 时间驱动主界面
- 🔄 3D扁平化图标系统
- 🔄 语音交互功能
- 🔄 AI智能推荐系统

## 🌐 Web部署

项目已配置GitHub Actions自动部署到GitHub Pages：

1. 在GitHub仓库设置中启用GitHub Pages
2. 选择"GitHub Actions"作为源
3. 推送到main分支将自动触发部署

访问地址：`https://yourusername.github.io/LoveRiverJustMenu/`

## 🛠️ 技术栈

- **框架**: Flutter 3.16.0
- **状态管理**: Riverpod 2.0
- **路由**: go_router
- **动画**: flutter_animate + 自定义动画系统
- **本地存储**: Hive
- **Web支持**: 完整响应式布局

## 📐 设计规范

### 色彩系统
- 背景色: #FFFFFF (纯白)
- 主文字: #000000 (纯黑)
- 辅助文字: #999999 (中灰)
- 焦点色: #5B6FED → #8B9BF3 (蓝紫渐变)

### 字体规范
- 字重: 100(超轻) / 300(轻) / 500(中等)
- 禁用粗体
- 基准字号: 16px

### 间距系统
- 基础单位: 8px
- 页面边距: 48px
- 卡片圆角: 24px

## 🤝 贡献指南

欢迎贡献代码！请确保：
- 严格遵循设计规范
- 保持60FPS性能
- 添加必要的测试

## 📄 许可证

MIT License

## 👥 团队

为爱而生的极简设计团队
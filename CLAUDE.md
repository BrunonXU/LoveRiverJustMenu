# 爱心食谱 Flutter 开发指南 - Claude Code

## 项目概述

你正在开发一个名为"爱心食谱"的Flutter应用，这是一个**极简高级**的情侣菜谱分享应用。请严格遵循以下设计理念和开发规范。

### 核心设计理念
- **95%黑白灰，5%彩色焦点**
- **零按钮设计，全手势操作**
- **大量留白，极致简约**
- **自然物理动画，呼吸感设计**

---

## 🎨 设计规范（必须严格遵守）

### 1. 色彩使用规则

```dart
// 基础色（95%使用）
const Color backgroundColor = Color(0xFFFFFFFF);  // 纯白背景
const Color textPrimary = Color(0xFF000000);      // 纯黑主文字
const Color backgroundSecondary = Color(0xFFF7F7F7); // 高级灰背景
const Color textSecondary = Color(0xFF999999);    // 中灰辅助文字

// 焦点渐变色（仅5%使用）
const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)], // 蓝紫渐变
);
const LinearGradient emotionGradient = LinearGradient(
  colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)], // 橙粉渐变
);

// ❌ 错误示例：不要使用其他颜色
// ❌ 不要使用 Colors.blue, Colors.red 等预设颜色
// ❌ 不要使用超过5%的彩色
```

### 2. 字体规范

```dart
// 字重使用（仅使用这三种）
FontWeight ultralight = FontWeight.w100;  // 仅用于超大标题(48px+)
FontWeight light = FontWeight.w300;       // 主要内容
FontWeight medium = FontWeight.w500;      // 强调文字

// ❌ 禁止使用 FontWeight.bold (w700)

// 字号体系
const double displayLarge = 48;   // 时间显示
const double titleLarge = 32;     // 页面标题
const double titleMedium = 24;    // 卡片标题
const double bodyLarge = 18;      // 重要信息
const double bodyMedium = 16;     // 正文
const double bodySmall = 14;      // 辅助信息
const double caption = 12;        // 最小文字
```

### 3. 间距系统

```dart
// 基础间距单位（8的倍数）
const double space_xs = 4;    // 紧密间距
const double space_sm = 8;    // 元素内间距
const double space_md = 16;   // 相关元素间距
const double space_lg = 24;   // 模块内间距
const double space_xl = 48;   // 页面边距（重要！）
const double space_xxl = 64;  // 大模块间距

// 所有 padding 和 margin 必须使用上述常量
// ✅ padding: EdgeInsets.all(space_xl)
// ❌ padding: EdgeInsets.all(20)
```

### 4. 组件设计规则

```dart
// 卡片设计
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24), // 固定圆角
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08), // 固定阴影
        blurRadius: 32,
        offset: Offset(0, 8),
      ),
    ],
  ),
  padding: EdgeInsets.all(space_xl), // 48px内边距
  child: // content
)

// ❌ 禁止使用 ElevatedButton, OutlinedButton 等Material按钮
// ✅ 使用手势识别器 + 自定义容器
```

---

## 🚀 Flutter 开发规范

### 1. 项目结构

```
lib/
├── core/
│   ├── animations/      # 动画系统
│   │   ├── breathing_animation.dart
│   │   ├── liquid_transition.dart
│   │   └── physics_engine.dart
│   ├── gestures/       # 手势系统
│   │   ├── gesture_recognizer.dart
│   │   ├── gesture_visualizer.dart
│   │   └── haptic_feedback.dart
│   ├── themes/         # 主题系统
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── spacing.dart
│   └── utils/          # 工具类
│
├── features/           # 功能模块
│   ├── home/          # 主页
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── domain/
│   ├── timeline/      # 3D时光机
│   ├── ai_recommendation/ # AI推荐
│   └── cooking_mode/  # 烹饪模式
│
├── shared/            # 共享组件
│   ├── widgets/
│   │   ├── breathing_widget.dart
│   │   ├── minimal_card.dart
│   │   └── gesture_detector_plus.dart
│   └── models/
│
└── main.dart
```

### 2. 状态管理

```dart
// 使用 Riverpod 2.0
// ✅ 正确示例
final recipeProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) {
  return RecipeNotifier();
});

// 状态类必须是 immutable
@immutable
class Recipe {
  final String id;
  final String name;
  final int cookTime;
  
  const Recipe({
    required this.id,
    required this.name,
    required this.cookTime,
  });
}
```

### 3. 动画实现

```dart
// 所有动画必须保持 60FPS
class BreathingWidget extends StatefulWidget {
  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 4), // 呼吸周期4秒
      vsync: this,
    )..repeat(reverse: true);
  }
  
  // 使用 Transform 和 Opacity，避免触发重排
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.02), // 最大缩放1.02
          child: Opacity(
            opacity: 0.8 + (_controller.value * 0.2),
            child: widget.child,
          ),
        );
      },
    );
  }
}
```

### 4. 手势系统实现

```dart
// 手势识别必须包含触觉反馈
class CustomGestureDetector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -50) {
          HapticFeedback.lightImpact(); // 轻触反馈
          // 上滑逻辑
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 300) {
          HapticFeedback.mediumImpact(); // 中等反馈
          // 右滑逻辑
        }
      },
      child: // content
    );
  }
}

// 手势可视化轨迹
class GestureTrailPainter extends CustomPainter {
  final List<Offset> points;
  
  @override
  void paint(Canvas canvas, Size size) {
    // 渐变轨迹绘制
    for (int i = 1; i < points.length; i++) {
      final paint = Paint()
        ..color = Color(0xFFFF6B6B).withOpacity(i / points.length)
        ..strokeWidth = 3.0 * (i / points.length);
      
      canvas.drawLine(points[i - 1], points[i], paint);
    }
  }
}
```

### 5. 性能要求

```dart
// 监控 FPS
void main() {
  // 开发模式下显示性能浮层
  if (kDebugMode) {
    WidgetsApp.debugAllowBannerOverride = false;
  }
  
  runApp(MyApp());
}

// 图片加载优化
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => ShimmerSkeleton(), // 骨架屏
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheHeight: 400, // 内存缓存优化
  memCacheWidth: 300,
)

// 列表优化
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    // 使用 const 构造函数
    return const MinimalCard();
  },
  // 优化滚动性能
  cacheExtent: 100,
)
```

---

## 📝 开发指令

### 1. 创建新页面时

```bash
# 指令格式
"创建一个新的[页面名称]页面，遵循极简设计，包含呼吸动画和手势识别"

# 必须包含的元素：
- 纯白背景
- 48px边距
- 单一焦点卡片
- 呼吸动画效果
- 上下滑动手势
- 无任何按钮
```

### 2. 实现动画时

```bash
# 指令格式
"实现[动画名称]，持续时间[X]秒，使用贝塞尔曲线"

# 动画规范：
- 只使用 Transform 和 Opacity
- 必须达到 60FPS
- 包含物理特性（重力、弹性）
- 自然的缓动函数
```

### 3. 添加手势时

```bash
# 指令格式
"添加[手势类型]识别，触发[功能]，包含触觉反馈"

# 手势规范：
- 包含轨迹可视化
- 添加触觉反馈
- 阈值设置合理（50px）
- 支持组合手势
```

### 4. 性能优化时

```bash
# 指令格式
"优化[页面/组件]性能，确保流畅度"

# 优化清单：
- [ ] RepaintBoundary 隔离动画区域
- [ ] const 构造函数
- [ ] 图片预加载和缓存
- [ ] 减少 Widget 重建
- [ ] 使用 ValueListenableBuilder
```

---

## ⚠️ 禁止事项

### UI 设计禁止

```dart
// ❌ 禁止使用以下组件：
- ElevatedButton    // 使用自定义手势容器
- FloatingActionButton // 使用自定义悬浮组件  
- AppBar           // 使用自定义顶部布局
- BottomNavigationBar // 使用手势导航
- Drawer           // 使用边缘滑入手势

// ❌ 禁止使用 Material Design 预设样式
// ❌ 禁止使用超过3种字重
// ❌ 禁止使用 bold 字体
// ❌ 禁止添加装饰性元素
```

### 代码规范禁止

```dart
// ❌ 禁止硬编码数值
padding: EdgeInsets.all(20), // 错误
padding: EdgeInsets.all(space_lg), // 正确

// ❌ 禁止使用 setState 进行复杂状态管理
// ❌ 禁止在 build 方法中进行计算
// ❌ 禁止创建超过3个同时运行的动画
// ❌ 禁止使用会触发重排的动画属性
```

---

## 🎯 核心功能实现指南

### 1. 时间驱动主页

```dart
// 根据时间自动切换内容
String getTimeOfDay() {
  final hour = DateTime.now().hour;
  if (hour >= 6 && hour < 12) return 'morning';
  if (hour >= 12 && hour < 17) return 'afternoon';
  if (hour >= 17 && hour < 22) return 'evening';
  return 'night';
}

// 背景渐变随时间变化
Color getBackgroundGradient() {
  switch (getTimeOfDay()) {
    case 'morning':
      return Color(0xFFFFF5E6); // 晨光色
    case 'afternoon':
      return Color(0xFFFFF8DC); // 午后暖黄
    case 'evening':
      return Color(0xFFFFE4E1); // 晚霞粉
    case 'night':
      return Color(0xFF191970); // 夜空蓝
  }
}
```

### 2. 3D时光机实现

```dart
// 使用 Transform 创建3D效果
Transform(
  transform: Matrix4.identity()
    ..setEntry(3, 2, 0.001) // 透视效果
    ..rotateY(rotationY)
    ..scale(scale),
  alignment: Alignment.center,
  child: // 记忆卡片
)

// 螺旋布局算法
Offset calculateSpiralPosition(int index, int total) {
  final angle = (index / total) * 2 * pi;
  final radius = 150.0;
  final x = sin(angle) * radius;
  final z = cos(angle) * radius;
  final y = index * 50.0;
  return Offset(x, y);
}
```

### 3. AI推荐故事化

```dart
// 故事化文案生成
String generateStoryNarrative(WeatherData weather, UserPreference preference) {
  if (weather.temperature < 15) {
    return "今晚降到${weather.temperature}度，一碗热汤最暖心";
  }
  // 更多情境判断...
}

// 推荐卡片必须包含：
// 1. 情境标签（天气/时间/事件）
// 2. 对话式文案
// 3. 单一推荐（避免选择困难）
// 4. 推荐理由
```

---

## 📱 测试要求

### 性能测试

```dart
// 在 main.dart 添加性能监控
void main() {
  // FPS 监控
  WidgetsBinding.instance.addTimingsCallback((timings) {
    timings.forEach((timing) {
      if (timing.totalSpan.inMilliseconds > 16) {
        print('Frame exceeded 16ms: ${timing.totalSpan.inMilliseconds}ms');
      }
    });
  });
  
  runApp(MyApp());
}
```

### 手势测试

```dart
// 测试手势识别准确率
testWidgets('Swipe gesture test', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 模拟上滑
  await tester.drag(find.byType(GestureDetector), Offset(0, -100));
  await tester.pumpAndSettle();
  
  // 验证页面切换
  expect(find.text('下一个内容'), findsOneWidget);
});
```

---

## 🚨 紧急修复指南

### 性能问题

```bash
# 如果FPS低于60
1. 检查同时运行的动画数量
2. 使用 RepaintBoundary 隔离动画
3. 确保只使用 Transform 和 Opacity
4. 检查是否有在 build 中的计算

# 如果内存占用过高
1. 检查图片缓存设置
2. 及时 dispose 动画控制器
3. 使用 const 构造函数
4. 避免内存泄漏
```

### UI 不符合设计

```bash
# 检查清单
- [ ] 是否使用了正确的间距常量？
- [ ] 是否遵循95%黑白灰原则？
- [ ] 是否有多余的装饰元素？
- [ ] 是否使用了禁止的组件？
- [ ] 动画是否流畅自然？
```

---

## 最终检查清单

开发完成后，请确认：

- [ ] 所有页面都有呼吸动画
- [ ] 没有使用任何传统按钮
- [ ] 手势操作流畅且有反馈
- [ ] 遵循95%黑白灰原则
- [ ] 页面边距使用48px
- [ ] FPS保持在60
- [ ] 内存占用<150MB
- [ ] 所有文字使用指定字重
- [ ] 动画使用自然缓动
- [ ] 代码结构清晰规范

记住：**简约不是简单，而是把复杂藏在优雅的表象之下**。
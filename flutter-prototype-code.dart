// main.dart - 主应用入口
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const LoveRecipeApp());
}

class LoveRecipeApp extends StatelessWidget {
  const LoveRecipeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '爱心食谱',
      theme: ThemeData(
        fontFamily: 'PingFang SC',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF5B6FED),
          secondary: Color(0xFFFF6B6B),
          background: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// 主界面 - 时间驱动的卡片流
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _cardController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _cardAnimation;
  
  int _currentIndex = 0;
  double _dragOffset = 0;
  
  // 获取当前时段
  String get timeOfDay {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 22) return 'evening';
    return 'night';
  }
  
  // 获取问候语
  Map<String, dynamic> get greeting {
    final greetings = {
      'morning': {'text': '早安', 'icon': Icons.wb_sunny, 'color': Color(0xFFFFF5E6)},
      'afternoon': {'text': '午后好', 'icon': Icons.coffee, 'color': Color(0xFFFFF8DC)},
      'evening': {'text': '晚上好', 'icon': Icons.dinner_dining, 'color': Color(0xFFFFE4E1)},
      'night': {'text': '夜深了', 'icon': Icons.bedtime, 'color': Color(0xFF191970)},
    };
    return greetings[timeOfDay] ?? greetings['morning']!;
  }

  @override
  void initState() {
    super.initState();
    
    // 呼吸动画控制器
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // 卡片动画控制器
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greetingData = greeting;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [greetingData['color'], Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 时间感知顶部
              _buildTimeAwareHeader(greetingData),
              
              // 主卡片区域
              Expanded(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _dragOffset = details.delta.dy;
                    });
                  },
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy < -300) {
                      // 上滑 - 下一个
                      _nextCard();
                    } else if (details.velocity.pixelsPerSecond.dy > 300) {
                      // 下滑 - 上一个或创建
                      if (_currentIndex == 0) {
                        _showCreateMode();
                      } else {
                        _previousCard();
                      }
                    }
                    setState(() {
                      _dragOffset = 0;
                    });
                  },
                  child: Center(
                    child: _buildRecipeCard(),
                  ),
                ),
              ),
              
              // 隐形导航提示
              _buildNavigationHint(),
            ],
          ),
        ),
      ),
      
      // 语音按钮
      floatingActionButton: _buildVoiceButton(),
    );
  }
  
  Widget _buildTimeAwareHeader(Map<String, dynamic> greetingData) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(greetingData['icon'], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    greetingData['text'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _getSmartSuggestion(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getCurrentTime(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w100,
                ),
              ),
              Text(
                '24°C 适合热饮',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecipeCard() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: Container(
              width: 320,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D扁平图标
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.ramen_dining,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 菜名
                  Text(
                    _getCurrentRecipe()['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${_getCurrentRecipe()['time']}分钟',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildNavigationHint() {
    return Container(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Icon(
            Icons.keyboard_arrow_up,
            color: Colors.black.withOpacity(0.3),
            size: 20,
          ),
          Text(
            '滑动探索',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVoiceButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        onPressed: _showVoiceInterface,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }
  
  // 辅助方法
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
  
  String _getSmartSuggestion() {
    final suggestions = {
      'morning': '来份营养早餐开启美好一天',
      'afternoon': '下午茶时间，来点轻食吧',
      'evening': '今晚想为她做点什么呢',
      'night': '要不要来点夜宵',
    };
    return suggestions[timeOfDay] ?? '探索更多美味';
  }
  
  Map<String, dynamic> _getCurrentRecipe() {
    final recipes = [
      {'name': '银耳莲子羹', 'time': 20},
      {'name': '番茄鸡蛋面', 'time': 15},
      {'name': '红烧排骨', 'time': 45},
    ];
    return recipes[_currentIndex % recipes.length];
  }
  
  void _nextCard() {
    setState(() {
      _currentIndex++;
    });
    HapticFeedback.lightImpact();
  }
  
  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) _currentIndex--;
    });
    HapticFeedback.lightImpact();
  }
  
  void _showCreateMode() {
    HapticFeedback.mediumImpact();
    // 显示创建模式
  }
  
  void _showVoiceInterface() {
    HapticFeedback.lightImpact();
    // 显示语音界面
  }
}

// 手势可视化组件
class GestureVisualizer extends StatefulWidget {
  final Widget child;
  const GestureVisualizer({Key? key, required this.child}) : super(key: key);

  @override
  State<GestureVisualizer> createState() => _GestureVisualizerState();
}

class _GestureVisualizerState extends State<GestureVisualizer> {
  final List<Offset> _points = [];
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _points.add(details.localPosition);
          if (_points.length > 20) {
            _points.removeAt(0);
          }
        });
      },
      onPanEnd: (_) {
        setState(() {
          _points.clear();
        });
      },
      child: Stack(
        children: [
          widget.child,
          CustomPaint(
            painter: GestureTrailPainter(_points),
          ),
        ],
      ),
    );
  }
}

// 手势轨迹绘制
class GestureTrailPainter extends CustomPainter {
  final List<Offset> points;
  GestureTrailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    
    for (int i = 1; i < points.length; i++) {
      final paint = Paint()
        ..color = Color(0xFFFF6B6B).withOpacity(i / points.length)
        ..strokeWidth = 3.0 * (i / points.length)
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(points[i - 1], points[i], paint);
    }
  }

  @override
  bool shouldRepaint(GestureTrailPainter oldDelegate) => true;
}

// 液态动画组件
class LiquidTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  
  const LiquidTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipPath(
          clipper: LiquidClipper(animation.value),
          child: child,
        );
      },
      child: child,
    );
  }
}

class LiquidClipper extends CustomClipper<Path> {
  final double progress;
  LiquidClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 50.0 * (1 - progress);
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * (1 - progress) + 
                math.sin((x / size.width) * 2 * math.pi) * waveHeight;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(LiquidClipper oldClipper) => progress != oldClipper.progress;
}
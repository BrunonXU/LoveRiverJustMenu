// ai_recommendation.dart - AI智能推荐系统
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AIRecommendationPage extends StatefulWidget {
  const AIRecommendationPage({Key? key}) : super(key: key);

  @override
  State<AIRecommendationPage> createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _shakeController;
  late Animation<double> _cardAnimation;
  late Animation<double> _shakeAnimation;
  
  int _currentStoryIndex = 0;
  bool _isShaking = false;
  
  final List<StoryRecommendation> stories = [
    StoryRecommendation(
      context: '降温预警',
      narrative: '今晚降到15度，一碗热汤最暖心',
      recipe: '奶油蘑菇汤',
      reason: '基于天气变化推荐',
      icon: '🍄',
      gradient: [const Color(0xFFFFA751), const Color(0xFFFFE259)],
    ),
    StoryRecommendation(
      context: '营养提醒',
      narrative: '已经3天没吃绿叶菜了哦',
      recipe: '蒜蓉西兰花',
      reason: '基于营养均衡推荐',
      icon: '🥦',
      gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    ),
    StoryRecommendation(
      context: '特殊日子',
      narrative: '还有2天就是你们的纪念日',
      recipe: '红丝绒蛋糕',
      reason: '基于日历事件推荐',
      icon: '🎂',
      gradient: [const Color(0xFFEE9CA7), const Color(0xFFFFDDE1)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AI助手头像
              _buildAIAssistantHeader(),
              
              // 故事卡片
              Expanded(
                child: _buildStoryCards(),
              ),
              
              // 摇一摇按钮
              _buildShakeButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAIAssistantHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '智能助手',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '根据你的生活推荐',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStoryCards() {
    return PageView.builder(
      itemCount: stories.length,
      onPageChanged: (index) {
        setState(() {
          _currentStoryIndex = index;
        });
        _cardAnimationController.forward(from: 0);
      },
      itemBuilder: (context, index) {
        final story = stories[index];
        
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedBuilder(
            animation: _cardAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _cardAnimation.value)),
                child: Opacity(
                  opacity: _cardAnimation.value,
                  child: _buildStoryCard(story),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildStoryCard(StoryRecommendation story) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 情境标签
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: story.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    story.context,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 故事内容
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.narrative,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 推荐卡片
                GestureDetector(
                  onTap: () => _selectRecipe(story),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          story.icon,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story.recipe,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                story.reason,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 智能分析
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '小贴士：这道菜富含维生素C，正好补充你最近缺乏的营养',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShakeButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_isShaking ? _shakeAnimation.value : 0, 0),
            child: GestureDetector(
              onTap: _shakeForNewRecommendation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      '摇一摇换一个',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _shakeForNewRecommendation() {
    setState(() {
      _isShaking = true;
    });
    
    _shakeController.forward().then((_) {
      _shakeController.reverse().then((_) {
        setState(() {
          _isShaking = false;
          _currentStoryIndex = (_currentStoryIndex + 1) % stories.length;
        });
        _cardAnimationController.forward(from: 0);
      });
    });
    
    HapticFeedback.mediumImpact();
  }
  
  void _selectRecipe(StoryRecommendation story) {
    HapticFeedback.lightImpact();
    // 选择食谱
  }
}

// 故事推荐数据模型
class StoryRecommendation {
  final String context;
  final String narrative;
  final String recipe;
  final String reason;
  final String icon;
  final List<Color> gradient;
  
  StoryRecommendation({
    required this.context,
    required this.narrative,
    required this.recipe,
    required this.reason,
    required this.icon,
    required this.gradient,
  });
}

// animation_system.dart - 动画系统
class AnimationSystem {
  // 呼吸动画
  static Widget breathingWidget({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
  }) {
    return _BreathingWidget(
      duration: duration,
      child: child,
    );
  }
  
  // 液态过渡
  static Widget liquidTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ClipPath(
          clipper: _LiquidClipper(animation.value),
          child: child,
        );
      },
    );
  }
  
  // 磁性吸附
  static Widget magneticField({
    required Widget child,
    required Offset targetPosition,
    double strength = 100,
    double radius = 150,
  }) {
    return _MagneticWidget(
      targetPosition: targetPosition,
      strength: strength,
      radius: radius,
      child: child,
    );
  }
  
  // 粒子系统
  static Widget particleSystem({
    required Widget child,
    required List<Particle> particles,
  }) {
    return Stack(
      children: [
        child,
        ..._buildParticles(particles),
      ],
    );
  }
  
  static List<Widget> _buildParticles(List<Particle> particles) {
    return particles.map((particle) {
      return AnimatedPositioned(
        duration: particle.lifespan,
        left: particle.position.dx,
        top: particle.position.dy,
        child: AnimatedOpacity(
          duration: particle.lifespan,
          opacity: particle.opacity,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }).toList();
  }
}

// 呼吸动画组件
class _BreathingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const _BreathingWidget({
    Key? key,
    required this.child,
    required this.duration,
  }) : super(key: key);

  @override
  State<_BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<_BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// 液态裁剪器
class _LiquidClipper extends CustomClipper<Path> {
  final double progress;
  
  _LiquidClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 30.0 * (1 - progress);
    
    path.moveTo(0, size.height);
    
    // 创建波浪效果
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * (1 - progress) +
          math.sin((x / size.width) * 2 * math.pi) * waveHeight;
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(_LiquidClipper oldClipper) => progress != oldClipper.progress;
}

// 磁性组件
class _MagneticWidget extends StatefulWidget {
  final Widget child;
  final Offset targetPosition;
  final double strength;
  final double radius;
  
  const _MagneticWidget({
    Key? key,
    required this.child,
    required this.targetPosition,
    required this.strength,
    required this.radius,
  }) : super(key: key);

  @override
  State<_MagneticWidget> createState() => _MagneticWidgetState();
}

class _MagneticWidgetState extends State<_MagneticWidget> {
  Offset _currentPosition = Offset.zero;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final distance = (details.localPosition - widget.targetPosition).distance;
        
        if (distance < widget.radius) {
          final force = 1 - (distance / widget.radius);
          final deltaX = (widget.targetPosition.dx - details.localPosition.dx) * force * 0.2;
          final deltaY = (widget.targetPosition.dy - details.localPosition.dy) * force * 0.2;
          
          setState(() {
            _currentPosition = Offset(deltaX, deltaY);
          });
        } else {
          setState(() {
            _currentPosition = Offset.zero;
          });
        }
      },
      onPanEnd: (_) {
        setState(() {
          _currentPosition = Offset.zero;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(
          _currentPosition.dx,
          _currentPosition.dy,
          0,
        ),
        child: widget.child,
      ),
    );
  }
}

// 粒子数据模型
class Particle {
  final Offset position;
  final double size;
  final Color color;
  final Duration lifespan;
  final double opacity;
  
  Particle({
    required this.position,
    required this.size,
    required this.color,
    required this.lifespan,
    this.opacity = 1.0,
  });
}
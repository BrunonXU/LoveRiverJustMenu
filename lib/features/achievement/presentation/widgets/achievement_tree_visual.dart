import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../domain/models/achievement.dart';

/// 🌳 真正的成就树可视化组件
class AchievementTreeVisual extends StatefulWidget {
  final List<Achievement> achievements;
  final Function(Achievement)? onAchievementTap;

  const AchievementTreeVisual({
    super.key,
    required this.achievements,
    this.onAchievementTap,
  });

  @override
  State<AchievementTreeVisual> createState() => _AchievementTreeVisualState();
}

class _AchievementTreeVisualState extends State<AchievementTreeVisual>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _breathingController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    
    // 呼吸动画 - 已解锁成就
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    // 脉冲动画 - 即将解锁成就
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _breathingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 600, // 足够的高度显示完整树
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: 1200, // 树的总高度
            child: CustomPaint(
              painter: _AchievementTreePainter(
                achievements: widget.achievements,
                breathingAnimation: _breathingController,
                pulseAnimation: _pulseController,
              ),
              child: _buildAchievementNodes(),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建成就节点
  Widget _buildAchievementNodes() {
    final treeStructure = _buildTreeStructure();
    
    return Stack(
      children: treeStructure.entries.map((entry) {
        final level = entry.key;
        final achievements = entry.value;
        
        return achievements.asMap().entries.map((achievementEntry) {
          final index = achievementEntry.key;
          final achievement = achievementEntry.value;
          final position = _getNodePosition(level, index, achievements.length);
          
          return Positioned(
            left: position.dx - 40,
            top: position.dy - 40,
            child: _buildAchievementNode(achievement),
          );
        }).toList();
      }).expand((x) => x).toList(),
    );
  }

  /// 构建树状结构 - 按层级分组
  Map<int, List<Achievement>> _buildTreeStructure() {
    final structure = <int, List<Achievement>>{};
    
    for (final achievement in widget.achievements) {
      int level;
      
      // 根据成就类型和等级确定树的层级
      switch (achievement.level) {
        case AchievementLevel.bronze:
          level = 0; // 底层：青铜成就
          break;
        case AchievementLevel.silver:
          level = 1; // 中层：白银成就
          break;
        case AchievementLevel.gold:
          level = 2; // 顶层：黄金成就
          break;
        case AchievementLevel.diamond:
          level = 3; // 钻石成就（如果有）
          break;
        case AchievementLevel.legendary:
          level = 4; // 传说成就
          break;
      }
      
      structure.putIfAbsent(level, () => []).add(achievement);
    }
    
    return structure;
  }

  /// 获取节点在树中的位置
  Offset _getNodePosition(int level, int index, int totalInLevel) {
    final canvasWidth = MediaQuery.of(context).size.width;
    final canvasHeight = 1200.0;
    
    // 从底部开始布局（倒置的树）
    final y = canvasHeight - 150 - (level * 250.0); // 每层间距250px
    
    // 水平分布
    final spacing = canvasWidth / (totalInLevel + 1);
    final x = spacing * (index + 1);
    
    return Offset(x, y);
  }

  /// 构建单个成就节点
  Widget _buildAchievementNode(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final isNearComplete = achievement.progress >= 0.8 && !isUnlocked;
    
    Widget node = GestureDetector(
      onTap: () => widget.onAchievementTap?.call(achievement),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isUnlocked 
              ? _getAchievementGradient(achievement.level)
              : null,
          color: isUnlocked 
              ? null 
              : isNearComplete 
                  ? AppColors.emotionGradient.colors.first.withValues(alpha: 0.3)
                  : AppColors.backgroundSecondary,
          border: Border.all(
            color: isUnlocked 
                ? _getAchievementColor(achievement.level)
                : isNearComplete 
                    ? AppColors.emotionGradient.colors.first
                    : AppColors.textSecondary.withValues(alpha: 0.3),
            width: isUnlocked ? 3 : 2,
          ),
          boxShadow: [
            if (isUnlocked)
              BoxShadow(
                color: _getAchievementColor(achievement.level).withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.emoji,
              style: TextStyle(
                fontSize: isUnlocked ? 32 : 24,
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${achievement.points}',
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getAchievementColor(achievement.level),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // 添加动画效果
    if (isUnlocked) {
      node = AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_breathingController.value * 0.05),
            child: node,
          );
        },
      );
    } else if (isNearComplete) {
      node = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.1),
            child: node,
          );
        },
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        node,
        // 成就名称
        Positioned(
          bottom: -25,
          child: SizedBox(
            width: 100,
            child: Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: AppTypography.captionStyle(isDark: false).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isUnlocked 
                    ? AppColors.textPrimary 
                    : AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // 进度环
        if (!isUnlocked) 
          Positioned(
            right: -5,
            top: -5,
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                value: achievement.progress,
                strokeWidth: 3,
                backgroundColor: AppColors.backgroundSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isNearComplete 
                      ? AppColors.emotionGradient.colors.first
                      : AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 获取成就等级对应的颜色
  Color _getAchievementColor(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return const Color(0xFFCD7F32); // 青铜色
      case AchievementLevel.silver:
        return const Color(0xFFC0C0C0); // 银色
      case AchievementLevel.gold:
        return const Color(0xFFFFD700); // 金色
      case AchievementLevel.diamond:
        return const Color(0xFFB9F2FF); // 钻石色
      case AchievementLevel.legendary:
        return const Color(0xFFFF6B6B); // 传说色
    }
  }

  /// 获取成就等级对应的渐变
  LinearGradient _getAchievementGradient(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return const LinearGradient(
          colors: [
            Color(0xFFCD7F32),
            Color(0xFFDEB887),
          ],
        );
      case AchievementLevel.silver:
        return const LinearGradient(
          colors: [
            Color(0xFFC0C0C0),
            Color(0xFFE5E5E5),
          ],
        );
      case AchievementLevel.gold:
        return const LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFF8DC),
          ],
        );
      case AchievementLevel.diamond:
        return const LinearGradient(
          colors: [
            Color(0xFFB9F2FF),
            Color(0xFFE1F5FE),
          ],
        );
      case AchievementLevel.legendary:
        return const LinearGradient(
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFFE66D),
          ],
        );
    }
  }
}

/// 🌳 成就树绘制器 - 绘制树干和连接线
class _AchievementTreePainter extends CustomPainter {
  final List<Achievement> achievements;
  final Animation<double> breathingAnimation;
  final Animation<double> pulseAnimation;

  _AchievementTreePainter({
    required this.achievements,
    required this.breathingAnimation,
    required this.pulseAnimation,
  }) : super(repaint: Listenable.merge([breathingAnimation, pulseAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制树干
    _drawTrunk(canvas, size);
    
    // 绘制树枝连接
    _drawBranches(canvas, size);
    
    // 绘制装饰元素
    _drawDecorations(canvas, size);
  }

  /// 绘制主树干
  void _drawTrunk(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8D4B0A).withValues(alpha: 0.8),
          const Color(0xFF654321),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // 主树干路径
    final trunkPath = Path();
    final centerX = size.width / 2;
    final trunkWidth = 20.0;
    
    trunkPath.moveTo(centerX - trunkWidth / 2, size.height);
    trunkPath.lineTo(centerX - trunkWidth / 3, size.height * 0.7);
    trunkPath.lineTo(centerX + trunkWidth / 3, size.height * 0.7);
    trunkPath.lineTo(centerX + trunkWidth / 2, size.height);
    trunkPath.close();
    
    canvas.drawPath(trunkPath, trunkPaint);
  }

  /// 绘制树枝连接线
  void _drawBranches(Canvas canvas, Size size) {
    final branchPaint = Paint()
      ..color = const Color(0xFF8D4B0A).withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    
    // 绘制各层级之间的连接
    for (int level = 0; level < 3; level++) {
      final fromY = size.height - 150 - (level * 250.0);
      final toY = size.height - 150 - ((level + 1) * 250.0);
      
      if (toY > 0) {
        // 主干到该层的连接
        canvas.drawLine(
          Offset(centerX, fromY + 40),
          Offset(centerX, toY - 40),
          branchPaint,
        );
        
        // 该层内部节点的连接
        final levelAchievements = _getAchievementsForLevel(level);
        if (levelAchievements.length > 1) {
          for (int i = 0; i < levelAchievements.length; i++) {
            final spacing = size.width / (levelAchievements.length + 1);
            final x = spacing * (i + 1);
            
            // 从主干到节点的分支
            canvas.drawLine(
              Offset(centerX, fromY + 20),
              Offset(x, fromY + 20),
              branchPaint..strokeWidth = 2,
            );
            canvas.drawLine(
              Offset(x, fromY + 20),
              Offset(x, fromY + 40),
              branchPaint,
            );
          }
        }
      }
    }
  }

  /// 绘制装饰元素（叶子、花朵等）
  void _drawDecorations(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // 在已解锁成就周围绘制叶子
    for (final achievement in achievements) {
      if (achievement.isUnlocked) {
        final position = _getAchievementPosition(achievement, size);
        
        // 绘制小叶子
        for (int i = 0; i < 3; i++) {
          final angle = (i * 120) * math.pi / 180;
          final leafX = position.dx + math.cos(angle) * 50;
          final leafY = position.dy + math.sin(angle) * 50;
          
          final leafPath = Path();
          leafPath.addOval(Rect.fromCenter(
            center: Offset(leafX, leafY),
            width: 8,
            height: 12,
          ));
          
          canvas.drawPath(leafPath, leafPaint);
        }
      }
    }
  }

  /// 获取特定层级的成就
  List<Achievement> _getAchievementsForLevel(int level) {
    return achievements.where((achievement) {
      switch (level) {
        case 0:
          return achievement.level == AchievementLevel.bronze;
        case 1:
          return achievement.level == AchievementLevel.silver;
        case 2:
          return achievement.level == AchievementLevel.gold;
        case 3:
          return achievement.level == AchievementLevel.diamond;
        case 4:
          return achievement.level == AchievementLevel.legendary;
        default:
          return false;
      }
    }).toList();
  }

  /// 获取成就在画布中的位置
  Offset _getAchievementPosition(Achievement achievement, Size size) {
    int level;
    switch (achievement.level) {
      case AchievementLevel.bronze:
        level = 0;
        break;
      case AchievementLevel.silver:
        level = 1;
        break;
      case AchievementLevel.gold:  
        level = 2;
        break;
      case AchievementLevel.diamond:
        level = 3;
        break;
      case AchievementLevel.legendary:
        level = 4;
        break;
    }
    
    final levelAchievements = _getAchievementsForLevel(level);
    final index = levelAchievements.indexOf(achievement);
    
    final y = size.height - 150 - (level * 250.0);
    final spacing = size.width / (levelAchievements.length + 1);
    final x = spacing * (index + 1);
    
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
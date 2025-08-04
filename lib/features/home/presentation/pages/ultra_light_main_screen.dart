import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/performance/frame_budget_manager.dart';
import '../../../../core/animations/lightweight_animations.dart';

/// 🚀 超轻量级主页 - 专为120FPS优化
/// 移除所有非必要动画和复杂布局
class UltraLightMainScreen extends ConsumerStatefulWidget {
  const UltraLightMainScreen({super.key});

  @override
  ConsumerState<UltraLightMainScreen> createState() => _UltraLightMainScreenState();
}

class _UltraLightMainScreenState extends ConsumerState<UltraLightMainScreen>
    with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
    // 初始化超轻量级动画系统 - 仅在调试模式
    if (kDebugMode) {
      LightweightAnimationController.instance.initialize(this);
      FrameBudgetManager.instance.setTargetFps(120);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 简化的顶部栏
              _buildSimpleHeader(),
              
              // 主要内容区域
              Expanded(
                child: _buildMainContent(),
              ),
              
              // 底部提示
              _buildBottomHint(),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建简单的顶部栏
  Widget _buildSimpleHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 菜单按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // 简化的菜单操作
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, size: 20),
            ),
          ),
          
          // 时间显示
          Text(
            _getCurrentTime(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
          
          // 搜索按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/search');
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search, size: 20),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建主要内容
  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 主标题
          const Text(
            '爱心食谱',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w100,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 副标题
          Text(
            '极简版本 - 专为性能优化',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 主要操作卡片 - 只有最基本的呼吸效果
          UltraLightBreathingWidget(
            scaleRange: 0.01, // 极小的缩放
            period: 6000, // 更长的周期减少计算
            child: Container(
              width: 280,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 简单的图标
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    '今日推荐',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '点击开始烹饪之旅',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建底部提示
  Widget _buildBottomHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        '超轻量级版本 - 120FPS优化',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
    );
  }
  
  /// 获取当前时间
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    LightweightAnimationController.instance.dispose();
    super.dispose();
  }
}
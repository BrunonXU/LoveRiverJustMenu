import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/colors.dart';
import '../../core/router/app_router.dart';
import '../../core/auth/providers/auth_providers.dart';
import 'breathing_widget.dart';

/// 🎨 侧边栏组件 - 占50%宽度，从左滑出
/// 包含所有原主页功能的统一入口
class SideDrawer extends ConsumerWidget {
  final VoidCallback? onClose;
  
  const SideDrawer({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55, // 55%宽度
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, // 纯白色背景
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部关闭按钮和标题
            _buildHeader(context),
            
            // 用户中心区域
            _buildUserCenter(context, ref),
            
            // 分割线
            _buildDivider(),
            
            // 功能列表区域 - 可滚动
            Expanded(
              child: _buildFunctionList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建顶部header
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '爱心食谱',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              size: 24,
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户中心区域
  Widget _buildUserCenter(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: BreathingWidget(
        child: GestureDetector(
          onTap: () {
            print('👤 用户头像被点击');
            HapticFeedback.lightImpact();
            print('🎯 准备导航到个人空间: ${AppRouter.personalSpace}');
            _navigateTo(context, AppRouter.personalSpace);
          },
          child: Row(
            children: [
              // 用户头像
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B6FED).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '❤️',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? user?.displayName ?? user?.email ?? '未登录',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user != null 
                          ? '点击查看个人资料'
                          : '⚠️ 未登录状态',
                      style: TextStyle(
                        fontSize: 12,
                        color: user != null ? Colors.grey[600] : Colors.red,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头图标
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 0.5,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  /// 构建功能列表
  Widget _buildFunctionList(BuildContext context) {
    final functionItems = [
      // 🥇 第一位：我的菜谱
      DrawerItem(
        icon: Icons.restaurant_menu,
        title: '我的菜谱',
        subtitle: '创建·预设·管理·收藏',
        onTap: () => _navigateTo(context, AppRouter.myRecipes),
      ),
      // 🥈 第二位：味道圈
      DrawerItem(
        icon: Icons.group,
        title: '味道圈',
        subtitle: '组队烹饪',
        children: [
          DrawerSubItem(
            title: '我的味道圈',
            onTap: () => _navigateTo(context, AppRouter.tasteCircles),
          ),
          DrawerSubItem(
            title: '创建新圈子',
            onTap: () => _navigateTo(context, AppRouter.createCircle),
          ),
          DrawerSubItem(
            title: '圈子成就',
            onTap: () => _navigateTo(context, AppRouter.tasteCircleAchievements),
          ),
        ],
      ),
      // 其他功能按原顺序
      DrawerItem(
        icon: Icons.menu_book,
        title: '美食日记',
        subtitle: '翻页记忆回顾',
        onTap: () => _navigateTo(context, AppRouter.foodJournal),
      ),
      DrawerItem(
        icon: Icons.timeline,
        title: '美食时光机',
        subtitle: '3D记忆时光',
        onTap: () => _navigateTo(context, AppRouter.timeline),
      ),
      DrawerItem(
        icon: Icons.psychology,
        title: 'AI推荐',
        subtitle: '智能故事推荐',
        onTap: () => _navigateTo(context, AppRouter.aiRecommendation),
      ),
      DrawerItem(
        icon: Icons.map,
        title: '美食地图',
        subtitle: '探索各地美食',
        onTap: () => _navigateTo(context, AppRouter.foodMap),
      ),
      DrawerItem(
        icon: Icons.sports_martial_arts,
        title: '挑战模式',
        subtitle: '节奏烹饪游戏',
        onTap: () => _navigateTo(context, AppRouter.challenge),
      ),
      DrawerItem(
        icon: Icons.emoji_events,
        title: '成就中心',
        subtitle: '成长·成就·数据',
        children: [
          DrawerSubItem(
            title: '成就系统',
            onTap: () => _navigateTo(context, AppRouter.achievements),
          ),
          DrawerSubItem(
            title: '学习历程',
            onTap: () => _navigateTo(context, AppRouter.learningProgress),
          ),
          DrawerSubItem(
            title: '数据分析',
            onTap: () => _navigateTo(context, AppRouter.analytics),
          ),
        ],
      ),
      DrawerItem(
        icon: Icons.settings,
        title: '设置',
        subtitle: '个性化偏好',
        onTap: () => _navigateTo(context, AppRouter.settings),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: functionItems.length,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: false,
      // 性能优化：避免不必要的重建
      cacheExtent: 100,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('drawer_item_$index'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildDrawerItem(context, functionItems[index]),
          ),
        );
      },
    );
  }

  /// 构建单个抽屉项目
  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    return Column(
      children: [
        // 主项目 - 移除BreathingWidget提升性能
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              if (item.children != null && item.children!.isNotEmpty) {
                // 如果有子项目，展开/收起逻辑可以后续添加
                // 目前直接执行主项目的操作
                if (item.onTap != null) item.onTap!();
              } else {
                if (item.onTap != null) item.onTap!();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 文字
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 箭头（如果有子项目）
                  if (item.children != null && item.children!.isNotEmpty)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // 子项目（如果有）
        if (item.children != null && item.children!.isNotEmpty)
          ...item.children!.map((subItem) => RepaintBoundary(
            child: _buildSubItem(context, subItem),
          )),
      ],
    );
  }

  /// 构建子项目
  Widget _buildSubItem(BuildContext context, DrawerSubItem subItem) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          HapticFeedback.lightImpact();
          if (subItem.onTap != null) subItem.onTap!();
        },
        child: Container(
          padding: const EdgeInsets.only(left: 68, right: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subItem.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis, // 防止文字溢出
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 导航到指定页面
  void _navigateTo(BuildContext context, String route) {
    print('🚀 _navigateTo 被调用，路由: $route');
    print('🔍 onClose 是否为空: ${onClose == null}');
    
    // 先执行导航，再关闭侧边栏
    try {
      print('📍 尝试导航到: $route');
      context.push(route); // 使用push替代go，保持导航栈
      print('✅ 导航成功');
      
      // 导航成功后关闭侧边栏
      if (onClose != null) {
        print('🚪 调用 onClose');
        onClose!();
      }
    } catch (e) {
      print('❌ 导航失败: $route, 错误: $e');
      // 即使导航失败也要关闭侧边栏
      if (onClose != null) {
        print('🚪 导航失败，仍调用 onClose');
        onClose!();
      }
    }
  }
}

/// 抽屉项目数据类
class DrawerItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final List<DrawerSubItem>? children;

  DrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.children,
  });
}

/// 抽屉子项目数据类
class DrawerSubItem {
  final String title;
  final VoidCallback? onTap;

  DrawerSubItem({
    required this.title,
    this.onTap,
  });
}
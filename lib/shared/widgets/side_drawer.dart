import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/colors.dart';
import '../../core/themes/typography.dart';
import '../../core/themes/spacing.dart';
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
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5, // 50%宽度
        height: MediaQuery.of(context).size.height, // 明确指定高度避免溢出
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            HapticFeedback.lightImpact();
            
            // 关闭侧边栏
            Navigator.of(context).pop();
            
            // 延迟导航，确保pop完成后再进行路由跳转
            Future.microtask(() {
              if (context.mounted) {
                context.go('/personal-center'); // 使用go替代push，避免路由栈问题
              }
            });
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
                      user?.displayName ?? user?.email ?? 'Melody',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '点击查看个人资料',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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
      height: 1,
      color: Colors.grey[200],
    );
  }

  /// 构建功能列表
  Widget _buildFunctionList(BuildContext context) {
    final functionItems = [
      DrawerItem(
        icon: Icons.timeline,
        title: '时光机',
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
        icon: Icons.favorite,
        title: '情侣空间',
        subtitle: '档案与亲密度',
        children: [
          DrawerSubItem(
            title: '情侣档案',
            onTap: () => _navigateTo(context, AppRouter.coupleProfile),
          ),
          DrawerSubItem(
            title: '亲密度成就',
            onTap: () => _navigateTo(context, AppRouter.intimacy),
          ),
        ],
      ),
      DrawerItem(
        icon: Icons.sports_martial_arts,
        title: '挑战模式',
        subtitle: '节奏烹饪游戏',
        onTap: () => _navigateTo(context, AppRouter.challenge),
      ),
      DrawerItem(
        icon: Icons.restaurant_menu,
        title: '我的菜谱',
        subtitle: '创建·预设·管理',
        onTap: () => _navigateTo(context, '/personal-center/my-recipes'),
      ),
      DrawerItem(
        icon: Icons.favorite_border,
        title: '我的收藏',
        subtitle: '收藏的美食菜谱',
        onTap: () => _navigateTo(context, '/personal-center/favorites'),
      ),
      DrawerItem(
        icon: Icons.emoji_events,
        title: '成就中心',
        subtitle: '成长·成就·数据',
        children: [
          DrawerSubItem(
            title: '成就系统',
            onTap: () => _navigateTo(context, '/personal-center/achievements'),
          ),
          DrawerSubItem(
            title: '学习历程',
            onTap: () => _navigateTo(context, '/personal-center/learning-progress'),
          ),
          DrawerSubItem(
            title: '数据分析',
            onTap: () => _navigateTo(context, '/personal-center/analytics'),
          ),
        ],
      ),
      DrawerItem(
        icon: Icons.settings,
        title: '设置',
        subtitle: '个性化偏好',
        onTap: () => _navigateTo(context, '/settings'),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: functionItems.length,
      physics: const BouncingScrollPhysics(), // 添加弹性滚动
      shrinkWrap: false, // 确保ListView占满Expanded空间
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4), // 项目间距
          child: _buildDrawerItem(context, functionItems[index]),
        );
      },
    );
  }

  /// 构建单个抽屉项目
  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    return Column(
      children: [
        // 主项目
        BreathingWidget(
          child: Material(
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis, // 防止文字溢出
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
                              overflow: TextOverflow.ellipsis, // 防止文字溢出
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
        ),
        
        // 子项目（如果有）
        if (item.children != null && item.children!.isNotEmpty)
          ...item.children!.map((subItem) => _buildSubItem(context, subItem)),
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
    // 关闭侧边栏
    Navigator.of(context).pop();
    
    // 延迟导航，确保pop完成后再进行路由跳转
    Future.microtask(() {
      if (context.mounted) {
        context.go(route); // 使用go替代push，避免路由栈问题
      }
    });
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
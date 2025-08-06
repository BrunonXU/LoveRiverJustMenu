/// 🔄 菜谱更新标记组件
/// 
/// 在菜谱卡片右上角显示更新标记
/// 支持不同重要性级别的视觉差异化
/// 
/// 作者: Claude Code
/// 创建时间: 2025-08-06

import 'package:flutter/material.dart';
import '../../core/models/recipe_update_info.dart';
import '../../core/themes/colors.dart';

/// 🎯 菜谱更新标记组件
class RecipeUpdateBadge extends StatelessWidget {
  /// 更新信息
  final RecipeUpdateInfo updateInfo;
  
  /// 标记大小
  final double size;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  const RecipeUpdateBadge({
    super.key,
    required this.updateInfo,
    this.size = 24.0,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getBadgeColor(),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getBadgeColor().withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _getBadgeIcon(),
            size: size * 0.6,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  /// 获取标记颜色
  Color _getBadgeColor() {
    switch (updateInfo.badgeColor) {
      case UpdateBadgeColor.red:
        return const Color(0xFFFF4757); // 紧急更新 - 红色
      case UpdateBadgeColor.orange:
        return const Color(0xFFFF6B35); // 重要更新 - 橙色  
      case UpdateBadgeColor.blue:
        return const Color(0xFF3742FA); // 新更新 - 蓝色
      case UpdateBadgeColor.green:
      default:
        return const Color(0xFF2ED573); // 普通更新 - 绿色
    }
  }
  
  /// 获取标记图标
  IconData _getBadgeIcon() {
    if (updateInfo.isCriticalUpdate) {
      return Icons.priority_high; // 紧急更新 - 感叹号
    }
    if (updateInfo.isImportantUpdate) {
      return Icons.new_releases; // 重要更新 - 新版本图标
    }
    if (updateInfo.isRecentUpdate) {
      return Icons.fiber_new; // 新更新 - NEW标记
    }
    return Icons.sync; // 普通更新 - 同步图标
  }
}

/// 🎨 菜谱更新脉冲动画标记
/// 
/// 带有脉冲动画效果的更新标记，更容易吸引用户注意
class AnimatedRecipeUpdateBadge extends StatefulWidget {
  /// 更新信息
  final RecipeUpdateInfo updateInfo;
  
  /// 标记大小
  final double size;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  const AnimatedRecipeUpdateBadge({
    super.key,
    required this.updateInfo,
    this.size = 24.0,
    this.onTap,
  });
  
  @override
  State<AnimatedRecipeUpdateBadge> createState() => _AnimatedRecipeUpdateBadgeState();
}

class _AnimatedRecipeUpdateBadgeState extends State<AnimatedRecipeUpdateBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 仅对重要更新和紧急更新启动动画
    if (widget.updateInfo.isImportantUpdate || widget.updateInfo.isCriticalUpdate) {
      _animationController.repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 脉冲光环效果（仅对重要更新显示）
          if (widget.updateInfo.isImportantUpdate || widget.updateInfo.isCriticalUpdate)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size * 1.5,
                    height: widget.size * 1.5,
                    decoration: BoxDecoration(
                      color: _getBadgeColor().withOpacity(_opacityAnimation.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          
          // 主标记
          RecipeUpdateBadge(
            updateInfo: widget.updateInfo,
            size: widget.size,
            onTap: null, // 在这里不处理点击，由外层GestureDetector处理
          ),
        ],
      ),
    );
  }
  
  /// 获取标记颜色
  Color _getBadgeColor() {
    switch (widget.updateInfo.badgeColor) {
      case UpdateBadgeColor.red:
        return const Color(0xFFFF4757);
      case UpdateBadgeColor.orange:
        return const Color(0xFFFF6B35);
      case UpdateBadgeColor.blue:
        return const Color(0xFF3742FA);
      case UpdateBadgeColor.green:
      default:
        return const Color(0xFF2ED573);
    }
  }
}

/// 📱 菜谱更新提示对话框
class RecipeUpdateDialog extends StatelessWidget {
  /// 更新信息
  final RecipeUpdateInfo updateInfo;
  
  /// 菜谱名称
  final String recipeName;
  
  /// 更新回调
  final Function(UpdateAction action) onAction;
  
  const RecipeUpdateDialog({
    super.key,
    required this.updateInfo,
    required this.recipeName,
    required this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题图标
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getUpdateColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getUpdateIcon(),
                size: 32,
                color: _getUpdateColor(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 标题
            Text(
              '发现菜谱更新',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 菜谱名称和更新信息
            Text(
              recipeName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              updateInfo.updateLabel,
              style: TextStyle(
                fontSize: 14,
                color: _getUpdateColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '更新时间：${_formatUpdateTime(updateInfo.cloudVersion)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 操作按钮
            Column(
              children: [
                // 更新按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onAction(UpdateAction.update),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getUpdateColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '立即更新',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 底部按钮行
                Row(
                  children: [
                    // 稍后提醒
                    Expanded(
                      child: TextButton(
                        onPressed: () => onAction(UpdateAction.later),
                        child: Text(
                          '稍后提醒',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    
                    // 忽略更新
                    Expanded(
                      child: TextButton(
                        onPressed: () => onAction(UpdateAction.ignore),
                        child: Text(
                          '忽略更新',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getUpdateColor() {
    switch (updateInfo.badgeColor) {
      case UpdateBadgeColor.red:
        return const Color(0xFFFF4757);
      case UpdateBadgeColor.orange:
        return const Color(0xFFFF6B35);
      case UpdateBadgeColor.blue:
        return const Color(0xFF3742FA);
      case UpdateBadgeColor.green:
      default:
        return const Color(0xFF2ED573);
    }
  }
  
  IconData _getUpdateIcon() {
    if (updateInfo.isCriticalUpdate) return Icons.warning;
    if (updateInfo.isImportantUpdate) return Icons.new_releases;
    return Icons.sync;
  }
  
  String _formatUpdateTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
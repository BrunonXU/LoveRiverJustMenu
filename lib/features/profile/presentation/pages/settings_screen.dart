import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../recipe/data/repositories/recipe_repository.dart';
import '../../../recipe/domain/services/data_backup_service.dart';
import '../../../../core/utils/json_recipe_importer.dart';
import '../../../../core/firestore/repositories/recipe_repository.dart';
import '../../../../core/auth/providers/auth_providers.dart';
import '../../../../core/utils/clean_orphaned_favorites_script.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/auth/providers/auth_providers.dart' as auth;

/// 设置中心页面 - 包含数据备份恢复功能
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late DataBackupService _backupService;
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeBackupService();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }
  
  void _initializeBackupService() async {
    final repository = await ref.read(initializedRecipeRepositoryProvider.future);
    _backupService = DataBackupService(repository);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getTimeBasedGradient(),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 顶部导航栏
                _buildAppBar(isDark),
                
                // 主内容区域
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: AppSpacing.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 数据管理板块
                        _buildSectionTitle('数据管理', isDark),
                        const SizedBox(height: AppSpacing.md),
                        _buildDataManagementSection(isDark),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // 应用设置板块
                        _buildSectionTitle('应用设置', isDark),
                        const SizedBox(height: AppSpacing.md),
                        _buildAppSettingsSection(isDark),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // 关于板块
                        _buildSectionTitle('关于', isDark),
                        const SizedBox(height: AppSpacing.md),
                        _buildAboutSection(isDark),
                        
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(isDark).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadowColor(isDark),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.getTextPrimaryColor(isDark),
                size: 20,
              ),
            ),
          ),
          
          const Spacer(),
          
          // 标题
          Text(
            '设置中心',
            style: AppTypography.titleLargeStyle(isDark: isDark),
          ),
          
          const Spacer(),
          
          // 占位
          const SizedBox(width: 44),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
        fontWeight: AppTypography.medium,
      ),
    );
  }
  
  /// 💾 数据管理板块
  Widget _buildDataManagementSection(bool isDark) {
    return Column(
      children: [
        // 导出数据
        _buildSettingItem(
          icon: Icons.upload_file,
          iconColor: AppColors.primary,
          title: '导出菜谱数据',
          subtitle: '将所有菜谱导出为JSON文件',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _exportData(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 导入数据
        _buildSettingItem(
          icon: Icons.download,
          iconColor: Colors.green,
          title: '导入菜谱数据',
          subtitle: '从JSON文件恢复菜谱',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _importData(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 🧹 清理孤立收藏记录
        _buildSettingItem(
          icon: Icons.favorite_border,
          iconColor: Colors.red,
          title: '🧹 清理无效收藏',
          subtitle: '删除收藏中已不存在的菜谱记录',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _cleanOrphanedFavorites(),
        ),
      ],
    );
  }
  
  /// ⚙️ 应用设置板块（暂时移除未实现功能）
  Widget _buildAppSettingsSection(bool isDark) {
    return Column(
      children: [
        // 🔧 当前没有已实现的应用设置功能
        // 未来可以在这里添加：深色模式、通知设置、语言选择等
        _buildSettingItem(
          icon: Icons.settings,
          iconColor: Colors.grey,
          title: '应用设置',
          subtitle: '更多设置功能正在开发中...',
          isDark: isDark,
          onTap: null,
        ),
      ],
    );
  }
  
  /// ℹ️ 关于板块
  Widget _buildAboutSection(bool isDark) {
    return Column(
      children: [
        // 版本信息
        _buildSettingItem(
          icon: Icons.info,
          iconColor: Colors.blue,
          title: '应用信息',
          subtitle: '爱心食谱 v1.0.0 - 极简高级美食菜谱应用',
          isDark: isDark,
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 技术栈信息
        _buildSettingItem(
          icon: Icons.code,
          iconColor: Colors.green,
          title: '技术实现',
          subtitle: 'Flutter + Firebase + Claude Code 联合开发',
          isDark: isDark,
        ),
      ],
    );
  }
  
  /// 🔧 设置项组件
  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return BreathingWidget(
      child: MinimalCard(
        onTap: onTap,
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // 文字内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            
            // 尾部组件
            if (trailing != null) 
              trailing
            else if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.getTextSecondaryColor(isDark),
              ),
          ],
        ),
      ),
    );
  }
  
  // ==================== 数据操作方法 ====================
  
  /// 📤 导出数据
  Future<void> _exportData() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      await _backupService.exportData(
        context: context,
        shareDirectly: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  /// 📥 导入数据
  Future<void> _importData() async {
    if (_isProcessing) return;
    
    // 直接从文件导入
    await _importFromFile();
  }
  

  
  /// 📂 从文件导入
  Future<void> _importFromFile() async {
    // 显示导入方式选择
    final merge = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择导入方式'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('合并：保留现有菜谱，添加新菜谱'),
            SizedBox(height: AppSpacing.sm),
            Text('覆盖：删除所有现有菜谱，完全替换'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('合并导入'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '覆盖导入',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (merge == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      await _backupService.importData(
        context: context,
        merge: merge,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  /// ✅ 显示成功消息
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
  
  /// ❌ 显示错误消息
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
  
  /// 🧹 清理孤立的收藏记录
  Future<void> _cleanOrphanedFavorites() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      // 获取当前用户ID
      final currentUser = ref.read(auth.currentUserProvider);
      if (currentUser == null) {
        _showErrorMessage('用户未登录，无法清理收藏记录');
        return;
      }
      
      final userId = currentUser.uid;
      
      // 获取服务实例
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      final favoritesService = FavoritesService();
      
      // 先分析孤立收藏
      final analysis = await CleanOrphanedFavoritesScript.analyzeUserOrphanedFavorites(
        userId,
        repository,
        favoritesService,
      );
      
      if (analysis.containsKey('error')) {
        _showErrorMessage('分析收藏记录失败：${analysis['error']}');
        return;
      }
      
      final orphanedCount = analysis['orphaned_favorites'] as int;
      
      if (orphanedCount == 0) {
        _showSuccessMessage('🎉 您的收藏记录很干净！\n\n没有发现孤立的收藏记录。');
        return;
      }
      
      // 显示分析结果并确认清理
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🧹 清理无效收藏记录'),
          content: Text(
            '发现收藏中有无效的菜谱记录：\n\n'
            '📊 收藏分析结果：\n'
            '• 总收藏数：${analysis['total_favorites']} 个\n'
            '• 有效收藏：${analysis['valid_favorites']} 个\n'
            '• 无效收藏：${analysis['orphaned_favorites']} 个\n\n'
            '🗑️ 将清理的无效记录：\n' +
            (analysis['orphaned_details'] as List).take(3).map((detail) => 
              '• ${detail['recipe_id']} (${detail['reason']})'
            ).join('\n') +
            (analysis['orphaned_details'].length > 3 ? '\n• ...' : '') +
            '\n\n⚠️ 清理后您的收藏将更加整洁，是否继续？',
            style: const TextStyle(height: 1.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '确认清理',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // 执行清理
      final result = await CleanOrphanedFavoritesScript.cleanUserOrphanedFavorites(
        userId,
        repository,
        favoritesService,
      );
      
      if (result['status'] == 'success') {
        _showSuccessMessage(
          '🎉 收藏记录清理成功！\n\n'
          '📊 清理结果：\n'
          '• 原收藏数：${result['total_favorites']} 个\n'
          '• 清理无效：${result['cleaned_count']} 个\n'
          '• 剩余收藏：${result['remaining_count']} 个\n\n'
          '✅ 您的收藏记录现在更加整洁了！'
        );
      } else if (result['status'] == 'partial_success') {
        _showErrorMessage(
          '⚠️ 收藏记录清理部分成功\n\n'
          '清理成功：${result['cleaned_count']} 个\n'
          '清理失败：${result['orphaned_count'] - result['cleaned_count']} 个\n\n'
          '请检查控制台日志了解详情'
        );
      } else if (result['status'] == 'no_favorites') {
        _showSuccessMessage('🎉 您还没有任何收藏记录！');
      } else {
        _showErrorMessage(
          '❌ 收藏记录清理失败\n\n'
          '${result.containsKey('error') ? result['error'] : '未知错误'}'
        );
      }
      
    } catch (e) {
      debugPrint('❌ 清理孤立收藏失败: $e');
      _showErrorMessage('清理失败：$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 🗑️ 已删除的预设菜谱管理功能：
  // - _setupRootPresetRecipes(): Root架构重置（预设菜谱已在数据库中）
  // - _resetAllPresets(): 重置预设菜谱（不需要用户操作）
  // - _addStepEmojis(): 添加步骤emoji（预设菜谱已有完整emoji）
  // - _cleanDuplicatePresets(): 清理重复预设（Root架构避免了重复）
  // 
  // 这些功能已移除，因为预设菜谱现在通过Root用户(2352016835@qq.com)
  // 在数据库中统一管理，普通用户不需要这些管理功能。
}
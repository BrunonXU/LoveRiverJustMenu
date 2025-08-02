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
        
        // 🔧 管理员功能：初始化Root用户预设菜谱
        _buildSettingItem(
          icon: Icons.admin_panel_settings,
          iconColor: Colors.purple,
          title: '初始化系统预设菜谱',
          subtitle: '🔧 管理员功能：为Root用户创建12个预设菜谱',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _initializeRootPresetRecipes(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 快速备份
        _buildSettingItem(
          icon: Icons.backup,
          iconColor: Colors.orange,
          title: '快速备份',
          subtitle: '备份到应用内部存储',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _quickBackup(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 清空数据
        _buildSettingItem(
          icon: Icons.delete_forever,
          iconColor: Colors.red,
          title: '清空所有数据',
          subtitle: '⚠️ 此操作不可恢复',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _clearAllData(),
        ),
      ],
    );
  }
  
  /// ⚙️ 应用设置板块
  Widget _buildAppSettingsSection(bool isDark) {
    return Column(
      children: [
        // 深色模式（暂未实现）
        _buildSettingItem(
          icon: Icons.dark_mode,
          iconColor: Colors.indigo,
          title: '深色模式',
          subtitle: '即将推出',
          isDark: isDark,
          trailing: Switch(
            value: false,
            onChanged: null, // 暂时禁用
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 通知设置
        _buildSettingItem(
          icon: Icons.notifications,
          iconColor: Colors.blue,
          title: '烹饪提醒',
          subtitle: '定时提醒功能开发中',
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
          iconColor: Colors.grey,
          title: '版本信息',
          subtitle: 'v1.0.0',
          isDark: isDark,
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 隐私政策
        _buildSettingItem(
          icon: Icons.privacy_tip,
          iconColor: Colors.teal,
          title: '隐私政策',
          subtitle: '了解我们如何保护您的数据',
          isDark: isDark,
          onTap: () {
            // TODO: 打开隐私政策页面
          },
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
    
    // Step 1: 选择导入来源
    final importSource = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择导入来源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.restaurant_menu, color: Colors.orange),
              title: Text('导入示例菜谱'),
              subtitle: Text('6个精选菜谱：银耳汤、番茄面等'),
              onTap: () => Navigator.of(context).pop('sample'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.file_upload, color: Colors.blue),
              title: Text('从文件导入'),
              subtitle: Text('选择备份的JSON文件'),
              onTap: () => Navigator.of(context).pop('file'),
            ),
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
        ],
      ),
    );
    
    if (importSource == null) return;
    
    if (importSource == 'sample') {
      await _importSampleRecipes();
    } else if (importSource == 'file') {
      await _importFromFile();
    }
  }
  
  /// 🔧 初始化Root用户预设菜谱（管理员功能）
  Future<void> _initializeRootPresetRecipes() async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      // 确认操作
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🔧 管理员操作'),
          content: const Text(
            '即将为Root用户(2352016835@qq.com)初始化12个预设菜谱。\n\n'
            '这些菜谱将作为所有新用户的预设菜谱来源。\n\n'
            '确定继续吗？'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定初始化'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // 获取云端仓库
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      
      // 执行Root用户初始化
      const rootUserId = '2352016835@qq.com';
      final successCount = await JsonRecipeImporter.initializeRootPresetRecipes(
        rootUserId,
        repository
      );
      
      if (successCount > 0) {
        _showSuccessMessage('✅ 成功为Root用户初始化 $successCount 个预设菜谱！');
      } else {
        _showErrorMessage('❌ Root用户预设菜谱初始化失败');
      }
      
    } catch (e) {
      debugPrint('❌ Root用户预设菜谱初始化异常: $e');
      _showErrorMessage('初始化失败：$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// 📥 导入示例菜谱
  Future<void> _importSampleRecipes() async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      // 获取当前用户
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        _showErrorMessage('请先登录');
        return;
      }
      
      // 加载示例菜谱
      final sampleRecipes = await JsonRecipeImporter.loadSampleRecipes();
      if (sampleRecipes.isEmpty) {
        _showErrorMessage('加载示例菜谱失败');
        return;
      }
      
      // 获取云端仓库
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      
      // 显示导入确认
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认导入'),
          content: Text(
            '即将导入 ${sampleRecipes.length} 个示例菜谱到您的账户：\n\n'
            '${sampleRecipes.map((r) => '• ${r.name}').join('\n')}\n\n'
            '这些菜谱将添加到您的菜谱列表中。'
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认导入'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // 执行导入
      final successCount = await JsonRecipeImporter.importRecipesToCloud(
        sampleRecipes, 
        currentUser.uid, 
        repository
      );
      
      _showSuccessMessage('成功导入 $successCount 个示例菜谱！');
      
    } catch (e) {
      debugPrint('❌ 导入示例菜谱失败: $e');
      _showErrorMessage('导入失败：$e');
    } finally {
      setState(() => _isProcessing = false);
    }
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
  
  /// 💾 快速备份
  Future<void> _quickBackup() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      await _backupService.quickBackup(context);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  /// 🗑️ 清空数据
  Future<void> _clearAllData() async {
    if (_isProcessing) return;
    
    // 二次确认
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ 危险操作'),
        content: Text(
          '确定要清空所有菜谱数据吗？\n\n此操作不可恢复！建议先导出备份。',
          style: TextStyle(height: 1.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              '确定清空',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();
    
    try {
      final repository = await ref.read(initializedRecipeRepositoryProvider.future);
      final allRecipes = repository.getAllRecipes();
      
      for (final recipe in allRecipes) {
        await repository.deleteRecipe(recipe.id);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已清空所有数据'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清空失败：$e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
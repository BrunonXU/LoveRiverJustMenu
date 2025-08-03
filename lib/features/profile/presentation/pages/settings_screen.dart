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
import '../../../../core/utils/clean_duplicate_presets_script.dart';
import '../../../../core/utils/reset_presets_script.dart';
import '../../../../core/utils/add_step_emojis_script.dart';
import '../../../../core/utils/setup_root_preset_recipes_script.dart';

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
        
        // 🏗️ 新增：Root架构重置（推荐方案）
        _buildSettingItem(
          icon: Icons.architecture,
          iconColor: Colors.blue,
          title: '🏗️ Root架构重置预设菜谱',
          subtitle: '正确的架构：Root用户统一管理，所有用户共享查看',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _setupRootPresetRecipes(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 🔄 旧方案：一键重置预设菜谱（临时方案）
        _buildSettingItem(
          icon: Icons.refresh,
          iconColor: Colors.red,
          title: '🚨 一键重置预设菜谱（旧方案）',
          subtitle: '彻底删除所有预设菜谱，重新创建干净的12个标准版本',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _resetAllPresets(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 🗑️ 清理重复预设菜谱（温和方案）
        _buildSettingItem(
          icon: Icons.cleaning_services,
          iconColor: Colors.purple,
          title: '清理重复预设菜谱',
          subtitle: '🧹 删除数据库中没有emoji的旧版本预设菜谱',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _cleanDuplicatePresets(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 🎨 新增：为烹饪步骤添加emoji
        _buildSettingItem(
          icon: Icons.emoji_emotions,
          iconColor: Colors.pink,
          title: '🎨 添加烹饪步骤emoji',
          subtitle: '为所有菜谱的烹饪步骤自动添加emoji图标',
          isDark: isDark,
          onTap: _isProcessing ? null : () => _addStepEmojis(),
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
  
  /// 🏗️ Root架构重置预设菜谱（正确的解决方案）
  Future<void> _setupRootPresetRecipes() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      
      // 显示架构说明并确认
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🏗️ Root架构重置预设菜谱'),
          content: const Text(
            '正确的预设菜谱架构设计：\\n\\n'
            '🔧 架构原理：\\n'
            '• Root用户(2352...@qq.com)统一管理所有预设菜谱\\n'
            '• 预设菜谱标记为：isPreset=true, isPublic=true\\n'
            '• 所有用户通过查询共享这些菜谱\\n'
            '• 用户可以收藏，但不复制数据\\n\\n'
            '🎯 解决问题：\\n'
            '• 消除数据源混乱（本地JSON vs 云端数据）\\n'
            '• 确保所有用户看到相同的预设菜谱\\n'
            '• 简化数据同步和更新流程\\n'
            '• 提供统一的管理入口\\n\\n'
            '⚠️ 此操作将：\\n'
            '• 删除所有现有的错误预设菜谱\\n'
            '• 创建12个标准Root预设菜谱\\n'
            '• 每个菜谱包含完整的步骤emoji\\n\\n'
            '✨ 执行后，所有用户将看到统一的预设菜谱！',
            style: TextStyle(height: 1.4),
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
                '确认重置',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // 执行Root架构重置
      final result = await SetupRootPresetRecipesScript.resetRootPresetRecipes(repository);
      
      if (result['final_status'] == 'success') {
        _showSuccessMessage(
          '🎉 Root架构重置成功！\\n\\n'
          '📊 执行结果：\\n'
          '• 清理旧预设：${result['cleanup_deleted']} 个\\n'
          '• 创建Root预设：${result['created_count']} 个\\n'
          '• 清理错误：${result['cleanup_errors']} 个\\n'
          '• 创建错误：${result['create_errors']} 个\\n\\n'
          '✅ 现在所有用户都将看到Root用户管理的\\n'
          '统一标准预设菜谱！\\n\\n'
          '🔧 每个预设菜谱都有完整的emoji图标，\\n'
          '烹饪模式现在应该正常显示了！'
        );
      } else if (result['final_status'] == 'partial_success') {
        _showErrorMessage(
          '⚠️ Root架构重置部分成功\\n\\n'
          '清理：${result['cleanup_deleted']} 个\\n'
          '创建：${result['created_count']} 个\\n'
          '总错误：${(result['cleanup_errors'] ?? 0) + (result['create_errors'] ?? 0)} 个\\n\\n'
          '请检查控制台日志了解详情'
        );
      } else {
        _showErrorMessage(
          '❌ Root架构重置失败\\n\\n'
          '${result.containsKey('error') ? result['error'] : '未知错误'}'
        );
      }
      
    } catch (e) {
      debugPrint('❌ Root架构重置失败: $e');
      _showErrorMessage('架构重置失败：$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// 🔄 一键重置预设菜谱（彻底解决方案）
  Future<void> _resetAllPresets() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      
      // 先检查当前状态
      final status = await ResetPresetsScript.checkPresetStatus(repository);
      
      if (status.containsKey('error')) {
        _showErrorMessage('检查状态失败：${status['error']}');
        return;
      }
      
      // 显示详细的重置确认
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🚨 预设菜谱完全重置'),
          content: Text(
            '当前预设菜谱状态：\n\n'
            '📊 总数量：${status['total_presets']} 个\n'
            '📊 唯一名称：${status['unique_names']} 种\n'
            '📊 有emoji：${status['with_emoji']} 个\n'
            '📊 无emoji：${status['without_emoji']} 个\n'
            '📊 期望数量：${status['expected_count']} 个\n\n'
            '🔄 重置操作将：\n'
            '• 强制删除所有现有预设菜谱\n'
            '• 重新创建12个标准预设菜谱\n'
            '• 每个菜谱都有emoji图标\n'
            '• 彻底解决重复问题\n\n'
            '⚠️ 此操作不可撤销，是否继续？',
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
                '确认重置',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // 执行重置
      final result = await ResetPresetsScript.resetAllPresets(repository);
      
      if (result['final_status'] == 'success') {
        _showSuccessMessage(
          '🎉 预设菜谱重置成功！\n\n'
          '📊 重置结果：\n'
          '• 删除旧菜谱：${result['total_deleted']} 个\n'
          '• 创建新菜谱：${result['created_new']} 个\n'
          '• 删除错误：${result['delete_errors']} 个\n\n'
          '✅ 现在数据库中有12个标准预设菜谱，\n每个都有emoji图标！'
        );
      } else if (result['final_status'] == 'partial_success') {
        _showErrorMessage(
          '⚠️ 重置部分成功\n\n'
          '删除：${result['total_deleted']} 个\n'
          '创建：${result['created_new']} 个\n'
          '错误：${result['delete_errors']} 个\n\n'
          '请检查控制台日志了解详情'
        );
      } else {
        _showErrorMessage(
          '❌ 重置失败\n\n'
          '${result.containsKey('error') ? result['error'] : '未知错误'}'
        );
      }
      
    } catch (e) {
      debugPrint('❌ 重置预设菜谱失败: $e');
      _showErrorMessage('重置失败：$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// 🎨 为烹饪步骤添加emoji图标
  Future<void> _addStepEmojis() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      
      // 先分析现状
      final analysis = await AddStepEmojisScript.analyzeStepEmojiStatus(repository);
      
      if (analysis.containsKey('error')) {
        _showErrorMessage('分析失败：${analysis['error']}');
        return;
      }
      
      // 显示分析结果并确认添加
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎨 烹饪步骤emoji添加'),
          content: Text(
            '当前烹饪步骤emoji状态：\\n\\n'
            '📊 数据分析：\\n'
            '• 总菜谱数：${analysis['total_recipes']} 个\\n'
            '• 总步骤数：${analysis['total_steps']} 个\\n'
            '• 有emoji步骤：${analysis['steps_with_emoji']} 个\\n'
            '• 无emoji步骤：${analysis['steps_without_emoji']} 个\\n'
            '• emoji覆盖率：${analysis['coverage_percentage']}%\\n'
            '• 需要更新菜谱：${analysis['recipes_needing_update']} 个\\n\\n'
            '🎨 将执行操作：\\n'
            '• 为每个烹饪步骤智能分配emoji图标\\n'
            '• 根据步骤内容选择最合适的emoji\\n'
            '• 保持已有emoji不变\\n'
            '• 提升烹饪模式视觉体验\\n\\n'
            '✨ 这将让烹饪过程更加生动有趣！',
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
                '确认添加',
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // 执行添加emoji
      final result = await AddStepEmojisScript.addStepEmojisToPresets(repository);
      
      if (result['status'] == 'success') {
        _showSuccessMessage(
          '🎉 步骤emoji添加成功！\\n\\n'
          '📊 处理结果：\\n'
          '• 总菜谱数：${result['total_recipes']} 个\\n'
          '• 更新菜谱：${result['updated_count']} 个\\n'
          '• 跳过菜谱：${result['skip_count']} 个\\n\\n'
          '✨ 现在所有烹饪步骤都有生动的emoji图标了！\\n'
          '🍳 快去烹饪模式体验全新的视觉效果吧！'
        );
      } else if (result['status'] == 'partial_success') {
        _showErrorMessage(
          '⚠️ 步骤emoji添加部分成功\\n\\n'
          '更新：${result['updated_count']} 个\\n'
          '跳过：${result['skip_count']} 个\\n'
          '错误：${result['error_count']} 个\\n\\n'
          '请检查控制台日志了解详情'
        );
      } else {
        _showErrorMessage(
          '❌ 步骤emoji添加失败\\n\\n'
          '${result.containsKey('error') ? result['error'] : '未知错误'}'
        );
      }
      
    } catch (e) {
      debugPrint('❌ 添加步骤emoji失败: $e');
      _showErrorMessage('添加失败：$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// 🗑️ 清理重复预设菜谱
  Future<void> _cleanDuplicatePresets() async {
    if (_isProcessing) return;
    
    // 第一步：先分析数据
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    
    try {
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      
      // 分析重复情况
      final analysis = await CleanDuplicatePresetsScript.analyzePresets(repository);
      
      if (analysis.containsKey('error')) {
        _showErrorMessage('分析失败：${analysis['error']}');
        return;
      }
      
      // 显示分析结果并确认清理
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🗑️ 预设菜谱数据清理'),
          content: Text(
            '检测到重复的预设菜谱数据：\n\n'
            '📊 数据分析结果：\n'
            '• 总预设菜谱：${analysis['total']} 个\n'
            '• 有emoji版本：${analysis['with_emoji']} 个\n'
            '• 无emoji版本：${analysis['without_emoji']} 个\n'
            '• 重复菜谱：${(analysis['duplicates'] as Map).length} 种\n\n'
            '🧹 将执行清理：\n'
            '• 删除所有无emoji的旧版本\n'
            '• 删除同名菜谱的重复版本\n'
            '• 保留最新的emoji版本\n\n'
            '⚠️ 此操作不可恢复，是否继续？',
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
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // 执行清理
      final result = await CleanDuplicatePresetsScript.cleanDuplicatePresets(repository);
      
      if (result['errors'] == 0) {
        _showSuccessMessage(
          '🎉 清理完成！\n\n'
          '📊 清理结果：\n'
          '• 删除旧版本：${result['deleted_old']} 个\n'
          '• 删除重复版本：${result['deleted_duplicates']} 个\n'
          '• 剩余预设菜谱：${result['remaining']} 个\n\n'
          '✅ 现在数据库中只保留带emoji的最新版本预设菜谱'
        );
      } else {
        _showErrorMessage(
          '清理部分完成，但有 ${result['errors']} 个错误\n'
          '请查看控制台日志了解详情'
        );
      }
      
    } catch (e) {
      debugPrint('❌ 清理预设菜谱失败: $e');
      _showErrorMessage('清理失败：$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 🗑️ 已删除未实现的功能：
  // - _quickBackup(): 快速备份功能依赖未实现的DataBackupService.quickBackup
  // - _clearAllData(): 清空数据使用错误的repository，逻辑有问题
  // 这些功能可以在未来需要时重新设计和实现
}
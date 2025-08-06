/// 🧪 数据同步调试工具
/// 
/// 提供单用户测试数据同步系统的工具界面
/// 包括缓存状态查看、手动触发同步、模拟更新等功能
/// 
/// 作者: Claude Code
/// 创建时间: 2025-08-06

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/auth/providers/auth_providers.dart';
import '../../../../core/services/providers/cache_providers.dart';
import '../../../../core/services/providers/cached_recipe_providers.dart';
import '../../../../core/models/recipe_update_info.dart';
import '../../../../shared/widgets/minimal_card.dart';

/// 🛠️ 数据同步调试页面
class SyncDebugScreen extends ConsumerStatefulWidget {
  const SyncDebugScreen({super.key});

  @override
  ConsumerState<SyncDebugScreen> createState() => _SyncDebugScreenState();
}

class _SyncDebugScreenState extends ConsumerState<SyncDebugScreen> {
  final List<String> _logs = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('请先登录')),
        body: const Center(child: Text('需要登录才能使用调试工具')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      appBar: AppBar(
        title: const Text('🧪 数据同步调试'),
        backgroundColor: AppColors.getBackgroundColor(isDark),
        foregroundColor: AppColors.getTextPrimaryColor(isDark),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: '清空日志',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息
            _buildUserInfo(currentUser.email ?? '未知', isDark),
            
            // 缓存状态
            _buildCacheStatus(isDark),
            
            // 操作按钮区域 - 紧凑版
            _buildCompactActionButtons(currentUser.uid, isDark),
            
            // 日志区域 - 固定高度，避免溢出
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: _buildLogArea(isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// 👤 用户信息区域
  Widget _buildUserInfo(String email, bool isDark) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: MinimalCard(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Text('测试用户', style: AppTypography.bodyMediumStyle(isDark: isDark)),
          subtitle: Text(email, style: AppTypography.bodySmallStyle(isDark: isDark)),
        ),
      ),
    );
  }

  /// 📊 缓存状态区域
  Widget _buildCacheStatus(bool isDark) {
    final cacheStats = ref.watch(cacheStatsProvider);
    
    return Container(
      margin: AppSpacing.pagePadding.copyWith(top: 0),
      child: MinimalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📦 缓存状态',
              style: AppTypography.titleMediumStyle(isDark: isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: cacheStats.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key}: ${entry.value}'),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎛️ 紧凑版操作按钮区域
  Widget _buildCompactActionButtons(String userId, bool isDark) {
    return Container(
      margin: AppSpacing.pagePadding.copyWith(top: 0),
      child: MinimalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎛️ 测试操作',
              style: AppTypography.titleMediumStyle(isDark: isDark),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // 使用网格布局，2列显示，更紧凑
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              children: [
                _CompactButton(emoji: '🔄', title: '登录同步', color: Colors.blue, onTap: () => _testLoginSync(userId), isLoading: _isLoading),
                _CompactButton(emoji: '💖', title: '收藏功能', color: Colors.red, onTap: () => _testFavoriteSync(userId), isLoading: _isLoading),
                _CompactButton(emoji: '🌟', title: '预设菜谱', color: Colors.orange, onTap: () => _testPresetRecipes(), isLoading: _isLoading),
                _CompactButton(emoji: '🔍', title: '更新检测', color: Colors.purple, onTap: () => _simulateUpdateDetection(userId), isLoading: _isLoading),
                _CompactButton(emoji: '🧹', title: '清空缓存', color: Colors.red[700]!, onTap: () => _clearLocalCache(), isLoading: _isLoading),
                _CompactButton(emoji: '📱', title: '重置状态', color: Colors.red[900]!, onTap: () => _resetAppState(), isLoading: _isLoading),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎛️ 原版操作按钮区域（保留备用）
  Widget _buildActionButtons(String userId, bool isDark) {
    return Container(
      margin: AppSpacing.pagePadding.copyWith(top: 0),
      child: MinimalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎛️ 测试操作',
              style: AppTypography.titleMediumStyle(isDark: isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // 紧急修复：使用SingleChildScrollView包装，防止溢出
            SingleChildScrollView(
              child: Column(
                children: [
                  // 基础同步测试
                  _buildTestSection('基础功能测试', [
                    _ActionButton(
                      title: '🔄 触发登录同步',
                      subtitle: '模拟登录时的数据同步过程',
                      onTap: () => _testLoginSync(userId),
                      color: Colors.blue,
                      isLoading: _isLoading,
                    ),
                    _ActionButton(
                      title: '💖 测试收藏功能',
                      subtitle: '验证收藏菜谱的显示和同步',
                      onTap: () => _testFavoriteSync(userId),
                      color: Colors.red,
                      isLoading: _isLoading,
                    ),
                    _ActionButton(
                      title: '🌟 检查预设菜谱',
                      subtitle: '验证预设菜谱缓存和更新',
                      onTap: () => _testPresetRecipes(),
                      color: Colors.orange,
                      isLoading: _isLoading,
                    ),
                  ]),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // 高级测试 - 简化版本，避免溢出
                  _buildTestSection('高级测试', [
                    _ActionButton(
                      title: '🔍 模拟更新检测',
                      subtitle: '创建假的更新提示进行UI测试',
                      onTap: () => _simulateUpdateDetection(userId),
                      color: Colors.purple,
                      isLoading: _isLoading,
                    ),
                    _ActionButton(
                      title: '🧹 清空缓存',
                      subtitle: '清除本地数据重新同步',
                      onTap: () => _clearLocalCache(),
                      color: Colors.red[700]!,
                      isLoading: _isLoading,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧪 测试分组
  Widget _buildTestSection(String title, List<Widget> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...actions,
      ],
    );
  }

  /// 📜 日志区域
  Widget _buildLogArea(bool isDark) {
    return Container(
      margin: AppSpacing.pagePadding.copyWith(top: 0),
      child: MinimalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '📜 测试日志',
                  style: AppTypography.titleMediumStyle(isDark: isDark),
                ),
                const Spacer(),
                Text(
                  '${_logs.length} 条记录',
                  style: AppTypography.bodySmallStyle(isDark: isDark),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        '暂无测试日志\n点击上方按钮开始测试',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[_logs.length - 1 - index]; // 最新的在上面
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.getBackgroundSecondaryColor(isDark),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            log,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📝 添加日志
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logs.add('[$timestamp] $message');
    });
  }

  /// 🧹 清空日志
  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  /// 🔄 测试登录同步
  Future<void> _testLoginSync(String userId) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    _addLog('🔄 开始测试登录同步...');
    
    try {
      // 1. 测试用户菜谱同步
      _addLog('📚 获取用户菜谱...');
      final userRecipes = await ref.read(userRecipesProvider(userId).future);
      _addLog('✅ 用户菜谱: ${userRecipes.length} 个');
      
      // 2. 测试收藏同步
      _addLog('💖 获取收藏菜谱...');
      final favoriteRecipes = await ref.read(favoriteRecipesProvider(userId).future);
      _addLog('✅ 收藏菜谱: ${favoriteRecipes.length} 个');
      
      // 3. 测试预设菜谱
      _addLog('🌟 获取预设菜谱...');
      final presetRecipes = await ref.read(presetRecipesProvider.future);
      _addLog('✅ 预设菜谱: ${presetRecipes.length} 个');
      
      _addLog('🎉 登录同步测试完成！');
      
    } catch (e) {
      _addLog('❌ 登录同步测试失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 💖 测试收藏功能
  Future<void> _testFavoriteSync(String userId) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    _addLog('💖 开始测试收藏功能...');
    
    try {
      // 1. 获取当前收藏
      final favoriteRecipes = await ref.read(favoriteRecipesProvider(userId).future);
      _addLog('📋 当前收藏: ${favoriteRecipes.length} 个');
      
      if (favoriteRecipes.isEmpty) {
        _addLog('💡 建议：先在主页收藏一些预设菜谱进行测试');
      } else {
        for (final recipe in favoriteRecipes.take(3)) {
          _addLog('   - ${recipe.name} (${recipe.isPreset ? "预设" : "用户"})');
        }
        if (favoriteRecipes.length > 3) {
          _addLog('   - ...还有 ${favoriteRecipes.length - 3} 个');
        }
      }
      
      _addLog('✅ 收藏功能测试完成');
      
    } catch (e) {
      _addLog('❌ 收藏功能测试失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🌟 测试预设菜谱
  Future<void> _testPresetRecipes() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    _addLog('🌟 开始测试预设菜谱...');
    
    try {
      final presetRecipes = await ref.read(presetRecipesProvider.future);
      _addLog('📊 预设菜谱总数: ${presetRecipes.length}');
      
      // 统计emoji图标的菜谱
      final emojiCount = presetRecipes.where((r) => 
        r.emojiIcon != null && r.emojiIcon!.isNotEmpty).length;
      _addLog('🎨 带emoji图标: $emojiCount 个');
      
      // 显示前几个菜谱
      for (final recipe in presetRecipes.take(5)) {
        final icon = recipe.emojiIcon ?? '🍳';
        _addLog('   $icon ${recipe.name} (${recipe.totalTime}分钟)');
      }
      
      _addLog('✅ 预设菜谱测试完成');
      
    } catch (e) {
      _addLog('❌ 预设菜谱测试失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔍 模拟更新检测
  Future<void> _simulateUpdateDetection(String userId) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    _addLog('🔍 开始模拟更新检测...');
    
    try {
      final cacheService = await ref.read(localCacheServiceProvider.future);
      
      // 创建模拟的更新信息
      final fakeUpdateInfo = RecipeUpdateInfo(
        recipeId: 'test_recipe_id',
        localVersion: DateTime.now().subtract(const Duration(hours: 2)),
        cloudVersion: DateTime.now(),
        changedFields: ['name', 'steps'],
        checkedAt: DateTime.now(),
        importance: UpdateImportance.important,
      );
      
      _addLog('📝 创建模拟更新: ${fakeUpdateInfo.updateLabel}');
      _addLog('⏰ 本地版本: ${fakeUpdateInfo.localVersion}');
      _addLog('☁️ 云端版本: ${fakeUpdateInfo.cloudVersion}');
      _addLog('🔄 变更字段: ${fakeUpdateInfo.changedFields.join(', ')}');
      
      _addLog('💡 提示：在菜谱列表中应该会看到红点提示（如果实现完整的话）');
      _addLog('✅ 更新检测模拟完成');
      
    } catch (e) {
      _addLog('❌ 更新检测模拟失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🧹 清空本地缓存
  Future<void> _clearLocalCache() async {
    if (_isLoading) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 确认清空缓存'),
        content: const Text('这将清除所有本地缓存数据，下次需要重新从云端同步。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确定清空', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => _isLoading = true);
    _addLog('🧹 开始清空本地缓存...');
    
    try {
      final cacheService = await ref.read(localCacheServiceProvider.future);
      await cacheService.clearCache();
      
      _addLog('✅ 本地缓存已清空');
      _addLog('💡 提示：重新启动应用或刷新页面查看效果');
      
    } catch (e) {
      _addLog('❌ 清空缓存失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 📱 重置应用状态
  Future<void> _resetAppState() async {
    if (_isLoading) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 确认重置应用'),
        content: const Text('这将清除所有本地数据并重新登录，相当于重新安装应用。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
            child: const Text('确定重置', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => _isLoading = true);
    _addLog('📱 开始重置应用状态...');
    
    try {
      // 1. 清空缓存
      final cacheService = await ref.read(localCacheServiceProvider.future);
      await cacheService.clearCache();
      _addLog('🧹 本地缓存已清空');
      
      // 2. 登出用户
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      _addLog('🔓 用户已登出');
      
      _addLog('✅ 应用状态重置完成');
      _addLog('🔄 即将跳转到登录页面...');
      
      // 跳转到登录页面
      if (mounted) {
        context.go('/login');
      }
      
    } catch (e) {
      _addLog('❌ 重置应用状态失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

/// 🎯 操作按钮组件
class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final bool isLoading;

  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          ),
                        )
                      : Icon(
                          Icons.play_arrow,
                          color: color,
                          size: 24,
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}

/// 🎯 紧凑按钮组件
class _CompactButton extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _CompactButton({
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
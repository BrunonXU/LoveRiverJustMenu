/// 🔄 预设菜谱重置脚本
/// 
/// 彻底清理所有预设菜谱，然后重新创建干净的12个标准预设菜谱
/// 这是最彻底的解决方案

import 'package:flutter/foundation.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../../features/recipe/domain/models/recipe.dart';
import 'create_preset_recipes_script.dart';

class ResetPresetsScript {
  
  /// 🔄 完全重置预设菜谱（删除所有，重新创建）
  static Future<Map<String, dynamic>> resetAllPresets(RecipeRepository repository) async {
    try {
      debugPrint('🔄 开始完全重置预设菜谱...');
      
      // 第一步：获取所有预设菜谱并强制删除
      final allPresets = await repository.getPresetRecipes();
      debugPrint('📋 找到 ${allPresets.length} 个预设菜谱，准备全部删除');
      
      int deletedCount = 0;
      int errorCount = 0;
      
      for (final recipe in allPresets) {
        try {
          final success = await repository.forceDeleteRecipe(recipe.id);
          if (success) {
            debugPrint('🗑️ 删除预设菜谱: ${recipe.name} (${recipe.id})');
            deletedCount++;
          } else {
            debugPrint('❌ 删除失败: ${recipe.name}');
            errorCount++;
          }
        } catch (e) {
          debugPrint('❌ 删除异常: ${recipe.name} - $e');
          errorCount++;
        }
      }
      
      debugPrint('🗑️ 删除阶段完成: 成功 $deletedCount, 失败 $errorCount');
      
      // 第二步：等待一下，确保删除完成
      await Future.delayed(Duration(seconds: 2));
      
      // 第三步：重新创建标准的12个预设菜谱
      debugPrint('🚀 开始重新创建标准预设菜谱...');
      final createResult = await CreatePresetRecipesScript.createPublicPresetRecipes(repository);
      
      final result = {
        'total_deleted': deletedCount,
        'delete_errors': errorCount,
        'created_new': createResult,
        'final_status': createResult == 12 ? 'success' : 'partial_success',
      };
      
      debugPrint('🎉 预设菜谱重置完成！');
      debugPrint('📊 删除数量: $deletedCount');
      debugPrint('📊 删除错误: $errorCount');
      debugPrint('📊 新建数量: $createResult');
      debugPrint('📊 最终状态: ${result['final_status']}');
      
      return result;
      
    } catch (e) {
      debugPrint('❌ 预设菜谱重置失败: $e');
      return {
        'error': e.toString(),
        'final_status': 'failed',
      };
    }
  }
  
  /// 🔍 检查预设菜谱当前状态
  static Future<Map<String, dynamic>> checkPresetStatus(RecipeRepository repository) async {
    try {
      final allPresets = await repository.getPresetRecipes();
      final nameGroups = <String, List<Recipe>>{};
      
      for (final recipe in allPresets) {
        nameGroups.putIfAbsent(recipe.name, () => []).add(recipe);
      }
      
      final duplicates = <String, int>{};
      for (final entry in nameGroups.entries) {
        if (entry.value.length > 1) {
          duplicates[entry.key] = entry.value.length;
        }
      }
      
      final withEmoji = allPresets.where((r) => r.emojiIcon != null && r.emojiIcon!.isNotEmpty).length;
      final withoutEmoji = allPresets.length - withEmoji;
      
      return {
        'total_presets': allPresets.length,
        'unique_names': nameGroups.length,
        'with_emoji': withEmoji,
        'without_emoji': withoutEmoji,
        'duplicates': duplicates,
        'needs_cleanup': duplicates.isNotEmpty || allPresets.length != 12,
        'expected_count': 12,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
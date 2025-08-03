/// 🗑️ 清理重复预设菜谱脚本
/// 
/// 目的：删除数据库中没有emoji图标的旧版本预设菜谱
/// 保留：isPreset=true 且 emojiIcon!=null 的新版本
/// 删除：isPreset=true 且 emojiIcon==null 的旧版本

import 'package:flutter/foundation.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../../features/recipe/domain/models/recipe.dart';

class CleanDuplicatePresetsScript {
  
  /// 🗑️ 清理重复的预设菜谱数据
  static Future<Map<String, int>> cleanDuplicatePresets(RecipeRepository repository) async {
    try {
      debugPrint('🗑️ 开始清理重复预设菜谱...');
      
      // 1. 获取所有预设菜谱
      final allPresets = await repository.getPresetRecipes();
      debugPrint('📋 找到 ${allPresets.length} 个预设菜谱');
      
      // 2. 分类：有emoji vs 无emoji
      final presetsWithEmoji = <Recipe>[];
      final presetsWithoutEmoji = <Recipe>[];
      
      for (final recipe in allPresets) {
        if (recipe.emojiIcon != null && recipe.emojiIcon!.isNotEmpty) {
          presetsWithEmoji.add(recipe);
        } else {
          presetsWithoutEmoji.add(recipe);
        }
      }
      
      debugPrint('✅ 有emoji的预设菜谱: ${presetsWithEmoji.length}');
      debugPrint('🗑️ 无emoji的预设菜谱: ${presetsWithoutEmoji.length}');
      
      // 3. 删除没有emoji的旧版本
      int deletedCount = 0;
      int errorCount = 0;
      
      for (final oldRecipe in presetsWithoutEmoji) {
        try {
          await repository.deleteRecipe(oldRecipe.id, oldRecipe.createdBy);
          debugPrint('🗑️ 已删除旧预设菜谱: ${oldRecipe.name}');
          deletedCount++;
        } catch (e) {
          debugPrint('❌ 删除失败: ${oldRecipe.name} - $e');
          errorCount++;
        }
      }
      
      // 4. 检查菜谱名称重复情况
      final nameGroups = <String, List<Recipe>>{};
      for (final recipe in presetsWithEmoji) {
        nameGroups.putIfAbsent(recipe.name, () => []).add(recipe);
      }
      
      // 5. 删除同名菜谱中多余的版本（保留最新的）
      int duplicateDeletedCount = 0;
      for (final entry in nameGroups.entries) {
        final recipesWithSameName = entry.value;
        if (recipesWithSameName.length > 1) {
          debugPrint('⚠️ 发现同名菜谱: ${entry.key} (${recipesWithSameName.length}个)');
          
          // 按创建时间排序，保留最新的
          recipesWithSameName.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final toKeep = recipesWithSameName.first;
          final toDelete = recipesWithSameName.skip(1).toList();
          
          debugPrint('✅ 保留: ${toKeep.name} (${toKeep.createdAt})');
          
          for (final duplicateRecipe in toDelete) {
            try {
              await repository.deleteRecipe(duplicateRecipe.id, duplicateRecipe.createdBy);
              debugPrint('🗑️ 删除重复: ${duplicateRecipe.name} (${duplicateRecipe.createdAt})');
              duplicateDeletedCount++;
            } catch (e) {
              debugPrint('❌ 删除重复菜谱失败: ${duplicateRecipe.name} - $e');
              errorCount++;
            }
          }
        }
      }
      
      final result = {
        'deleted_old': deletedCount,
        'deleted_duplicates': duplicateDeletedCount,
        'errors': errorCount,
        'remaining': presetsWithEmoji.length - duplicateDeletedCount,
      };
      
      debugPrint('🎉 清理完成！');
      debugPrint('📊 删除旧版本: $deletedCount');
      debugPrint('📊 删除重复版本: $duplicateDeletedCount');
      debugPrint('📊 错误数量: $errorCount');
      debugPrint('📊 剩余预设菜谱: ${result['remaining']}');
      
      return result;
      
    } catch (e) {
      debugPrint('❌ 清理预设菜谱失败: $e');
      return {'errors': 1};
    }
  }
  
  /// 🔍 分析预设菜谱重复情况（不执行删除）
  static Future<Map<String, dynamic>> analyzePresets(RecipeRepository repository) async {
    try {
      debugPrint('🔍 开始分析预设菜谱重复情况...');
      
      final allPresets = await repository.getPresetRecipes();
      final analysis = <String, dynamic>{
        'total': allPresets.length,
        'with_emoji': 0,
        'without_emoji': 0,
        'duplicates': <String, int>{},
      };
      
      final nameGroups = <String, List<Recipe>>{};
      
      for (final recipe in allPresets) {
        // 统计emoji情况
        if (recipe.emojiIcon != null && recipe.emojiIcon!.isNotEmpty) {
          analysis['with_emoji']++;
        } else {
          analysis['without_emoji']++;
        }
        
        // 按名称分组
        nameGroups.putIfAbsent(recipe.name, () => []).add(recipe);
      }
      
      // 统计重复情况
      for (final entry in nameGroups.entries) {
        if (entry.value.length > 1) {
          analysis['duplicates'][entry.key] = entry.value.length;
        }
      }
      
      debugPrint('📊 分析结果:');
      debugPrint('   总数: ${analysis['total']}');
      debugPrint('   有emoji: ${analysis['with_emoji']}');
      debugPrint('   无emoji: ${analysis['without_emoji']}');
      debugPrint('   重复菜谱: ${analysis['duplicates']}');
      
      return analysis;
      
    } catch (e) {
      debugPrint('❌ 分析预设菜谱失败: $e');
      return {'error': e.toString()};
    }
  }
}
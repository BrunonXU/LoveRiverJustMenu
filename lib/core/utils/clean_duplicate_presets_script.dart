/// 🗑️ 清理重复预设菜谱脚本
/// 
/// 目的：删除数据库中没有emoji图标的旧版本预设菜谱
/// 保留：isPreset=true 且 emojiIcon!=null 的新版本
/// 删除：isPreset=true 且 emojiIcon==null 的旧版本

import 'package:flutter/foundation.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../../features/recipe/domain/models/recipe.dart';

class CleanDuplicatePresetsScript {
  
  /// 🗑️ 清理重复的预设菜谱数据 - 加强版
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
      
      // 4. 使用更严格的去重逻辑：按菜谱名称分组，每个名称只保留一个
      final nameGroups = <String, List<Recipe>>{};
      final allPresetsToProcess = [...presetsWithEmoji, ...presetsWithoutEmoji]; // 包含所有预设菜谱
      
      for (final recipe in allPresetsToProcess) {
        nameGroups.putIfAbsent(recipe.name, () => []).add(recipe);
      }
      
      // 5. 每个菜谱名称只保留最好的版本
      int duplicateDeletedCount = 0;
      final keepList = <Recipe>[];
      
      for (final entry in nameGroups.entries) {
        final recipesWithSameName = entry.value;
        debugPrint('📝 处理菜谱: ${entry.key} (${recipesWithSameName.length}个版本)');
        
        if (recipesWithSameName.length == 1) {
          // 只有一个版本，直接保留
          keepList.add(recipesWithSameName.first);
          continue;
        }
        
        // 多个版本：优先保留有emoji的，其次按创建时间排序
        Recipe? bestRecipe;
        
        // 首先查找有emoji的版本
        final withEmoji = recipesWithSameName.where((r) => r.emojiIcon != null && r.emojiIcon!.isNotEmpty).toList();
        if (withEmoji.isNotEmpty) {
          // 按创建时间排序，保留最新的有emoji版本
          withEmoji.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          bestRecipe = withEmoji.first;
        } else {
          // 没有emoji版本，按创建时间保留最新的
          recipesWithSameName.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          bestRecipe = recipesWithSameName.first;
        }
        
        keepList.add(bestRecipe);
        debugPrint('✅ 保留: ${bestRecipe.name} (emoji: ${bestRecipe.emojiIcon}, 时间: ${bestRecipe.createdAt})');
        
        // 删除其他版本
        final toDelete = recipesWithSameName.where((r) => r.id != bestRecipe!.id).toList();
        for (final duplicateRecipe in toDelete) {
          try {
            await repository.deleteRecipe(duplicateRecipe.id, duplicateRecipe.createdBy);
            debugPrint('🗑️ 删除重复: ${duplicateRecipe.name} (${duplicateRecipe.id})');
            duplicateDeletedCount++;
          } catch (e) {
            debugPrint('❌ 删除重复菜谱失败: ${duplicateRecipe.name} - $e');
            errorCount++;
          }
        }
      }
      
      final result = {
        'deleted_old': deletedCount,
        'deleted_duplicates': duplicateDeletedCount,
        'errors': errorCount,
        'remaining': keepList.length, // 实际保留的菜谱数量
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
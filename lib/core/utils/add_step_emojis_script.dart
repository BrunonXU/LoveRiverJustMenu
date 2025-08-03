/// 🎨 为现有菜谱步骤添加emoji图标脚本
/// 
/// 目的：为数据库中没有步骤emoji的菜谱自动添加emoji图标
/// 适用：所有现有的预设菜谱和用户菜谱

import 'package:flutter/foundation.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../../features/recipe/domain/models/recipe.dart';
import 'emoji_allocator.dart';

class AddStepEmojisScript {
  
  /// 🎨 为所有预设菜谱添加步骤emoji
  static Future<Map<String, dynamic>> addStepEmojisToPresets(RecipeRepository repository) async {
    try {
      debugPrint('🎨 开始为预设菜谱添加步骤emoji...');
      
      // 获取所有预设菜谱
      final presetRecipes = await repository.getPresetRecipes();
      debugPrint('📋 找到 ${presetRecipes.length} 个预设菜谱');
      
      int updatedCount = 0;
      int skipCount = 0;
      int errorCount = 0;
      
      for (final recipe in presetRecipes) {
        try {
          bool needsUpdate = false;
          final updatedSteps = <RecipeStep>[];
          
          // 检查每个步骤是否需要emoji
          for (int i = 0; i < recipe.steps.length; i++) {
            final step = recipe.steps[i];
            
            if (step.emojiIcon == null || step.emojiIcon!.isEmpty) {
              // 需要添加emoji
              final emoji = EmojiAllocator.allocateStepEmoji(
                step.title,
                step.description,
                i,
              );
              
              final updatedStep = step.copyWith(emojiIcon: emoji);
              updatedSteps.add(updatedStep);
              needsUpdate = true;
              
              debugPrint('🎨 为步骤添加emoji: ${recipe.name} - ${step.title} -> $emoji');
            } else {
              // 已有emoji，保持不变
              updatedSteps.add(step);
            }
          }
          
          if (needsUpdate) {
            // 更新菜谱
            final updatedRecipe = recipe.copyWith(steps: updatedSteps);
            await repository.saveRecipe(updatedRecipe, recipe.createdBy);
            updatedCount++;
            debugPrint('✅ 更新预设菜谱: ${recipe.name}');
          } else {
            skipCount++;
            debugPrint('⏭️ 跳过已有emoji的菜谱: ${recipe.name}');
          }
          
        } catch (e) {
          debugPrint('❌ 更新菜谱失败: ${recipe.name} - $e');
          errorCount++;
        }
      }
      
      final result = {
        'total_recipes': presetRecipes.length,
        'updated_count': updatedCount,
        'skip_count': skipCount,
        'error_count': errorCount,
        'status': errorCount == 0 ? 'success' : 'partial_success',
      };
      
      debugPrint('🎉 预设菜谱步骤emoji添加完成！');
      debugPrint('📊 总菜谱数: ${result['total_recipes']}');
      debugPrint('📊 更新数量: ${result['updated_count']}');
      debugPrint('📊 跳过数量: ${result['skip_count']}');
      debugPrint('📊 错误数量: ${result['error_count']}');
      debugPrint('📊 最终状态: ${result['status']}');
      
      return result;
      
    } catch (e) {
      debugPrint('❌ 添加步骤emoji失败: $e');
      return {
        'error': e.toString(),
        'status': 'failed',
      };
    }
  }
  
  /// 🔍 分析现有菜谱的步骤emoji状态
  static Future<Map<String, dynamic>> analyzeStepEmojiStatus(RecipeRepository repository) async {
    try {
      debugPrint('🔍 开始分析预设菜谱步骤emoji状态...');
      
      final presetRecipes = await repository.getPresetRecipes();
      
      int totalRecipes = presetRecipes.length;
      int totalSteps = 0;
      int stepsWithEmoji = 0;
      int stepsWithoutEmoji = 0;
      int recipesNeedingUpdate = 0;
      
      final recipeDetails = <Map<String, dynamic>>[];
      
      for (final recipe in presetRecipes) {
        bool recipeNeedsUpdate = false;
        int recipeStepsWithEmoji = 0;
        int recipeStepsWithoutEmoji = 0;
        
        for (final step in recipe.steps) {
          totalSteps++;
          
          if (step.emojiIcon != null && step.emojiIcon!.isNotEmpty) {
            stepsWithEmoji++;
            recipeStepsWithEmoji++;
          } else {
            stepsWithoutEmoji++;
            recipeStepsWithoutEmoji++;
            recipeNeedsUpdate = true;
          }
        }
        
        if (recipeNeedsUpdate) {
          recipesNeedingUpdate++;
        }
        
        recipeDetails.add({
          'name': recipe.name,
          'total_steps': recipe.steps.length,
          'steps_with_emoji': recipeStepsWithEmoji,
          'steps_without_emoji': recipeStepsWithoutEmoji,
          'needs_update': recipeNeedsUpdate,
        });
      }
      
      final analysis = {
        'total_recipes': totalRecipes,
        'total_steps': totalSteps,
        'steps_with_emoji': stepsWithEmoji,
        'steps_without_emoji': stepsWithoutEmoji,
        'recipes_needing_update': recipesNeedingUpdate,
        'coverage_percentage': totalSteps > 0 ? (stepsWithEmoji / totalSteps * 100).round() : 0,
        'recipe_details': recipeDetails,
      };
      
      debugPrint('📊 步骤emoji状态分析结果：');
      debugPrint('   总菜谱数: ${analysis['total_recipes']}');
      debugPrint('   总步骤数: ${analysis['total_steps']}');
      debugPrint('   有emoji步骤: ${analysis['steps_with_emoji']}');
      debugPrint('   无emoji步骤: ${analysis['steps_without_emoji']}');
      debugPrint('   需要更新的菜谱: ${analysis['recipes_needing_update']}');
      debugPrint('   emoji覆盖率: ${analysis['coverage_percentage']}%');
      
      return analysis;
      
    } catch (e) {
      debugPrint('❌ 分析步骤emoji状态失败: $e');
      return {'error': e.toString()};
    }
  }
}
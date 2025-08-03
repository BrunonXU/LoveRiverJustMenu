import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/core/utils/create_preset_recipes_script.dart';
import 'lib/core/firestore/repositories/recipe_repository.dart';

/// 🛠️ 紧急修复脚本：立即创建预设菜谱到Firebase
/// 这个脚本会检查并创建缺失的带emoji的预设菜谱
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 初始化Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 初始化成功');
    
    // 创建仓库实例
    final repository = CloudRecipeRepository();
    
    print('🔍 开始检查并创建预设菜谱...');
    
    // 检查现有预设菜谱
    final existingPresets = await repository.getPresetRecipes();
    print('📊 当前预设菜谱数量: ${existingPresets.length}');
    
    if (existingPresets.isEmpty) {
      print('🚀 没有预设菜谱，开始创建...');
      
      // 创建预设菜谱
      final successCount = await CreatePresetRecipesScript.createPublicPresetRecipes(repository);
      
      if (successCount > 0) {
        print('🎉 成功创建 $successCount 个预设菜谱');
        
        // 再次检查
        final newPresets = await repository.getPresetRecipes();
        print('✅ 验证：现在有 ${newPresets.length} 个预设菜谱');
        
        // 检查emoji
        for (final preset in newPresets) {
          if (preset.emojiIcon != null && preset.emojiIcon!.isNotEmpty) {
            print('🎭 ${preset.name}: ${preset.emojiIcon}');
          } else {
            print('❌ ${preset.name}: 缺少emoji');
          }
        }
        
      } else {
        print('❌ 创建预设菜谱失败');
      }
    } else {
      print('ℹ️ 预设菜谱已存在，检查emoji...');
      
      int emojiCount = 0;
      for (final preset in existingPresets) {
        if (preset.emojiIcon != null && preset.emojiIcon!.isNotEmpty) {
          emojiCount++;
          print('🎭 ${preset.name}: ${preset.emojiIcon}');
        } else {
          print('❌ ${preset.name}: 缺少emoji');
        }
      }
      
      print('📊 总结：${existingPresets.length} 个预设菜谱中，$emojiCount 个有emoji');
    }
    
  } catch (e) {
    print('❌ 执行失败: $e');
  }
  
  print('🏁 脚本执行完成');
}
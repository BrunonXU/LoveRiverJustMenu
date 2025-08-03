/// 🏗️ 设置Root用户预设菜谱架构脚本
/// 
/// 正确的架构设计：
/// 1. Root用户(2352016835@qq.com)管理所有预设菜谱
/// 2. 预设菜谱标记为：isPreset=true, isPublic=true
/// 3. 所有用户通过查询共享这些菜谱
/// 4. 用户可以收藏，但不复制数据

import 'package:flutter/foundation.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../../features/recipe/domain/models/recipe.dart';
import 'emoji_allocator.dart';

class SetupRootPresetRecipesScript {
  static const String ROOT_USER_ID = '2352016835@qq.com';
  
  /// 🧹 清理所有错误的预设菜谱数据
  static Future<Map<String, dynamic>> cleanupAllPresetRecipes(RecipeRepository repository) async {
    try {
      debugPrint('🧹 开始清理所有预设菜谱数据...');
      
      // 获取所有标记为预设的菜谱
      final allPresets = await repository.getPresetRecipes();
      int deletedCount = 0;
      int errorCount = 0;
      
      for (final recipe in allPresets) {
        try {
          final success = await repository.forceDeleteRecipe(recipe.id);
          if (success) {
            debugPrint('🗑️ 删除预设菜谱: ${recipe.name} (${recipe.createdBy})');
            deletedCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          debugPrint('❌ 删除失败: ${recipe.name} - $e');
          errorCount++;
        }
      }
      
      return {
        'deleted_count': deletedCount,
        'error_count': errorCount,
        'status': 'cleaned',
      };
    } catch (e) {
      debugPrint('❌ 清理预设菜谱失败: $e');
      return {'error': e.toString(), 'status': 'failed'};
    }
  }
  
  /// 🏗️ 创建Root用户的标准预设菜谱
  static Future<Map<String, dynamic>> createRootPresetRecipes(RecipeRepository repository) async {
    try {
      debugPrint('🏗️ 开始创建Root用户预设菜谱...');
      
      final presetRecipes = _getStandardPresetRecipes();
      int createdCount = 0;
      int errorCount = 0;
      final createdRecipeIds = <String>[];
      
      for (final recipeData in presetRecipes) {
        try {
          // 构建Recipe对象
          final recipe = Recipe(
            id: '', // 新创建，ID为空
            name: recipeData['name'],
            description: recipeData['description'],
            iconType: recipeData['iconType'],
            totalTime: recipeData['totalTime'],
            difficulty: recipeData['difficulty'], 
            servings: recipeData['servings'],
            emojiIcon: recipeData['emojiIcon'], // 菜谱emoji
            
            // 🎨 创建带emoji的步骤
            steps: (recipeData['steps'] as List).asMap().entries.map((entry) {
              final index = entry.key;
              final stepData = entry.value;
              final stepEmoji = EmojiAllocator.allocateStepEmoji(
                stepData['title'],
                stepData['description'],
                index,
              );
              
              return RecipeStep(
                title: stepData['title'],
                description: stepData['description'],
                duration: stepData['duration'],
                tips: stepData['tips'],
                emojiIcon: stepEmoji, // 步骤emoji
                ingredients: List<String>.from(stepData['ingredients']),
              );
            }).toList(),
            
            // 🔧 关键字段：Root用户的公共预设菜谱
            createdBy: ROOT_USER_ID,           // Root用户创建
            isPreset: true,                    // 预设菜谱
            isPublic: true,                    // 公开可见
            sourceType: 'preset',              // 来源：预设
            isShared: false,                   // 不需要共享（已经是公共的）
            
            // 其他字段
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            rating: 4.5,
            cookCount: 0,
            favoriteCount: 0,
            sharedWith: [],
          );
          
          // 保存到云端
          final recipeId = await repository.saveRecipe(recipe, ROOT_USER_ID);
          createdRecipeIds.add(recipeId);
          createdCount++;
          
          debugPrint('✅ 创建Root预设菜谱: ${recipe.name} ($recipeId)');
          
        } catch (e) {
          debugPrint('❌ 创建预设菜谱失败: ${recipeData['name']} - $e');
          errorCount++;
        }
      }
      
      return {
        'created_count': createdCount,
        'error_count': errorCount,
        'created_recipe_ids': createdRecipeIds,
        'status': createdCount == 12 ? 'success' : 'partial_success',
      };
      
    } catch (e) {
      debugPrint('❌ 创建Root预设菜谱失败: $e');
      return {'error': e.toString(), 'status': 'failed'};
    }
  }
  
  /// 🔄 完整重置：清理 + 创建
  static Future<Map<String, dynamic>> resetRootPresetRecipes(RecipeRepository repository) async {
    try {
      debugPrint('🔄 开始完整重置Root预设菜谱架构...');
      
      // 1. 清理所有现有预设菜谱
      final cleanupResult = await cleanupAllPresetRecipes(repository);
      debugPrint('📊 清理结果: ${cleanupResult['deleted_count']} 删除, ${cleanupResult['error_count']} 错误');
      
      // 2. 等待确保删除完成
      await Future.delayed(Duration(seconds: 2));
      
      // 3. 创建新的Root预设菜谱
      final createResult = await createRootPresetRecipes(repository);
      debugPrint('📊 创建结果: ${createResult['created_count']} 创建, ${createResult['error_count']} 错误');
      
      return {
        'cleanup_deleted': cleanupResult['deleted_count'],
        'cleanup_errors': cleanupResult['error_count'],
        'created_count': createResult['created_count'],
        'create_errors': createResult['error_count'],
        'created_recipe_ids': createResult['created_recipe_ids'],
        'final_status': createResult['status'],
      };
      
    } catch (e) {
      debugPrint('❌ 重置Root预设菜谱失败: $e');
      return {'error': e.toString(), 'final_status': 'failed'};
    }
  }
  
  /// 📋 标准12个预设菜谱数据
  static List<Map<String, dynamic>> _getStandardPresetRecipes() {
    return [
      {
        'name': '银耳莲子羹',
        'description': '滋润养颜的经典甜品，口感清香甜润',
        'iconType': 'soup',
        'totalTime': 45,
        'difficulty': '简单',
        'servings': 2,
        'emojiIcon': '🥣',
        'steps': [
          {
            'title': '食材准备',
            'description': '银耳泡发撕成小朵，莲子去心，枸杞洗净',
            'duration': 15,
            'tips': '银耳要完全泡发，莲子去心可避免苦味',
            'ingredients': ['银耳', '莲子', '枸杞', '冰糖'],
          },
          {
            'title': '炖煮过程',
            'description': '银耳先煮20分钟，加入莲子继续煮15分钟，最后加枸杞和冰糖',
            'duration': 30,
            'tips': '小火慢炖，时不时搅拌防止粘锅',
            'ingredients': [],
          },
        ],
      },
      
      {
        'name': '番茄鸡蛋面',
        'description': '家常经典面条，酸甜开胃',
        'iconType': 'noodles',
        'totalTime': 20,
        'difficulty': '简单',
        'servings': 1,
        'emojiIcon': '🍜',
        'steps': [
          {
            'title': '炒制番茄',
            'description': '番茄去皮切块，热油爆炒出汁',
            'duration': 5,
            'tips': '番茄要炒出红油才香',
            'ingredients': ['番茄', '食用油'],
          },
          {
            'title': '煮面装盘',
            'description': '下面条煮熟，加入炒蛋和番茄汁拌匀',
            'duration': 15,
            'tips': '面条不要煮过软',
            'ingredients': ['面条', '鸡蛋'],
          },
        ],
      },
      
      {
        'name': '红烧排骨',
        'description': '色泽红亮，肉质酥烂的经典菜',
        'iconType': 'meat',
        'totalTime': 60,
        'difficulty': '中等',
        'servings': 3,
        'emojiIcon': '🍖',
        'steps': [
          {
            'title': '排骨处理',
            'description': '排骨焯水去腥，控干水分',
            'duration': 15,
            'tips': '焯水时加料酒去腥效果更好',
            'ingredients': ['排骨', '料酒'],
          },
          {
            'title': '红烧炖煮',
            'description': '热油炒糖色，下排骨上色，加调料炖煮40分钟',
            'duration': 45,
            'tips': '炒糖色要小火，避免炒糊',
            'ingredients': ['冰糖', '生抽', '老抽', '八角'],
          },
        ],
      },
      
      {
        'name': '蒸蛋羹',
        'description': '嫩滑如丝的蒸蛋，营养丰富',
        'iconType': 'egg',
        'totalTime': 15,
        'difficulty': '简单',
        'servings': 1,
        'emojiIcon': '🥚',
        'steps': [
          {
            'title': '调制蛋液',
            'description': '鸡蛋打散，加温水和盐调匀，过筛去泡沫',
            'duration': 5,
            'tips': '水和蛋液比例1:1，水温不能太热',
            'ingredients': ['鸡蛋', '温水', '盐'],
          },
          {
            'title': '蒸制过程',
            'description': '盖保鲜膜蒸8-10分钟，关火焖2分钟',
            'duration': 10,
            'tips': '保鲜膜扎几个小孔，避免水汽滴落',
            'ingredients': [],
          },
        ],
      },
      
      {
        'name': '青椒肉丝',
        'description': '经典下饭菜，爽脆可口',
        'iconType': 'vegetable',
        'totalTime': 20,
        'difficulty': '简单',
        'servings': 2,
        'emojiIcon': '🫑',
        'steps': [
          {
            'title': '食材处理',
            'description': '猪肉丝用料酒和生抽腌制，青椒切丝',
            'duration': 10,
            'tips': '肉丝要切得均匀，腌制会更嫩',
            'ingredients': ['猪肉丝', '青椒', '料酒', '生抽'],
          },
          {
            'title': '爆炒调味',
            'description': '先炒肉丝至变色，再下青椒丝炒匀调味',
            'duration': 10,
            'tips': '青椒不要炒太久，保持脆嫩',
            'ingredients': ['盐', '鸡精'],
          },
        ],
      },
      
      {
        'name': '糖醋排骨',
        'description': '酸甜可口的经典川菜',
        'iconType': 'meat',
        'totalTime': 50,
        'difficulty': '中等',
        'servings': 3,
        'emojiIcon': '🍯',
        'steps': [
          {
            'title': '排骨预处理',
            'description': '排骨切段焯水，控干备用',
            'duration': 15,
            'tips': '焯水要彻底，去除血水和腥味',
            'ingredients': ['排骨', '料酒'],
          },
          {
            'title': '调制糖醋汁',
            'description': '生抽、老抽、醋、糖调成糖醋汁',
            'duration': 5,
            'tips': '比例：生抽3:老抽1:醋2:糖4',
            'ingredients': ['生抽', '老抽', '醋', '糖'],
          },
          {
            'title': '炸制上色',
            'description': '排骨炸至金黄，淋糖醋汁收汁',
            'duration': 30,
            'tips': '收汁时要不断翻炒，让每块排骨都裹上汁',
            'ingredients': ['食用油'],
          },
        ],
      },
      
      {
        'name': '宫保鸡丁',
        'description': '经典川菜，麻辣鲜香',
        'iconType': 'meat',
        'totalTime': 25,
        'difficulty': '中等',
        'servings': 2,
        'emojiIcon': '🌶️',
        'steps': [
          {
            'title': '腌制鸡丁',
            'description': '鸡胸肉切丁，用料酒和生抽腌制',
            'duration': 10,
            'tips': '鸡丁大小要均匀，腌制时间不要太久',
            'ingredients': ['鸡胸肉', '料酒', '生抽'],
          },
          {
            'title': '爆炒调味',
            'description': '热油下花椒和干辣椒，再下鸡丁炒制，最后加花生米',
            'duration': 15,
            'tips': '火候要大，动作要快',
            'ingredients': ['花椒', '干辣椒', '花生米', '豆瓣酱'],
          },
        ],
      },
      
      {
        'name': '麻婆豆腐',
        'description': '经典川菜，麻辣鲜香嫩',
        'iconType': 'tofu',
        'totalTime': 20,
        'difficulty': '简单',
        'servings': 2,
        'emojiIcon': '🌶️',
        'steps': [
          {
            'title': '豆腐处理',
            'description': '嫩豆腐切块，用盐水焯一下定型',
            'duration': 5,
            'tips': '焯水可以去豆腥味，还能让豆腐更结实',
            'ingredients': ['嫩豆腐', '盐'],
          },
          {
            'title': '炒制调味',
            'description': '炒豆瓣酱出红油，加豆腐轻炒，勾芡撒花椒粉',
            'duration': 15,
            'tips': '豆腐要轻拌，不要弄碎',
            'ingredients': ['豆瓣酱', '肉末', '花椒粉', '葱花'],
          },
        ],
      },
      
      {
        'name': '清蒸鲈鱼',
        'description': '鲜美清淡的蒸鱼，保持原味',
        'iconType': 'fish',
        'totalTime': 25,
        'difficulty': '中等',
        'servings': 2,
        'emojiIcon': '🐟',
        'steps': [
          {
            'title': '鱼类处理',
            'description': '鲈鱼洗净打花刀，用料酒和盐腌制',
            'duration': 10,
            'tips': '花刀要均匀，便于入味和蒸熟',
            'ingredients': ['鲈鱼', '料酒', '盐', '姜丝'],
          },
          {
            'title': '蒸制调味',
            'description': '上锅蒸8-10分钟，淋蒸鱼豉油和热油',
            'duration': 15,
            'tips': '蒸好后要倒掉蒸出的水，再调味',
            'ingredients': ['蒸鱼豉油', '葱丝', '食用油'],
          },
        ],
      },
      
      {
        'name': '蚂蚁上树',
        'description': '经典川菜，粉丝炒肉末',
        'iconType': 'noodles',
        'totalTime': 20,
        'difficulty': '简单',
        'servings': 2,
        'emojiIcon': '🍝',
        'steps': [
          {
            'title': '粉丝处理',
            'description': '粉丝用温水泡软，控干水分',
            'duration': 10,
            'tips': '粉丝不要泡太久，保持一定韧性',
            'ingredients': ['粉丝'],
          },
          {
            'title': '炒制肉末',
            'description': '肉末炒散，加豆瓣酱炒香',
            'duration': 5,
            'tips': '肉末要炒得粒粒分明',
            'ingredients': ['肉末', '豆瓣酱'],
          },
          {
            'title': '下粉丝调味',
            'description': '下粉丝翻炒，调味炒匀即可',
            'duration': 5,
            'tips': '粉丝容易粘锅，要不停翻炒',
            'ingredients': ['生抽', '老抽', '葱花'],
          },
        ],
      },
      
      {
        'name': '西红柿牛腩',
        'description': '酸甜开胃的炖菜，营养丰富',
        'iconType': 'meat',
        'totalTime': 90,
        'difficulty': '中等',
        'servings': 4,
        'emojiIcon': '🍅',
        'steps': [
          {
            'title': '牛腩处理',
            'description': '牛腩切块焯水，去血沫洗净',
            'duration': 20,
            'tips': '焯水要充分，这样炖出来的汤才清',
            'ingredients': ['牛腩', '料酒'],
          },
          {
            'title': '炖煮过程',
            'description': '牛腩先炖1小时，再加番茄块炖30分钟',
            'duration': 70,
            'tips': '番茄要炒出汁再加，味道更浓郁',
            'ingredients': ['番茄', '洋葱', '土豆'],
          },
        ],
      },
      
      {
        'name': '酸辣土豆丝',
        'description': '爽脆开胃的经典素菜',
        'iconType': 'vegetable',
        'totalTime': 15,
        'difficulty': '简单',
        'servings': 2,
        'emojiIcon': '🥔',
        'steps': [
          {
            'title': '土豆处理',
            'description': '土豆切细丝，用清水冲洗去淀粉',
            'duration': 10,
            'tips': '丝要切得均匀，冲洗后土豆丝更脆',
            'ingredients': ['土豆'],
          },
          {
            'title': '爆炒调味',
            'description': '热油爆香辣椒，下土豆丝炒制，调酸辣味',
            'duration': 5,
            'tips': '大火快炒，保持土豆丝的脆嫩',
            'ingredients': ['干辣椒', '醋', '盐', '糖'],
          },
        ],
      },
    ];
  }
}
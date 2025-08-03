/// 🍳 一次性脚本：直接创建公共预设菜谱
/// 
/// 这个脚本会在数据库中直接创建12个公共预设菜谱
/// 所有用户共享，不需要复制到每个用户账户
/// 
/// 使用方法：在适当的地方调用 createPublicPresetRecipes()

import 'package:flutter/foundation.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../../features/recipe/domain/models/recipe.dart';

class CreatePresetRecipesScript {
  
  /// 🚀 创建公共预设菜谱（一次性执行）
  static Future<int> createPublicPresetRecipes(RecipeRepository repository) async {
    try {
      debugPrint('🚀 开始创建公共预设菜谱...');
      
      // 1. 检查是否已经存在预设菜谱
      final existingPresets = await repository.getPresetRecipes();
      if (existingPresets.isNotEmpty) {
        debugPrint('⚠️ 公共预设菜谱已存在 ${existingPresets.length} 个，跳过创建');
        return existingPresets.length;
      }
      
      // 2. 创建12个经典预设菜谱
      final presetRecipes = _createPresetRecipeData();
      int successCount = 0;
      
      for (int i = 0; i < presetRecipes.length; i++) {
        try {
          final recipeData = presetRecipes[i];
          
          // 创建标准的Recipe对象
          final recipe = Recipe(
            id: '', // 让Firestore自动生成ID
            name: recipeData['name'],
            description: recipeData['description'],
            iconType: recipeData['iconType'],
            totalTime: recipeData['totalTime'],
            difficulty: recipeData['difficulty'],
            servings: recipeData['servings'],
            steps: (recipeData['steps'] as List).map((stepData) => RecipeStep(
              title: stepData['title'],
              description: stepData['description'],
              duration: stepData['duration'],
              tips: stepData['tips'],
              ingredients: List<String>.from(stepData['ingredients']),
            )).toList(),
            
            // 🔧 关键字段：标记为公共预设菜谱
            createdBy: 'system',           // 系统创建
            isPreset: true,                // 预设菜谱
            isPublic: true,                // 公开可见
            sourceType: 'preset',          // 预设来源
            
            // 时间设置
            createdAt: DateTime.now().subtract(Duration(days: 30 + i * 5)), // 分散创建时间
            updatedAt: DateTime.now().subtract(Duration(days: 25 + i * 5)),
            
            // 初始数据
            rating: 4.5 + (i % 3) * 0.15,  // 4.5-4.8分
            cookCount: 100 + i * 20,        // 100-320次
            favoriteCount: 50 + i * 10,     // 50-160次收藏
            emojiIcon: recipeData['emojiIcon'], // 🔧 新增：emoji图标
          );
          
          final recipeId = await repository.saveRecipe(recipe, 'system');
          debugPrint('✅ 公共预设菜谱创建成功: ${recipe.name} -> $recipeId');
          successCount++;
          
        } catch (e) {
          debugPrint('❌ 创建预设菜谱失败: ${presetRecipes[i]['name']} - $e');
        }
      }
      
      debugPrint('🎉 公共预设菜谱创建完成: $successCount/${presetRecipes.length}');
      return successCount;
      
    } catch (e) {
      debugPrint('❌ 创建公共预设菜谱异常: $e');
      return 0;
    }
  }
  
  /// 📝 预设菜谱数据定义
  static List<Map<String, dynamic>> _createPresetRecipeData() {
    return [
      {
        'name': '银耳莲子羹',
        'description': '滋润养颜的经典甜品，口感清香甜美，是秋冬季节的最佳选择',
        'iconType': 'AppIcon3DType.bowl',
        'emojiIcon': '🥣', // 3D立体碗emoji
        'totalTime': 45,
        'difficulty': '简单',
        'servings': 2,
        'steps': [
          {
            'title': '准备食材',
            'description': '银耳一朵提前2小时泡发，莲子50g去芯，冰糖适量。银耳撕成小朵备用。',
            'duration': 15,
            'tips': '银耳要充分泡发，这样煮出来才粘稠',
            'ingredients': ['银耳 1朵', '莲子 50g', '冰糖 适量', '水 1000ml']
          },
          {
            'title': '炖煮过程',
            'description': '将银耳和莲子放入锅中，加足量水，大火煮开后转小火炖煮30分钟至粘稠。',
            'duration': 30,
            'tips': '小火慢炖，保持微沸状态，中途不要揭盖',
            'ingredients': []
          },
          {
            'title': '调味装盛',
            'description': '最后10分钟加入冰糖调味，搅拌均匀至冰糖完全融化即可盛碗享用。',
            'duration': 10,
            'tips': '冰糖不要加太早，以免影响银耳出胶',
            'ingredients': ['冰糖 适量']
          }
        ]
      },
      {
        'name': '番茄鸡蛋面',
        'description': '家常经典面条，酸甜可口，营养丰富，是最温暖的家的味道',
        'iconType': 'AppIcon3DType.spoon',
        'emojiIcon': '🍜', // 3D立体拉面碗emoji
        'totalTime': 15,
        'difficulty': '简单',
        'servings': 1,
        'steps': [
          {
            'title': '准备食材',
            'description': '面条150g，鸡蛋2个打散，番茄2个去皮切块，葱花适量。',
            'duration': 5,
            'tips': '番茄去皮后更容易出汁，口感更好',
            'ingredients': ['面条 150g', '鸡蛋 2个', '番茄 2个', '葱花 适量']
          },
          {
            'title': '炒制番茄',
            'description': '热锅下少许油，倒入番茄块炒出汁水，炒至软烂出汁。',
            'duration': 3,
            'tips': '番茄要充分炒出汁水，这样面条才有味道',
            'ingredients': []
          },
          {
            'title': '煮面调味',
            'description': '加水烧开，下面条煮至8分熟，倒入蛋液快速搅散，最后撒葱花即可。',
            'duration': 7,
            'tips': '倒蛋液时要快速搅拌，形成蛋花状',
            'ingredients': ['水 适量', '盐 少许', '生抽 1勺']
          }
        ]
      },
      {
        'name': '红烧排骨',
        'description': '色泽红亮，口感软糯，是经典的家常硬菜，老少皆宜',
        'iconType': 'AppIcon3DType.meat',
        'emojiIcon': '🍖', // 3D立体肉块emoji
        'totalTime': 60,
        'difficulty': '中等',
        'servings': 3,
        'steps': [
          {
            'title': '处理排骨',
            'description': '排骨500g切段，冷水下锅焯水去血沫，捞起洗净备用。',
            'duration': 15,
            'tips': '焯水要彻底，去除血沫和腥味',
            'ingredients': ['排骨 500g', '料酒 2勺', '姜片 3片']
          },
          {
            'title': '炒糖色',
            'description': '热锅下冰糖小火炒至焦糖色，下排骨翻炒上色。',
            'duration': 10,
            'tips': '糖色不要炒过头，微焦即可',
            'ingredients': ['冰糖 30g', '油 适量']
          },
          {
            'title': '炖煮入味',
            'description': '加生抽、老抽、料酒和开水没过排骨，大火煮开转小火炖35分钟。',
            'duration': 35,
            'tips': '小火慢炖，最后大火收汁',
            'ingredients': ['生抽 3勺', '老抽 1勺', '料酒 2勺', '八角 2个']
          }
        ]
      },
      {
        'name': '蒸蛋羹',
        'description': '嫩滑如豆腐，营养丰富，适合老人小孩的温润美食',
        'iconType': 'AppIcon3DType.egg',
        'emojiIcon': '🥚', // 3D立体鸡蛋emoji
        'totalTime': 20,
        'difficulty': '简单',
        'servings': 2,
        'steps': [
          {
            'title': '调制蛋液',
            'description': '鸡蛋3个打散，加入等量温水搅匀，过筛去泡沫。',
            'duration': 5,
            'tips': '蛋液和水的比例1:1，温水不烫手即可',
            'ingredients': ['鸡蛋 3个', '温水 150ml', '盐 少许']
          },
          {
            'title': '蒸制成型',
            'description': '盖保鲜膜扎几个小孔，水开后上锅蒸12分钟即可。',
            'duration': 15,
            'tips': '保鲜膜防止水蒸气滴入，小孔透气',
            'ingredients': []
          }
        ]
      },
      {
        'name': '青椒肉丝',
        'description': '清爽下饭的经典川菜，色泽搭配完美，口感爽脆',
        'iconType': 'AppIcon3DType.pepper',
        'emojiIcon': '🫑', // 3D立体青椒emoji
        'totalTime': 20,
        'difficulty': '简单',
        'servings': 2,
        'steps': [
          {
            'title': '切丝腌制',
            'description': '肉丝切细用生抽、料酒、淀粉腌制10分钟，青椒切丝。',
            'duration': 12,
            'tips': '肉丝要切得细一些，口感更好',
            'ingredients': ['猪肉丝 200g', '青椒 3个', '生抽 1勺', '料酒 1勺', '淀粉 1勺']
          },
          {
            'title': '大火快炒',
            'description': '热锅下油，先炒肉丝至变色，再下青椒丝大火快炒1分钟即可。',
            'duration': 8,
            'tips': '大火快炒保持青椒爽脆，不要炒老',
            'ingredients': ['油 适量', '盐 少许', '蒜末 2瓣']
          }
        ]
      },
      {
        'name': '爱心早餐',
        'description': '营养丰富的浪漫早餐，用心意温暖每个清晨',
        'iconType': 'AppIcon3DType.heart',
        'emojiIcon': '🥞', // 3D立体煎饼emoji
        'totalTime': 25,
        'difficulty': '简单',
        'servings': 2,
        'steps': [
          {
            'title': '准备食材',
            'description': '面包2片，鸡蛋2个，牛奶200ml，新鲜水果适量。',
            'duration': 5,
            'tips': '选择新鲜的时令水果，营养更丰富',
            'ingredients': ['面包 2片', '鸡蛋 2个', '牛奶 200ml', '草莓 5个', '蓝莓 适量']
          },
          {
            'title': '制作煎蛋',
            'description': '平底锅刷少许油，用心形模具煎制爱心鸡蛋。',
            'duration': 8,
            'tips': '小火慢煎，保持蛋黄半熟状态',
            'ingredients': []
          },
          {
            'title': '精美摆盘',
            'description': '面包片配爱心煎蛋，搭配新鲜水果，温热牛奶装杯。',
            'duration': 12,
            'tips': '用心摆盘，营造浪漫的用餐氛围',
            'ingredients': []
          }
        ]
      },
      // 继续添加其他6个菜谱...
      {
        'name': '糖醋排骨',
        'description': '酸甜开胃的经典菜品，老少皆宜的家常美味',
        'iconType': 'AppIcon3DType.meat',
        'emojiIcon': '🍗', // 3D立体鸡腿肉emoji
        'totalTime': 45,
        'difficulty': '中等',
        'servings': 3,
        'steps': [
          {
            'title': '排骨处理',
            'description': '排骨400g切段焯水，裹淀粉炸至金黄捞起。',
            'duration': 20,
            'tips': '炸制要外酥内嫩，油温控制在170度',
            'ingredients': ['排骨 400g', '淀粉 适量', '油 适量']
          },
          {
            'title': '调制糖醋汁',
            'description': '锅内放糖、醋、生抽、番茄酱小火熬至粘稠。',
            'duration': 10,
            'tips': '糖醋比例2:1，根据个人喜好调整',
            'ingredients': ['白糖 4勺', '醋 2勺', '生抽 1勺', '番茄酱 1勺']
          },
          {
            'title': '裹汁装盘',
            'description': '下炸好的排骨快速翻炒裹匀糖醋汁，撒芝麻装盘。',
            'duration': 15,
            'tips': '动作要快，避免排骨回软',
            'ingredients': ['芝麻 适量', '葱花 少许']
          }
        ]
      },
      {
        'name': '宫保鸡丁',
        'description': '川菜经典，麻辣鲜香，花生米增加口感层次',
        'iconType': 'AppIcon3DType.spoon',
        'emojiIcon': '🌶️', // 3D立体辣椒emoji
        'totalTime': 25,
        'difficulty': '中等',
        'servings': 2,
        'steps': [
          {
            'title': '鸡肉处理',
            'description': '鸡胸肉300g切丁，用蛋清、淀粉、料酒腌制15分钟。',
            'duration': 18,
            'tips': '鸡肉切得均匀一些，腌制时间充足',
            'ingredients': ['鸡胸肉 300g', '蛋清 1个', '淀粉 1勺', '料酒 1勺']
          },
          {
            'title': '炒制调味',
            'description': '热锅滑炒鸡丁至变色，下干辣椒花椒爆香，最后放花生米。',
            'duration': 7,
            'tips': '火候要大，动作要快，保持嫩滑',
            'ingredients': ['花生米 50g', '干辣椒 5个', '花椒 1勺', '葱段 适量']
          }
        ]
      },
      {
        'name': '麻婆豆腐',
        'description': '经典川菜，麻辣鲜香，豆腐嫩滑入味',
        'iconType': 'AppIcon3DType.tofu',
        'emojiIcon': '🧈', // 3D立体豆腐块emoji
        'totalTime': 20,
        'difficulty': '简单',
        'servings': 2,
        'steps': [
          {
            'title': '豆腐处理',
            'description': '嫩豆腐400g切块，用淡盐水浸泡5分钟去豆腥味。',
            'duration': 8,
            'tips': '豆腐要选择嫩豆腐，切块要轻柔',
            'ingredients': ['嫩豆腐 400g', '盐水 适量']
          },
          {
            'title': '炒制调味',
            'description': '下肉末炒香，加豆瓣酱炒出红油，轻柔下豆腐块烧制入味。',
            'duration': 12,
            'tips': '动作要轻，避免豆腐破碎',
            'ingredients': ['猪肉末 100g', '豆瓣酱 2勺', '蒜末 适量', '花椒面 少许']
          }
        ]
      },
      {
        'name': '清蒸鲈鱼',
        'description': '清淡鲜美的粤菜经典，保持鱼肉原汁原味',
        'iconType': 'AppIcon3DType.fish',
        'emojiIcon': '🐟', // 3D立体鱼emoji
        'totalTime': 25,
        'difficulty': '中等',
        'servings': 3,
        'steps': [
          {
            'title': '鱼类处理',
            'description': '鲈鱼1条处理干净，鱼身划几刀，用料酒和盐腌制10分钟。',
            'duration': 15,
            'tips': '刀口要均匀，便于入味和蒸熟',
            'ingredients': ['鲈鱼 1条', '料酒 2勺', '盐 少许', '姜丝 适量']
          },
          {
            'title': '蒸制调味',
            'description': '水开上锅蒸8分钟，倒掉蒸鱼水，淋蒸鱼豉油，最后浇热油。',
            'duration': 10,
            'tips': '蒸好后要倒掉鱼水，去除腥味',
            'ingredients': ['蒸鱼豉油 3勺', '葱丝 适量', '红椒丝 少许', '热油 适量']
          }
        ]
      },
      {
        'name': '蚂蚁上树',
        'description': '四川传统名菜，粉条爽滑，肉末香浓',
        'iconType': 'AppIcon3DType.noodle',
        'emojiIcon': '🍝', // 3D立体意面emoji
        'totalTime': 20,
        'difficulty': '简单',
        'servings': 2,
        'steps': [
          {
            'title': '粉条处理',
            'description': '红薯粉条100g用热水泡软，肉末100g用料酒腌制。',
            'duration': 10,
            'tips': '粉条不要泡太软，保持一定韧性',
            'ingredients': ['红薯粉条 100g', '猪肉末 100g', '料酒 1勺']
          },
          {
            'title': '炒制调味',
            'description': '炒香肉末，下粉条翻炒，加生抽老抽调色调味。',
            'duration': 10,
            'tips': '要用豆瓣酱炒出红油，增加川菜风味',
            'ingredients': ['豆瓣酱 1勺', '生抽 2勺', '老抽 半勺', '葱花 适量']
          }
        ]
      },
      {
        'name': '西红柿牛腩',
        'description': '酸甜开胃的炖菜，牛腩软烂，汤汁浓郁',
        'iconType': 'AppIcon3DType.pot',
        'emojiIcon': '🍅', // 3D立体番茄emoji
        'totalTime': 90,
        'difficulty': '中等',
        'servings': 4,
        'steps': [
          {
            'title': '牛腩处理',
            'description': '牛腩500g切块焯水去血沫，西红柿3个去皮切块。',
            'duration': 20,
            'tips': '牛腩要选择带筋的部位，口感更佳',
            'ingredients': ['牛腩 500g', '西红柿 3个', '姜片 适量', '料酒 2勺']
          },
          {
            'title': '炖煮入味',
            'description': '先炒西红柿出汁，下牛腩炒匀，加水炖煮60分钟至软烂。',
            'duration': 70,
            'tips': '小火慢炖，中途要检查水量',
            'ingredients': ['番茄酱 2勺', '生抽 适量', '盐 适量', '胡萝卜 1根']
          }
        ]
      }
    ];
  }
}
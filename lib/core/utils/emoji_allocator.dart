/// 🎨 用户菜谱智能emoji分配器
/// 
/// 功能：
/// - 根据菜谱名称智能分配emoji图标
/// - 为没有图片的用户菜谱提供视觉元素
/// - 支持中文菜名智能识别

import 'package:flutter/foundation.dart';

class EmojiAllocator {
  
  /// 🎯 根据菜谱名称智能分配emoji
  static String allocateEmoji(String recipeName) {
    final name = recipeName.toLowerCase().trim();
    
    // 🍲 汤类菜品
    if (_containsAny(name, ['汤', '羹', '煲', '炖', '汤水'])) {
      return '🥣';
    }
    
    // 🍜 面类菜品
    if (_containsAny(name, ['面', '粉', '河粉', '米粉', '拉面', '意面', '面条'])) {
      return '🍜';
    }
    
    // 🍖 肉类主菜
    if (_containsAny(name, ['排骨', '牛肉', '猪肉', '羊肉', '红烧', '炖肉', '肉丸'])) {
      return '🍖';
    }
    
    // 🍗 鸡肉类
    if (_containsAny(name, ['鸡', '鸡肉', '鸡翅', '鸡腿', '宫保', '口水鸡', '白切鸡'])) {
      return '🍗';
    }
    
    // 🐟 鱼类海鲜
    if (_containsAny(name, ['鱼', '鲈鱼', '带鱼', '鲫鱼', '鱼片', '蒸鱼', '虾', '蟹', '贝'])) {
      return '🐟';
    }
    
    // 🥚 蛋类菜品
    if (_containsAny(name, ['蛋', '鸡蛋', '鸭蛋', '蒸蛋', '煎蛋', '蛋羹', '鸡蛋羹'])) {
      return '🥚';
    }
    
    // 🫑 蔬菜类
    if (_containsAny(name, ['青椒', '辣椒', '茄子', '豆腐', '白菜', '菠菜', '韭菜'])) {
      return '🫑';
    }
    
    // 🍅 番茄类
    if (_containsAny(name, ['番茄', '西红柿', '茄汁'])) {
      return '🍅';
    }
    
    // 🌶️ 辣味菜品
    if (_containsAny(name, ['麻婆', '麻辣', '水煮', '辣子', '川菜', '湘菜'])) {
      return '🌶️';
    }
    
    // 🥞 早餐类
    if (_containsAny(name, ['早餐', '煎饼', '饼', '包子', '馒头', '粥', '爱心'])) {
      return '🥞';
    }
    
    // 🍚 米饭类
    if (_containsAny(name, ['饭', '炒饭', '盖饭', '丼', '米饭', '焖饭'])) {
      return '🍚';
    }
    
    // 🥘 炒菜类
    if (_containsAny(name, ['炒', '爆炒', '小炒', '家常'])) {
      return '🥘';
    }
    
    // 🍝 意面粉丝类
    if (_containsAny(name, ['蚂蚁上树', '粉丝', '意大利面', '通心粉'])) {
      return '🍝';
    }
    
    // 🧈 豆制品
    if (_containsAny(name, ['豆腐', '豆干', '腐竹', '豆皮'])) {
      return '🧈';
    }
    
    // 🥗 凉菜沙拉
    if (_containsAny(name, ['凉菜', '凉拌', '沙拉', '冷菜'])) {
      return '🥗';
    }
    
    // 🍰 甜品点心
    if (_containsAny(name, ['甜品', '蛋糕', '布丁', '果冻', '甜汤', '银耳'])) {
      return '🍰';
    }
    
    // 🥟 饺子包子类
    if (_containsAny(name, ['饺子', '包子', '馄饨', '汤圆', '元宵'])) {
      return '🥟';
    }
    
    // 🍲 火锅类
    if (_containsAny(name, ['火锅', '麻辣烫', '关东煮', '涮菜'])) {
      return '🍲';
    }
    
    // 🥩 烧烤类
    if (_containsAny(name, ['烧烤', '烤肉', '烤鱼', '烤鸡', '烤串'])) {
      return '🥩';
    }
    
    // 🍱 便当盒饭
    if (_containsAny(name, ['便当', '盒饭', '套餐', '定食'])) {
      return '🍱';
    }
    
    // 默认通用餐具
    return '🍽️';
  }
  
  /// 🔍 检查名称是否包含关键词
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
  
  /// 📋 获取所有可用的emoji列表
  static List<String> getAllAvailableEmojis() {
    return [
      '🥣', '🍜', '🍖', '🍗', '🐟', '🥚', '🫑', '🍅', 
      '🌶️', '🥞', '🍚', '🥘', '🍝', '🧈', '🥗', '🍰',
      '🥟', '🍲', '🥩', '🍱', '🍽️'
    ];
  }
  
  /// 🎨 为现有菜谱批量分配emoji
  static Map<String, String> batchAllocateEmojis(List<String> recipeNames) {
    final result = <String, String>{};
    for (final name in recipeNames) {
      result[name] = allocateEmoji(name);
    }
    return result;
  }
  
  /// 🔍 分析菜谱名称的分类统计
  static Map<String, List<String>> analyzeRecipeCategories(List<String> recipeNames) {
    final categories = <String, List<String>>{};
    
    for (final name in recipeNames) {
      final emoji = allocateEmoji(name);
      categories.putIfAbsent(emoji, () => []).add(name);
    }
    
    return categories;
  }
  
  /// 🥄 为菜谱步骤分配emoji图标
  /// 
  /// 根据步骤内容智能分配合适的emoji图标
  /// 优先级：步骤动作 > 食材类型 > 通用图标
  static String allocateStepEmoji(String stepTitle, String stepDescription, int stepIndex) {
    final title = stepTitle.toLowerCase().trim();
    final description = stepDescription.toLowerCase().trim();
    final content = '$title $description';
    
    // 🔥 加热烹饪类
    if (_containsAny(content, ['炒', '爆炒', '煸炒', '翻炒', '大火炒', '热锅'])) {
      return '🔥';
    }
    
    // 🔪 切配准备类
    if (_containsAny(content, ['切', '切片', '切块', '切丝', '切段', '刀工', '处理', '准备', '洗净'])) {
      return '🔪';
    }
    
    // 💧 清洗浸泡类
    if (_containsAny(content, ['洗', '清洗', '冲洗', '浸泡', '泡水', '过水', '焯水'])) {
      return '💧';
    }
    
    // 🥄 搅拌调味类
    if (_containsAny(content, ['搅拌', '拌匀', '调味', '加盐', '调料', '腌制', '搅', '拌'])) {
      return '🥄';
    }
    
    // 🍳 煎炸类
    if (_containsAny(content, ['煎', '炸', '油炸', '煎制', '煎至', '下锅煎', '小火煎'])) {
      return '🍳';
    }
    
    // ⏱️ 时间控制类
    if (_containsAny(content, ['分钟', '小时', '时间', '煮至', '炖煮', '焖煮', '慢炖', '等待'])) {
      return '⏱️';
    }
    
    // 🌡️ 温度控制类
    if (_containsAny(content, ['大火', '小火', '中火', '关火', '调火', '火候', '温度'])) {
      return '🌡️';
    }
    
    // 🥢 夹取装盘类
    if (_containsAny(content, ['装盘', '盛起', '起锅', '夹出', '捞出', '摆盘', '出锅'])) {
      return '🥢';
    }
    
    // 🧂 调料类
    if (_containsAny(content, ['盐', '糖', '醋', '酱油', '料酒', '胡椒', '味精', '鸡精', '香油', '芝麻油'])) {
      return '🧂';
    }
    
    // 🥩 肉类处理
    if (_containsAny(content, ['肉', '排骨', '牛肉', '猪肉', '鸡肉', '鱼肉', '虾'])) {
      return '🥩';
    }
    
    // 🥬 蔬菜处理
    if (_containsAny(content, ['蔬菜', '青菜', '白菜', '菠菜', '韭菜', '豆芽', '胡萝卜'])) {
      return '🥬';
    }
    
    // 🍅 番茄相关
    if (_containsAny(content, ['番茄', '西红柿', '茄汁', '酸甜'])) {
      return '🍅';
    }
    
    // 🥚 蛋类处理
    if (_containsAny(content, ['蛋', '鸡蛋', '蛋液', '打散', '蛋花'])) {
      return '🥚';
    }
    
    // 🫗 倒入添加类
    if (_containsAny(content, ['倒入', '加入', '放入', '下入', '投入', '添加'])) {
      return '🫗';
    }
    
    // ✨ 最终装饰
    if (_containsAny(content, ['撒上', '点缀', '装饰', '最后', '完成', '即可', '享用'])) {
      return '✨';
    }
    
    // 📦 储存保存
    if (_containsAny(content, ['保存', '储存', '冷藏', '放置', '静置', '晾凉'])) {
      return '📦';
    }
    
    // 🍽️ 上菜品尝
    if (_containsAny(content, ['上菜', '享用', '品尝', '开吃', '美味', '完成'])) {
      return '🍽️';
    }
    
    // 根据步骤顺序分配通用图标
    const stepEmojis = [
      '1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣', '🔟'
    ];
    
    if (stepIndex < stepEmojis.length) {
      return stepEmojis[stepIndex];
    }
    
    // 默认烹饪图标
    return '👨‍🍳';
  }
  
  /// 🔄 为菜谱的所有步骤批量分配emoji
  static List<String> allocateStepEmojis(List<Map<String, dynamic>> steps) {
    final result = <String>[];
    
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final title = step['title'] as String? ?? '';
      final description = step['description'] as String? ?? '';
      
      final emoji = allocateStepEmoji(title, description, i);
      result.add(emoji);
    }
    
    return result;
  }
  
  /// 📊 获取所有步骤emoji列表
  static List<String> getAllStepEmojis() {
    return [
      '🔥', '🔪', '💧', '🥄', '🍳', '⏱️', '🌡️', '🥢', '🧂', '🥩',
      '🥬', '🍅', '🥚', '🫗', '✨', '📦', '🍽️', '👨‍🍳',
      '1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣', '🔟'
    ];
  }

  /// 🧪 测试emoji分配器
  static void testEmojiAllocator() {
    debugPrint('🧪 测试emoji分配器...');
    
    final testNames = [
      '银耳莲子羹', '番茄鸡蛋面', '红烧排骨', '蒸蛋羹', '青椒肉丝',
      '爱心早餐', '糖醋排骨', '宫保鸡丁', '麻婆豆腐', '清蒸鲈鱼',
      '蚂蚁上树', '西红柿牛腩', '小炒黄牛肉', '酸辣土豆丝', '鱼香茄子'
    ];
    
    debugPrint('📊 分配结果：');
    for (final name in testNames) {
      final emoji = allocateEmoji(name);
      debugPrint('  $name -> $emoji');
    }
    
    final categories = analyzeRecipeCategories(testNames);
    debugPrint('📋 分类统计：');
    categories.forEach((emoji, names) {
      debugPrint('  $emoji: ${names.length}个 ${names.join(', ')}');
    });
    
    // 测试步骤emoji分配
    debugPrint('🥄 测试步骤emoji分配：');
    final testSteps = [
      {'title': '准备食材', 'description': '洗净蔬菜，切成小块'},
      {'title': '热锅下油', 'description': '大火加热炒锅，倒入食用油'},
      {'title': '炒制蔬菜', 'description': '下入蔬菜快速翻炒'},
      {'title': '调味出锅', 'description': '加盐调味，装盘即可享用'},
    ];
    
    for (int i = 0; i < testSteps.length; i++) {
      final step = testSteps[i];
      final emoji = allocateStepEmoji(step['title']!, step['description']!, i);
      debugPrint('  ${step['title']} -> $emoji');
    }
  }
}
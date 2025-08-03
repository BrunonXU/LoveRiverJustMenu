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
  }
}
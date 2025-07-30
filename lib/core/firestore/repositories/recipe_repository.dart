/// 🍳 Firestore 菜谱数据仓库
/// 
/// 处理菜谱数据的云端存储和同步
/// 支持个人菜谱和情侣共享菜谱
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/recipe/domain/models/recipe.dart';

/// 菜谱数据仓库
/// 
/// 管理菜谱数据的 CRUD 操作
/// 支持个人菜谱和情侣共享菜谱
class RecipeRepository {
  /// Firestore 实例
  final FirebaseFirestore _firestore;
  
  /// 菜谱集合引用
  late final CollectionReference<Map<String, dynamic>> _recipesCollection;
  
  /// 构造函数
  RecipeRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _recipesCollection = _firestore.collection('recipes');
  }

  /// 💾 保存菜谱到云端
  /// 
  /// [recipe] 要保存的菜谱
  /// [userId] 创建者用户ID
  /// 返回保存后的菜谱ID
  Future<String> saveRecipe(Recipe recipe, String userId) async {
    try {
      final recipeData = _recipeToMap(recipe, userId);
      
      DocumentReference docRef;
      if (recipe.id.isNotEmpty) {
        // 更新已有菜谱
        docRef = _recipesCollection.doc(recipe.id);
        await docRef.set(recipeData, SetOptions(merge: true));
      } else {
        // 创建新菜谱
        docRef = await _recipesCollection.add(recipeData);
      }
      
      debugPrint('✅ 菜谱已保存到云端: ${recipe.name} (${docRef.id})');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ 保存菜谱失败: $e');
      throw FirestoreException('保存菜谱失败', e.toString());
    }
  }

  /// 📖 获取用户的所有菜谱
  /// 
  /// [userId] 用户ID
  /// [includeShared] 是否包含共享菜谱
  /// 返回菜谱列表
  Future<List<Recipe>> getUserRecipes(String userId, {bool includeShared = true}) async {
    try {
      Query<Map<String, dynamic>> query = _recipesCollection;
      
      if (includeShared) {
        // 获取用户创建的菜谱和共享给用户的菜谱
        query = query.where(
          Filter.or(
            Filter('createdBy', isEqualTo: userId),
            Filter('sharedWith', arrayContains: userId),
          ),
        );
      } else {
        // 只获取用户创建的菜谱
        query = query.where('createdBy', isEqualTo: userId);
      }
      
      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      final recipes = querySnapshot.docs
          .map((doc) => _mapToRecipe(doc.data(), doc.id))
          .toList();
      
      debugPrint('✅ 已获取 ${recipes.length} 个菜谱');
      return recipes;
    } catch (e) {
      debugPrint('❌ 获取用户菜谱失败: $e');
      throw FirestoreException('获取菜谱失败', e.toString());
    }
  }

  /// 📖 根据ID获取菜谱
  /// 
  /// [recipeId] 菜谱ID
  /// 返回菜谱数据，如果不存在返回null
  Future<Recipe?> getRecipe(String recipeId) async {
    try {
      final doc = await _recipesCollection.doc(recipeId).get();
      
      if (!doc.exists) {
        debugPrint('ℹ️ 菜谱不存在: $recipeId');
        return null;
      }
      
      final recipeData = doc.data();
      if (recipeData == null) {
        debugPrint('⚠️ 菜谱数据为空: $recipeId');
        return null;
      }
      
      final recipe = _mapToRecipe(recipeData, recipeId);
      debugPrint('✅ 已获取菜谱: ${recipe.name}');
      return recipe;
    } catch (e) {
      debugPrint('❌ 获取菜谱失败: $e');
      throw FirestoreException('获取菜谱失败', e.toString());
    }
  }

  /// 📡 监听用户菜谱变化
  /// 
  /// [userId] 用户ID
  /// [includeShared] 是否包含共享菜谱
  /// 返回菜谱列表流
  Stream<List<Recipe>> watchUserRecipes(String userId, {bool includeShared = true}) {
    try {
      Query<Map<String, dynamic>> query = _recipesCollection;
      
      if (includeShared) {
        query = query.where(
          Filter.or(
            Filter('createdBy', isEqualTo: userId),
            Filter('sharedWith', arrayContains: userId),
          ),
        );
      } else {
        query = query.where('createdBy', isEqualTo: userId);
      }
      
      return query
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => _mapToRecipe(doc.data(), doc.id))
              .toList());
    } catch (e) {
      debugPrint('❌ 监听用户菜谱失败: $e');
      return Stream.error(FirestoreException('监听菜谱失败', e.toString()));
    }
  }

  /// 🔍 搜索菜谱
  /// 
  /// [keyword] 搜索关键词
  /// [userId] 用户ID（用于权限检查）
  /// 返回匹配的菜谱列表
  Future<List<Recipe>> searchRecipes(String keyword, String userId) async {
    try {
      // Firestore不支持复杂的全文搜索，这里使用简单的名称匹配
      // 在实际项目中可以考虑使用Algolia或Elasticsearch
      final query = await _recipesCollection
          .where(
            Filter.or(
              Filter('createdBy', isEqualTo: userId),
              Filter('sharedWith', arrayContains: userId),
            ),
          )
          .orderBy('name')
          .startAt([keyword])
          .endAt(['$keyword\uf8ff'])
          .get();
      
      final recipes = query.docs
          .map((doc) => _mapToRecipe(doc.data(), doc.id))
          .toList();
      
      debugPrint('✅ 搜索到 ${recipes.length} 个菜谱');
      return recipes;
    } catch (e) {
      debugPrint('❌ 搜索菜谱失败: $e');
      throw FirestoreException('搜索菜谱失败', e.toString());
    }
  }

  /// 💕 共享菜谱给伴侣
  /// 
  /// [recipeId] 菜谱ID
  /// [partnerId] 伴侣用户ID
  /// 返回操作是否成功
  Future<bool> shareRecipeWithPartner(String recipeId, String partnerId) async {
    try {
      await _recipesCollection.doc(recipeId).update({
        'sharedWith': FieldValue.arrayUnion([partnerId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ 菜谱已共享给伴侣: $recipeId -> $partnerId');
      return true;
    } catch (e) {
      debugPrint('❌ 共享菜谱失败: $e');
      throw FirestoreException('共享菜谱失败', e.toString());
    }
  }

  /// 📊 更新菜谱统计数据
  /// 
  /// [recipeId] 菜谱ID
  /// [action] 动作类型（view, cook, favorite等）
  Future<bool> updateRecipeStats(String recipeId, String action) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      switch (action) {
        case 'view':
          updateData['viewCount'] = FieldValue.increment(1);
          break;
        case 'cook':
          updateData['cookCount'] = FieldValue.increment(1);
          updateData['lastCookedAt'] = FieldValue.serverTimestamp();
          break;
        case 'favorite':
          updateData['favoriteCount'] = FieldValue.increment(1);
          break;
        case 'unfavorite':
          updateData['favoriteCount'] = FieldValue.increment(-1);
          break;
      }
      
      await _recipesCollection.doc(recipeId).update(updateData);
      
      debugPrint('✅ 菜谱统计已更新: $recipeId ($action)');
      return true;
    } catch (e) {
      debugPrint('❌ 更新菜谱统计失败: $e');
      throw FirestoreException('更新菜谱统计失败', e.toString());
    }
  }

  /// 🗑️ 删除菜谱
  /// 
  /// [recipeId] 菜谱ID
  /// [userId] 用户ID（用于权限检查）
  /// 返回操作是否成功
  Future<bool> deleteRecipe(String recipeId, String userId) async {
    try {
      // 先检查用户是否有删除权限
      final recipe = await getRecipe(recipeId);
      if (recipe == null) {
        debugPrint('ℹ️ 菜谱不存在，无需删除: $recipeId');
        return true;
      }
      
      // 只有创建者可以删除菜谱
      // 注意：这里需要从Firestore文档中获取createdBy字段
      final doc = await _recipesCollection.doc(recipeId).get();
      final createdBy = doc.data()?['createdBy'] as String?;
      
      if (createdBy != userId) {
        throw FirestoreException('删除菜谱失败', '只有创建者可以删除菜谱');
      }
      
      await _recipesCollection.doc(recipeId).delete();
      
      debugPrint('✅ 菜谱已删除: $recipeId');
      return true;
    } catch (e) {
      debugPrint('❌ 删除菜谱失败: $e');
      throw FirestoreException('删除菜谱失败', e.toString());
    }
  }

  /// 🔥 获取热门菜谱
  /// 
  /// [limit] 获取数量限制
  /// 返回热门菜谱列表
  Future<List<Recipe>> getPopularRecipes({int limit = 20}) async {
    try {
      final query = await _recipesCollection
          .where('isPublic', isEqualTo: true) // 只获取公开菜谱
          .orderBy('cookCount', descending: true)
          .limit(limit)
          .get();
      
      final recipes = query.docs
          .map((doc) => _mapToRecipe(doc.data(), doc.id))
          .toList();
      
      debugPrint('✅ 已获取 ${recipes.length} 个热门菜谱');
      return recipes;
    } catch (e) {
      debugPrint('❌ 获取热门菜谱失败: $e');
      throw FirestoreException('获取热门菜谱失败', e.toString());
    }
  }

  // ==================== 私有辅助方法 ====================

  /// 菜谱对象转换为Map
  Map<String, dynamic> _recipeToMap(Recipe recipe, String userId) {
    return {
      'name': recipe.name,
      'description': recipe.description,
      'coverImageBase64': recipe.coverImageBase64,
      'difficulty': recipe.difficulty,
      'servings': recipe.servings,
      'cookTime': recipe.cookTime,
      'preparationTime': recipe.preparationTime,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps.map((step) => {
        'description': step.description,
        'imageBase64': step.imageBase64,
        'duration': step.duration,
        'temperature': step.temperature,
        'tips': step.tips,
      }).toList(),
      'tags': recipe.tags,
      'nutritionInfo': recipe.nutritionInfo,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'sharedWith': <String>[], // 初始为空，后续可以添加共享用户
      'isPublic': false, // 默认私有
      'viewCount': 0,
      'cookCount': 0,
      'favoriteCount': 0,
    };
  }

  /// Map转换为菜谱对象
  Recipe _mapToRecipe(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      coverImageBase64: data['coverImageBase64'] as String? ?? '',
      difficulty: data['difficulty'] as String? ?? '简单',
      servings: data['servings'] as int? ?? 2,
      cookTime: data['cookTime'] as int? ?? 30,
      preparationTime: data['preparationTime'] as int? ?? 15,
      ingredients: List<String>.from(data['ingredients'] as List? ?? []),
      steps: (data['steps'] as List? ?? []).map((stepData) {
        final step = stepData as Map<String, dynamic>;
        return RecipeStep(
          description: step['description'] as String,
          imageBase64: step['imageBase64'] as String? ?? '',
          duration: step['duration'] as int? ?? 0,
          temperature: step['temperature'] as String? ?? '',
          tips: step['tips'] as String? ?? '',
        );
      }).toList(),
      tags: List<String>.from(data['tags'] as List? ?? []),
      nutritionInfo: data['nutritionInfo'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

/// Firestore 异常类
class FirestoreException implements Exception {
  final String message;
  final String details;
  
  const FirestoreException(this.message, this.details);
  
  @override
  String toString() => 'FirestoreException: $message ($details)';
}
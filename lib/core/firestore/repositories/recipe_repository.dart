/// 🍳 Firestore 菜谱数据仓库
/// 
/// 处理菜谱数据的云端存储和同步
/// 支持个人菜谱和情侣共享菜谱
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/recipe/domain/models/recipe.dart';
import '../../storage/services/storage_service.dart';
import '../../utils/emoji_allocator.dart';

/// 菜谱数据仓库
/// 
/// 管理菜谱数据的 CRUD 操作
/// 支持个人菜谱和情侣共享菜谱
class RecipeRepository {
  /// Firestore 实例
  final FirebaseFirestore _firestore;
  
  /// Storage 服务
  final StorageService _storageService;
  
  /// 菜谱集合引用
  late final CollectionReference<Map<String, dynamic>> _recipesCollection;
  
  /// 构造函数
  RecipeRepository({
    FirebaseFirestore? firestore,
    StorageService? storageService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storageService = storageService ?? StorageService() {
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
      
      // 🆕 保存所有图片到子集合（封面 + 步骤）
      await _saveAllImages(docRef.id, recipe);
      
      debugPrint('✅ 菜谱已保存到云端: ${recipe.name} (${docRef.id})');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ 保存菜谱失败: $e');
      throw FirestoreException('保存菜谱失败', e.toString());
    }
  }

  /// 💾 保存所有图片到子集合（封面 + 步骤）
  /// 
  /// [recipeId] 菜谱ID
  /// [recipe] 菜谱对象
  Future<void> _saveAllImages(String recipeId, Recipe recipe) async {
    try {
      final imagesCollection = _recipesCollection.doc(recipeId).collection('images');
      
      // 清理现有的图片（如果是更新操作）
      final existingDocs = await imagesCollection.get();
      for (final doc in existingDocs.docs) {
        await doc.reference.delete();
      }
      
      // 保存封面图片
      if (recipe.imageBase64 != null && recipe.imageBase64!.isNotEmpty) {
        await imagesCollection.doc('cover').set({
          'type': 'cover',
          'imageBase64': recipe.imageBase64,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ 已保存封面图片到子集合');
      }
      
      // 保存步骤图片
      final steps = recipe.steps;
      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        if (step.imageBase64 != null && step.imageBase64!.isNotEmpty) {
          await imagesCollection.doc('step_$i').set({
            'type': 'step',
            'stepIndex': i,
            'imageBase64': step.imageBase64,
            'title': step.title,
            'createdAt': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ 已保存步骤 $i 的图片到子集合');
        }
      }
    } catch (e) {
      debugPrint('⚠️ 保存图片失败: $e');
      // 图片保存失败不影响主菜谱保存
    }
  }

  /// 📖 加载所有图片从子集合
  /// 
  /// [recipeId] 菜谱ID
  /// 返回包含封面图片和步骤图片的数据
  Future<({String? coverImage, Map<int, String> stepImages})> _loadAllImages(String recipeId) async {
    try {
      final imagesCollection = _recipesCollection.doc(recipeId).collection('images');
      final querySnapshot = await imagesCollection.get();
      
      String? coverImage;
      final stepImages = <int, String>{};
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String;
        
        if (type == 'cover') {
          coverImage = data['imageBase64'] as String?;
        } else if (type == 'step') {
          final stepIndex = data['stepIndex'] as int;
          final imageBase64 = data['imageBase64'] as String?;
          if (imageBase64 != null) {
            stepImages[stepIndex] = imageBase64;
          }
        }
      }
      
      debugPrint('✅ 已加载封面图片和 ${stepImages.length} 个步骤图片');
      return (coverImage: coverImage, stepImages: stepImages);
    } catch (e) {
      debugPrint('⚠️ 加载图片失败: $e');
      return (coverImage: null, stepImages: <int, String>{});
    }
  }

  /// 📖 获取用户的所有菜谱
  /// 
  /// [userId] 用户ID
  /// [includeShared] 是否包含共享菜谱
  /// 返回菜谱列表
  Future<List<Recipe>> getUserRecipes(String userId, {bool includeShared = false}) async {
    try {
      // 🚀 性能优化：移除排序避免索引要求
      final querySnapshot = await _recipesCollection
          .where('createdBy', isEqualTo: userId)
          .get();
      
      // 在客户端进行排序
      final docs = querySnapshot.docs.toList();
      docs.sort((a, b) {
        final aTime = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime); // 降序排序
      });
      
      final recipes = docs
          .map((doc) => _mapToRecipe(doc.data(), doc.id))
          .toList();
      
      debugPrint('✅ 已获取 ${recipes.length} 个用户菜谱');
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
      
      // 🆕 加载所有图片（封面 + 步骤）
      final images = await _loadAllImages(recipeId);
      
      final recipe = _mapToRecipe(recipeData, recipeId, images.coverImage, images.stepImages);
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
  Stream<List<Recipe>> watchUserRecipes(String userId, {bool includeShared = false}) {
    try {
      // 🚀 性能优化：移除排序避免索引要求
      return _recipesCollection
          .where('createdBy', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            // 在客户端进行排序
            final docs = snapshot.docs.toList();
            docs.sort((a, b) {
              final aTime = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final bTime = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              return bTime.compareTo(aTime); // 降序排序
            });
            
            return docs
                .map((doc) => _mapToRecipe(doc.data(), doc.id))
                .toList();
          });
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

  /// 🍳 获取公共预设菜谱
  /// 
  /// 返回所有用户共享的预设菜谱
  Future<List<Recipe>> getPresetRecipes() async {
    try {
      debugPrint('🔍 开始查询公共预设菜谱...');
      
      final querySnapshot = await _recipesCollection
          .where('isPreset', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .get();
      
      final recipes = querySnapshot.docs
          .map((doc) => _mapToRecipe(doc.data(), doc.id))
          .toList();
      
      // 按创建时间排序
      recipes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      debugPrint('✅ 成功获取 ${recipes.length} 个公共预设菜谱');
      return recipes;
    } catch (e) {
      debugPrint('❌ 获取公共预设菜谱失败: $e');
      throw FirestoreException('获取预设菜谱失败', e.toString());
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

  /// 🚨 紧急清理所有菜谱数据中的base64
  /// 
  /// 直接删除所有base64数据，解决Firebase控制台卡死
  /// 返回清理的文档数量
  Future<int> emergencyCleanupAllBase64() async {
    try {
      debugPrint('🚨 紧急清理模式：清理所有菜谱中的base64数据...');
      
      // 获取所有菜谱（不加任何条件）
      final querySnapshot = await _recipesCollection.get();
      
      int cleanedCount = 0;
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final updates = <String, dynamic>{};
        bool needsUpdate = false;
        
        // 无条件删除所有base64数据
        if (data.containsKey('imageBase64')) {
          updates['imageBase64'] = FieldValue.delete();
          needsUpdate = true;
        }
        
        // 清理步骤中的所有图片
        final steps = data['steps'] as List?;
        if (steps != null && steps.isNotEmpty) {
          final cleanedSteps = steps.map((step) {
            if (step is Map<String, dynamic>) {
              final cleanedStep = Map<String, dynamic>.from(step);
              cleanedStep.remove('imageBase64');
              return cleanedStep;
            }
            return step;
          }).toList();
          
          updates['steps'] = cleanedSteps;
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          await doc.reference.update(updates);
          cleanedCount++;
          debugPrint('🚨 紧急清理文档: ${doc.id}');
        }
      }
      
      debugPrint('✅ 紧急清理完成！共清理了 $cleanedCount 个文档');
      return cleanedCount;
    } catch (e) {
      debugPrint('❌ 紧急清理失败: $e');
      throw FirestoreException('紧急清理失败', e.toString());
    }
  }
  
  /// 🧹 清理用户菜谱中的所有base64图片数据
  /// 
  /// 解决Firebase控制台因文档过大而卡死的问题
  /// [userId] 用户ID
  /// 返回清理的文档数量
  Future<int> cleanupAllImagesBase64(String userId) async {
    try {
      debugPrint('🧹 开始清理用户菜谱中的所有base64图片数据...');
      
      final querySnapshot = await _recipesCollection
          .where('createdBy', isEqualTo: userId)
          .get();
      
      int cleanedCount = 0;
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        bool needsUpdate = false;
        final updates = <String, dynamic>{};
        
        // 检查并清理封面图片base64
        if (data.containsKey('imageBase64') && data['imageBase64'] != null) {
          updates['imageBase64'] = FieldValue.delete();
          needsUpdate = true;
          debugPrint('🧹 清理封面图片base64');
        }
        
        // 检查并清理步骤图片base64
        final steps = data['steps'] as List?;
        if (steps != null && steps.isNotEmpty) {
          bool hasStepImages = steps.any((step) => 
            step is Map<String, dynamic> && 
            step.containsKey('imageBase64') && 
            step['imageBase64'] != null
          );
          
          if (hasStepImages) {
            final cleanedSteps = steps.map((step) {
              if (step is Map<String, dynamic>) {
                final cleanedStep = Map<String, dynamic>.from(step);
                cleanedStep.remove('imageBase64');
                return cleanedStep;
              }
              return step;
            }).toList();
            
            updates['steps'] = cleanedSteps;
            needsUpdate = true;
            debugPrint('🧹 清理步骤图片base64');
          }
        }
        
        // 如果需要更新，执行更新
        if (needsUpdate) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          await doc.reference.update(updates);
          cleanedCount++;
          debugPrint('✅ 已清理文档: ${doc.id}');
        }
      }
      
      debugPrint('🎉 清理完成！共清理了 $cleanedCount 个文档');
      return cleanedCount;
    } catch (e) {
      debugPrint('❌ 清理失败: $e');
      throw FirestoreException('清理步骤图片数据失败', e.toString());
    }
  }

  // ==================== 私有辅助方法 ====================

  /// 菜谱对象转换为Map
  Map<String, dynamic> _recipeToMap(Recipe recipe, String userId) {
    // 🎨 智能emoji分配：如果用户菜谱没有图片且没有emoji，自动分配
    String? finalEmojiIcon = recipe.emojiIcon;
    if (!recipe.isPreset && // 只为用户菜谱分配
        (recipe.imageUrl == null || recipe.imageUrl!.isEmpty) && // 没有图片
        (recipe.emojiIcon == null || recipe.emojiIcon!.isEmpty)) { // 没有emoji
      finalEmojiIcon = EmojiAllocator.allocateEmoji(recipe.name);
      debugPrint('🎨 为用户菜谱自动分配emoji: ${recipe.name} -> $finalEmojiIcon');
    }
    
    return {
      'name': recipe.name,
      'description': recipe.description,
      'iconType': recipe.iconType,
      'imageUrl': recipe.imageUrl, // ✅ Storage URL（推荐）
      // 🚫 不再存储base64图片到主文档，避免Firebase控制台卡死
      'totalTime': recipe.totalTime,
      'difficulty': recipe.difficulty,
      'servings': recipe.servings,
      'steps': recipe.steps.map((step) => {
        'title': step.title,
        'description': step.description,
        'duration': step.duration,
        'tips': step.tips,
        // 🚫 重要：不存储步骤图片base64数据，避免文档过大导致Firebase控制台卡死
        // 'imageBase64': step.imageBase64, // 临时禁用，避免文档过大
        'ingredients': step.ingredients,
      }).toList(),
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'sharedWith': recipe.sharedWith,
      'isPublic': recipe.isPublic,
      'rating': recipe.rating,
      'cookCount': recipe.cookCount,
      'viewCount': 0,
      'favoriteCount': recipe.favoriteCount,
      // 🔧 修复：添加预设菜谱相关字段
      'isPreset': recipe.isPreset,
      'sourceType': recipe.sourceType,
      'isShared': recipe.isShared,
      'originalRecipeId': recipe.originalRecipeId,
      'emojiIcon': finalEmojiIcon, // 🎨 智能分配的emoji图标
    };
  }

  /// Map转换为菜谱对象
  Recipe _mapToRecipe(Map<String, dynamic> data, String id, [String? coverImage, Map<int, String>? stepImages]) {
    return Recipe(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      iconType: data['iconType'] as String? ?? 'food',
      totalTime: data['totalTime'] as int? ?? 30,
      difficulty: data['difficulty'] as String? ?? '简单',
      servings: data['servings'] as int? ?? 2,
      imageUrl: data['imageUrl'] as String?, // ✅ 从Storage URL读取
      imageBase64: coverImage ?? data['imageBase64'] as String?, // 🆕 优先使用子集合中的封面图片
      steps: (data['steps'] as List? ?? []).asMap().entries.map((entry) {
        final index = entry.key;
        final stepData = entry.value as Map<String, dynamic>;
        return RecipeStep(
          title: stepData['title'] as String? ?? '',
          description: stepData['description'] as String,
          duration: stepData['duration'] as int? ?? 0,
          tips: stepData['tips'] as String?,
          // 🆕 优先使用子集合中的图片，fallback到原来的数据
          imageBase64: stepImages?[index] ?? stepData['imageBase64'] as String?,
          ingredients: List<String>.from(stepData['ingredients'] as List? ?? []),
        );
      }).toList(),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isPublic: data['isPublic'] as bool? ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      cookCount: data['cookCount'] as int? ?? 0,
      // 🔧 修复：添加预设菜谱相关字段
      sharedWith: List<String>.from(data['sharedWith'] as List? ?? []),
      isShared: data['isShared'] as bool? ?? false,
      originalRecipeId: data['originalRecipeId'] as String?,
      sourceType: data['sourceType'] as String? ?? 'user',
      isPreset: data['isPreset'] as bool? ?? false,
      favoriteCount: data['favoriteCount'] as int? ?? 0,
      emojiIcon: data['emojiIcon'] as String?, // 🔧 新增：从Firestore读取emoji图标
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

// ==================== Riverpod Providers ====================

/// 🚀 云端菜谱仓库 Provider
final cloudRecipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});

/// 🚀 异步初始化的云端菜谱仓库 Provider  
final initializedCloudRecipeRepositoryProvider = FutureProvider<RecipeRepository>((ref) async {
  final repository = RecipeRepository();
  // Cloud Firestore 不需要额外初始化
  return repository;
});
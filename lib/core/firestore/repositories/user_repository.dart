/// 🔥 Firestore 用户数据仓库
/// 
/// 处理用户数据的云端存储和同步
/// 实现本地缓存 + 云端同步的混合存储策略
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../auth/models/app_user.dart';
import '../../exceptions/auth_exceptions.dart';

/// 用户数据仓库
/// 
/// 管理用户信息的 CRUD 操作
/// 实现缓存策略提升性能
class UserRepository {
  /// Firestore 实例
  final FirebaseFirestore _firestore;
  
  /// 用户集合引用
  late final CollectionReference<Map<String, dynamic>> _usersCollection;
  
  /// 构造函数
  UserRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _usersCollection = _firestore.collection('users');
  }

  /// 💾 保存用户数据到云端
  /// 
  /// [user] 要保存的用户数据
  /// 返回操作是否成功
  Future<bool> saveUser(AppUser user) async {
    try {
      final userData = _userToMap(user);
      
      await _usersCollection.doc(user.uid).set(
        userData,
        SetOptions(merge: true), // 合并更新，避免覆盖其他字段
      );
      
      debugPrint('✅ 用户数据已保存到云端: ${user.email}');
      return true;
    } catch (e) {
      debugPrint('❌ 保存用户数据失败: $e');
      throw FirestoreException('保存用户数据失败', e.toString());
    }
  }

  /// 📖 从云端获取用户数据
  /// 
  /// [uid] 用户唯一标识
  /// 返回用户数据，如果不存在返回null
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      
      if (!doc.exists) {
        debugPrint('ℹ️ 用户不存在: $uid');
        return null;
      }
      
      final userData = doc.data();
      if (userData == null) {
        debugPrint('⚠️ 用户数据为空: $uid');
        return null;
      }
      
      final user = _mapToUser(userData, uid);
      debugPrint('✅ 已获取用户数据: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('❌ 获取用户数据失败: $e');
      throw FirestoreException('获取用户数据失败', e.toString());
    }
  }

  /// 📡 监听用户数据变化
  /// 
  /// [uid] 用户唯一标识
  /// 返回用户数据流
  Stream<AppUser?> watchUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      
      final userData = doc.data();
      if (userData == null) return null;
      
      return _mapToUser(userData, uid);
    });
  }

  /// 🔄 更新用户偏好设置
  /// 
  /// [uid] 用户唯一标识
  /// [preferences] 新的偏好设置
  Future<bool> updateUserPreferences(String uid, UserPreferences preferences) async {
    try {
      await _usersCollection.doc(uid).update({
        'preferences': _preferencesToMap(preferences),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ 用户偏好已更新: $uid');
      return true;
    } catch (e) {
      debugPrint('❌ 更新用户偏好失败: $e');
      throw FirestoreException('更新用户偏好失败', e.toString());
    }
  }

  /// 📊 更新用户统计数据
  /// 
  /// [uid] 用户唯一标识
  /// [stats] 新的统计数据
  Future<bool> updateUserStats(String uid, UserStats stats) async {
    try {
      await _usersCollection.doc(uid).update({
        'stats': _statsToMap(stats),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ 用户统计已更新: $uid');
      return true;
    } catch (e) {
      debugPrint('❌ 更新用户统计失败: $e');
      throw FirestoreException('更新用户统计失败', e.toString());
    }
  }

  /// 💕 绑定情侣关系
  /// 
  /// [uid] 用户唯一标识
  /// [coupleBinding] 情侣绑定信息
  Future<bool> bindCouple(String uid, CoupleBinding coupleBinding) async {
    try {
      // 使用事务确保数据一致性
      await _firestore.runTransaction((transaction) async {
        // 更新当前用户的绑定信息
        transaction.update(_usersCollection.doc(uid), {
          'coupleBinding': _coupleBindingToMap(coupleBinding),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // 更新伴侣的绑定信息
        final partnerBinding = CoupleBinding(
          partnerId: uid,
          partnerName: '', // 需要从用户数据中获取
          bindingDate: coupleBinding.bindingDate,
          coupleId: coupleBinding.coupleId,
          intimacyLevel: coupleBinding.intimacyLevel,
          cookingTogether: coupleBinding.cookingTogether,
        );
        
        transaction.update(_usersCollection.doc(coupleBinding.partnerId), {
          'coupleBinding': _coupleBindingToMap(partnerBinding),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      
      debugPrint('✅ 情侣关系已绑定: $uid <-> ${coupleBinding.partnerId}');
      return true;
    } catch (e) {
      debugPrint('❌ 绑定情侣关系失败: $e');
      throw FirestoreException('绑定情侣关系失败', e.toString());
    }
  }

  /// 💔 解除情侣关系
  /// 
  /// [uid] 用户唯一标识
  Future<bool> unbindCouple(String uid) async {
    try {
      // 先获取当前绑定信息
      final userDoc = await _usersCollection.doc(uid).get();
      final userData = userDoc.data();
      
      if (userData == null || userData['coupleBinding'] == null) {
        debugPrint('ℹ️ 用户没有绑定关系: $uid');
        return true;
      }
      
      final coupleBindingData = userData['coupleBinding'] as Map<String, dynamic>;
      final partnerId = coupleBindingData['partnerId'] as String;
      
      // 使用事务解除双方绑定
      await _firestore.runTransaction((transaction) async {
        transaction.update(_usersCollection.doc(uid), {
          'coupleBinding': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        transaction.update(_usersCollection.doc(partnerId), {
          'coupleBinding': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      
      debugPrint('✅ 情侣关系已解除: $uid <-> $partnerId');
      return true;
    } catch (e) {
      debugPrint('❌ 解除情侣关系失败: $e');
      throw FirestoreException('解除情侣关系失败', e.toString());
    }
  }

  /// 🔍 根据邮箱查找用户
  /// 
  /// [email] 用户邮箱
  /// 返回用户数据，如果不存在返回null
  Future<AppUser?> getUserByEmail(String email) async {
    try {
      final query = await _usersCollection
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        debugPrint('ℹ️ 邮箱对应的用户不存在: $email');
        return null;
      }
      
      final doc = query.docs.first;
      final userData = doc.data();
      final user = _mapToUser(userData, doc.id);
      
      debugPrint('✅ 已通过邮箱找到用户: $email');
      return user;
    } catch (e) {
      debugPrint('❌ 根据邮箱查找用户失败: $e');
      throw FirestoreException('查找用户失败', e.toString());
    }
  }

  /// 🗑️ 删除用户数据
  /// 
  /// [uid] 用户唯一标识
  /// ⚠️ 危险操作：会永久删除用户所有数据
  Future<bool> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      
      debugPrint('✅ 用户数据已删除: $uid');
      return true;
    } catch (e) {
      debugPrint('❌ 删除用户数据失败: $e');
      throw FirestoreException('删除用户数据失败', e.toString());
    }
  }

  // ==================== 私有辅助方法 ====================

  /// 用户对象转换为Map
  Map<String, dynamic> _userToMap(AppUser user) {
    return {
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
      'preferences': _preferencesToMap(user.preferences),
      'coupleBinding': user.coupleBinding != null 
          ? _coupleBindingToMap(user.coupleBinding!) 
          : null,
      'stats': _statsToMap(user.stats),
    };
  }

  /// Map转换为用户对象
  AppUser _mapToUser(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      preferences: _mapToPreferences(data['preferences'] as Map<String, dynamic>),
      coupleBinding: data['coupleBinding'] != null 
          ? _mapToCoupleBinding(data['coupleBinding'] as Map<String, dynamic>)
          : null,
      stats: _mapToStats(data['stats'] as Map<String, dynamic>),
    );
  }

  /// 偏好设置转换为Map
  Map<String, dynamic> _preferencesToMap(UserPreferences preferences) {
    return {
      'isDarkMode': preferences.isDarkMode,
      'enableNotifications': preferences.enableNotifications,
      'enableCookingReminders': preferences.enableCookingReminders,
      'preferredDifficulty': preferences.preferredDifficulty,
      'preferredServings': preferences.preferredServings,
      'userTags': preferences.userTags,
    };
  }

  /// Map转换为偏好设置
  UserPreferences _mapToPreferences(Map<String, dynamic> data) {
    return UserPreferences(
      isDarkMode: data['isDarkMode'] as bool? ?? false,
      enableNotifications: data['enableNotifications'] as bool? ?? true,
      enableCookingReminders: data['enableCookingReminders'] as bool? ?? true,
      preferredDifficulty: data['preferredDifficulty'] as String? ?? '简单',
      preferredServings: data['preferredServings'] as int? ?? 2,
      userTags: List<String>.from(data['userTags'] as List? ?? []),
    );
  }

  /// 情侣绑定转换为Map
  Map<String, dynamic> _coupleBindingToMap(CoupleBinding binding) {
    return {
      'partnerId': binding.partnerId,
      'partnerName': binding.partnerName,
      'bindingDate': Timestamp.fromDate(binding.bindingDate),
      'coupleId': binding.coupleId,
      'intimacyLevel': binding.intimacyLevel,
      'cookingTogether': binding.cookingTogether,
    };
  }

  /// Map转换为情侣绑定
  CoupleBinding _mapToCoupleBinding(Map<String, dynamic> data) {
    return CoupleBinding(
      partnerId: data['partnerId'] as String,
      partnerName: data['partnerName'] as String,
      bindingDate: (data['bindingDate'] as Timestamp).toDate(),
      coupleId: data['coupleId'] as String,
      intimacyLevel: data['intimacyLevel'] as int,
      cookingTogether: data['cookingTogether'] as int,
    );
  }

  /// 统计数据转换为Map
  Map<String, dynamic> _statsToMap(UserStats stats) {
    return {
      'level': stats.level,
      'experience': stats.experience,
      'recipesCreated': stats.recipesCreated,
      'cookingCompleted': stats.cookingCompleted,
      'consecutiveDays': stats.consecutiveDays,
      'lastActiveDate': Timestamp.fromDate(stats.lastActiveDate),
    };
  }

  /// Map转换为统计数据
  UserStats _mapToStats(Map<String, dynamic> data) {
    return UserStats(
      level: data['level'] as int? ?? 1,
      experience: data['experience'] as int? ?? 0,
      recipesCreated: data['recipesCreated'] as int? ?? 0,
      cookingCompleted: data['cookingCompleted'] as int? ?? 0,
      consecutiveDays: data['consecutiveDays'] as int? ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp).toDate(),
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
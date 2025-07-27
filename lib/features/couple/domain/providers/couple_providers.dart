import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/couple_account.dart';

/// 情侣账号状态通知器
class CoupleAccountNotifier extends StateNotifier<CoupleAccountState> {
  CoupleAccountNotifier() : super(const CoupleAccountState.initial());

  /// 创建情侣账号
  Future<void> createCoupleAccount({
    required String creatorId,
    required String coupleName,
    required DateTime relationshipStartDate,
    String? avatarUrl,
  }) async {
    state = const CoupleAccountState.loading();
    
    try {
      // 生成唯一ID和邀请码
      final coupleId = 'couple_${DateTime.now().millisecondsSinceEpoch}';
      final inviteCode = _generateInviteCode();
      
      final now = DateTime.now();
      final coupleAccount = CoupleAccount(
        coupleId: coupleId,
        creatorId: creatorId,
        coupleName: coupleName,
        relationshipStartDate: relationshipStartDate,
        avatarUrl: avatarUrl,
        status: CoupleStatus.pending,
        createdAt: now,
        updatedAt: now,
        inviteCode: inviteCode,
      );
      
      // TODO: 保存到本地存储或远程服务器
      await _saveCoupleAccount(coupleAccount);
      
      state = CoupleAccountState.success(coupleAccount);
    } catch (e) {
      state = CoupleAccountState.error('创建情侣账号失败: $e');
    }
  }

  /// 通过邀请码加入情侣账号
  Future<void> joinCoupleAccount({
    required String inviteCode,
    required String partnerId,
    required CoupleProfile partnerProfile,
  }) async {
    state = const CoupleAccountState.loading();
    
    try {
      // TODO: 根据邀请码查找情侣账号
      final coupleAccount = await _findCoupleAccountByInviteCode(inviteCode);
      
      if (coupleAccount == null) {
        state = const CoupleAccountState.error('邀请码无效或已过期');
        return;
      }
      
      if (coupleAccount.partnerId != null) {
        state = const CoupleAccountState.error('该情侣账号已满员');
        return;
      }
      
      // 更新情侣账号，添加伴侣信息
      final updatedAccount = coupleAccount.copyWith(
        partnerId: partnerId,
        partnerProfile: partnerProfile,
        status: CoupleStatus.active,
        updatedAt: DateTime.now(),
        inviteCode: null, // 清除邀请码
      );
      
      await _saveCoupleAccount(updatedAccount);
      
      state = CoupleAccountState.success(updatedAccount);
    } catch (e) {
      state = CoupleAccountState.error('加入情侣账号失败: $e');
    }
  }

  /// 更新个人资料
  Future<void> updateProfile({
    required String userId,
    required CoupleProfile profile,
  }) async {
    final currentState = state;
    if (currentState is! CoupleAccountSuccess) return;
    
    final coupleAccount = currentState.account;
    CoupleAccount updatedAccount;
    
    if (coupleAccount.isCreator(userId)) {
      updatedAccount = coupleAccount.copyWith(
        myProfile: profile,
        updatedAt: DateTime.now(),
      );
    } else if (coupleAccount.isPartner(userId)) {
      updatedAccount = coupleAccount.copyWith(
        partnerProfile: profile,
        updatedAt: DateTime.now(),
      );
    } else {
      state = const CoupleAccountState.error('无权限更新资料');
      return;
    }
    
    try {
      await _saveCoupleAccount(updatedAccount);
      state = CoupleAccountState.success(updatedAccount);
    } catch (e) {
      state = CoupleAccountState.error('更新资料失败: $e');
    }
  }

  /// 解除绑定
  Future<void> unbindCouple(String userId) async {
    final currentState = state;
    if (currentState is! CoupleAccountSuccess) return;
    
    final coupleAccount = currentState.account;
    
    try {
      final updatedAccount = coupleAccount.copyWith(
        status: CoupleStatus.unbound,
        updatedAt: DateTime.now(),
      );
      
      await _saveCoupleAccount(updatedAccount);
      state = const CoupleAccountState.initial();
    } catch (e) {
      state = CoupleAccountState.error('解除绑定失败: $e');
    }
  }

  /// 加载现有的情侣账号
  Future<void> loadCoupleAccount(String userId) async {
    state = const CoupleAccountState.loading();
    
    try {
      final coupleAccount = await _loadCoupleAccountForUser(userId);
      
      if (coupleAccount != null) {
        state = CoupleAccountState.success(coupleAccount);
      } else {
        state = const CoupleAccountState.initial();
      }
    } catch (e) {
      state = CoupleAccountState.error('加载情侣账号失败: $e');
    }
  }

  // ==================== 私有方法 ====================

  /// 生成6位邀请码
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    
    return code;
  }

  /// 保存情侣账号（模拟）
  Future<void> _saveCoupleAccount(CoupleAccount account) async {
    // TODO: 实现本地存储或远程API调用
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 模拟保存到SharedPreferences或Hive
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('couple_account', jsonEncode(account.toJson()));
  }

  /// 根据邀请码查找情侣账号（模拟）
  Future<CoupleAccount?> _findCoupleAccountByInviteCode(String inviteCode) async {
    // TODO: 实现查找逻辑
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 模拟查找结果
    if (inviteCode.length != 6) return null;
    
    // 返回模拟的情侣账号
    return CoupleAccount(
      coupleId: 'couple_demo',
      creatorId: 'creator_demo',
      coupleName: '我们的美食时光',
      relationshipStartDate: DateTime.now().subtract(const Duration(days: 365)),
      status: CoupleStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      inviteCode: inviteCode,
    );
  }

  /// 为用户加载情侣账号（模拟）
  Future<CoupleAccount?> _loadCoupleAccountForUser(String userId) async {
    // TODO: 实现加载逻辑
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 从本地存储或远程服务器加载
    // final prefs = await SharedPreferences.getInstance();
    // final accountJson = prefs.getString('couple_account');
    // if (accountJson != null) {
    //   return CoupleAccount.fromJson(jsonDecode(accountJson));
    // }
    
    return null;
  }
}

/// 情侣账号状态
sealed class CoupleAccountState {
  const CoupleAccountState();
  
  const factory CoupleAccountState.initial() = CoupleAccountInitial;
  const factory CoupleAccountState.loading() = CoupleAccountLoading;
  const factory CoupleAccountState.success(CoupleAccount account) = CoupleAccountSuccess;
  const factory CoupleAccountState.error(String message) = CoupleAccountError;
}

class CoupleAccountInitial extends CoupleAccountState {
  const CoupleAccountInitial();
}

class CoupleAccountLoading extends CoupleAccountState {
  const CoupleAccountLoading();
}

class CoupleAccountSuccess extends CoupleAccountState {
  final CoupleAccount account;
  
  const CoupleAccountSuccess(this.account);
}

class CoupleAccountError extends CoupleAccountState {
  final String message;
  
  const CoupleAccountError(this.message);
}

// ==================== Provider 定义 ====================

/// 情侣账号状态提供者
final coupleAccountProvider = StateNotifierProvider<CoupleAccountNotifier, CoupleAccountState>((ref) {
  return CoupleAccountNotifier();
});

/// 当前用户ID提供者（模拟）
final currentUserIdProvider = Provider<String>((ref) {
  // TODO: 从认证系统获取当前用户ID
  return 'user_${DateTime.now().millisecondsSinceEpoch}';
});

/// 当前情侣账号提供者
final currentCoupleAccountProvider = Provider<CoupleAccount?>((ref) {
  final state = ref.watch(coupleAccountProvider);
  return switch (state) {
    CoupleAccountSuccess(:final account) => account,
    _ => null,
  };
});

/// 是否已绑定提供者
final isCoupleBindProvider = Provider<bool>((ref) {
  final account = ref.watch(currentCoupleAccountProvider);
  return account?.isBound ?? false;
});

/// 伴侣资料提供者
final partnerProfileProvider = Provider<CoupleProfile?>((ref) {
  final account = ref.watch(currentCoupleAccountProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  
  return account?.getPartnerProfile(currentUserId);
});

/// 我的资料提供者
final myProfileProvider = Provider<CoupleProfile?>((ref) {
  final account = ref.watch(currentCoupleAccountProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  
  return account?.getMyProfile(currentUserId);
});
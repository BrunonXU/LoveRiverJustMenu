import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/animations/christmas_snow_effect.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../domain/providers/couple_providers.dart';
import '../../domain/models/couple_account.dart';

/// 情侣档案页面
/// 显示情侣信息、邀请码分享、资料管理等
class CoupleProfileScreen extends ConsumerStatefulWidget {
  const CoupleProfileScreen({super.key});

  @override
  ConsumerState<CoupleProfileScreen> createState() => _CoupleProfileScreenState();
}

class _CoupleProfileScreenState extends ConsumerState<CoupleProfileScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // 加载情侣账号数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserId = ref.read(currentUserIdProvider);
      ref.read(coupleAccountProvider.notifier).loadCoupleAccount(currentUserId);
    });
  }
  
  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    
    _cardController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(coupleAccountProvider);

    return Scaffold(
      body: ChristmasSnowEffect(
        enableClickEffect: true,
        snowflakeCount: 3,
        clickEffectColor: const Color(0xFF00BFFF),
        child: SafeArea(
          child: Column(
            children: [
              // 头部导航
              _buildHeader(isDark),
              
              // 主要内容区域
              Expanded(
                child: _buildMainContent(state, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          // 返回按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.getTextSecondaryColor(isDark),
                  size: 18,
                ),
              ),
            ),
          ),
          
          Space.w16,
          
          // 标题
          Text(
            '情侣档案',
            style: AppTypography.titleLargeStyle(isDark: isDark),
          ),
          
          const Spacer(),
          
          // 设置按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showSettingsMenu(isDark);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.getTextSecondaryColor(isDark),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(CoupleAccountState state, bool isDark) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cardAnimation.value)),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: switch (state) {
              CoupleAccountLoading() => _buildLoadingState(isDark),
              CoupleAccountSuccess(:final account) => _buildSuccessState(account, isDark),
              CoupleAccountError(:final message) => _buildErrorState(message, isDark),
              CoupleAccountInitial() => _buildInitialState(isDark),
            },
          ),
        );
      },
    );
  }

  /// 加载状态
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: BreathingWidget(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  /// 成功状态
  Widget _buildSuccessState(CoupleAccount account, bool isDark) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final myProfile = account.getMyProfile(currentUserId);
    final partnerProfile = account.getPartnerProfile(currentUserId);
    
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // 情侣头部卡片
          _buildCoupleHeaderCard(account, isDark),
          
          Space.h24,
          
          // 个人资料卡片
          if (myProfile != null)
            _buildProfileCard('我的资料', myProfile, isDark, true),
          
          if (myProfile != null && partnerProfile != null)
            Space.h16,
          
          // 伴侣资料卡片
          if (partnerProfile != null)
            _buildProfileCard('TA的资料', partnerProfile, isDark, false),
          
          Space.h24,
          
          // 邀请码分享（仅创建者且未绑定时显示）
          if (account.isCreator(currentUserId) && !account.isBound && account.inviteCode != null)
            _buildInviteCodeCard(account.inviteCode!, isDark),
          
          Space.h24,
          
          // 组队打卡功能（如果已绑定）
          if (account.isBound)
            _buildTeamCheckInCard(account, isDark),
          
          if (account.isBound)
            Space.h24,
          
          // 统计信息
          _buildStatsCard(account, isDark),
          
          Space.h48,
        ],
      ),
    );
  }

  /// 错误状态
  Widget _buildErrorState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.getTextSecondaryColor(isDark),
          ),
          
          Space.h16,
          
          Text(
            '加载失败',
            style: AppTypography.titleMediumStyle(isDark: isDark),
          ),
          
          Space.h8,
          
          Text(
            message,
            style: AppTypography.bodySmallStyle(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          
          Space.h24,
          
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                final currentUserId = ref.read(currentUserIdProvider);
                ref.read(coupleAccountProvider.notifier).loadCoupleAccount(currentUserId);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '重试',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 初始状态（未绑定）
  Widget _buildInitialState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BreathingWidget(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          
          Space.h24,
          
          Text(
            '还没有情侣账号',
            style: AppTypography.titleMediumStyle(isDark: isDark),
          ),
          
          Space.h8,
          
          Text(
            '创建或加入情侣账号，开始美食之旅',
            style: AppTypography.bodySmallStyle(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          
          Space.h32,
          
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                // TODO: 导航到绑定页面
                // context.push('/couple/binding');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '创建情侣账号',
                  style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建情侣头部卡片
  Widget _buildCoupleHeaderCard(CoupleAccount account, bool isDark) {
    final relationshipDays = DateTime.now().difference(account.relationshipStartDate).inDays;
    
    return BreathingWidget(
      child: MinimalCard(
        child: Column(
          children: [
            // 情侣昵称
            Text(
              account.coupleName,
              style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            
            Space.h16,
            
            // 爱心图标
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 30,
              ),
            ),
            
            Space.h16,
            
            // 在一起天数
            Text(
              '在一起 $relationshipDays 天',
              style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            Space.h8,
            
            // 开始日期
            Text(
              '${account.relationshipStartDate.year}年${account.relationshipStartDate.month}月${account.relationshipStartDate.day}日',
              style: AppTypography.bodySmallStyle(isDark: isDark),
            ),
            
            Space.h16,
            
            // 状态标签
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(account.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(account.status).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getStatusText(account.status),
                style: AppTypography.captionStyle(isDark: isDark).copyWith(
                  color: _getStatusColor(account.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建资料卡片
  Widget _buildProfileCard(String title, CoupleProfile profile, bool isDark, bool isMyProfile) {
    return BreathingWidget(
      child: MinimalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Text(
                  title,
                  style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const Spacer(),
                
                if (isMyProfile)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: 编辑资料
                    },
                    child: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
              ],
            ),
            
            Space.h16,
            
            // 昵称
            _buildInfoRow('昵称', profile.nickname, Icons.person_outline, isDark),
            
            if (profile.age != null) ...[
              Space.h12,
              _buildInfoRow('年龄', '${profile.age}岁', Icons.cake_outlined, isDark),
            ],
            
            if (profile.gender != null) ...[
              Space.h12,
              _buildInfoRow('性别', _getGenderText(profile.gender!), Icons.wc, isDark),
            ],
            
            Space.h12,
            _buildInfoRow('厨艺', profile.cookingLevelDescription, Icons.restaurant, isDark),
            
            if (profile.bio != null) ...[
              Space.h12,
              _buildInfoRow('简介', profile.bio!, Icons.info_outline, isDark),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.getTextSecondaryColor(isDark),
        ),
        
        Space.w8,
        
        Text(
          '$label：',
          style: AppTypography.bodySmallStyle(isDark: isDark),
        ),
        
        Space.w4,
        
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
              color: AppColors.getTextPrimaryColor(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建邀请码卡片
  Widget _buildInviteCodeCard(String inviteCode, bool isDark) {
    return BreathingWidget(
      child: MinimalCard(
        child: Column(
          children: [
            Icon(
              Icons.share_outlined,
              size: 32,
              color: AppColors.primary,
            ),
            
            Space.h16,
            
            Text(
              '邀请TA加入',
              style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            Space.h8,
            
            Text(
              '分享邀请码给TA，一起开始美食之旅',
              style: AppTypography.bodySmallStyle(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            
            Space.h24,
            
            // 邀请码显示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getBackgroundSecondaryColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    inviteCode,
                    style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  
                  Space.w16,
                  
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('邀请码已复制'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatsCard(CoupleAccount account, bool isDark) {
    return BreathingWidget(
      child: MinimalCard(
        child: Column(
          children: [
            Text(
              '我们的数据',
              style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            Space.h24,
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('共同菜谱', '23', Icons.restaurant_menu, isDark),
                ),
                
                Expanded(
                  child: _buildStatItem('美食回忆', '15', Icons.photo_camera, isDark),
                ),
                
                Expanded(
                  child: _buildStatItem('挑战完成', '8', Icons.emoji_events, isDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
        
        Space.h8,
        
        Text(
          value,
          style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        Space.h4,
        
        Text(
          label,
          style: AppTypography.captionStyle(isDark: isDark),
        ),
      ],
    );
  }

  /// 显示设置菜单
  void _showSettingsMenu(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(isDark),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Space.h16,
            
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Space.h24,
            
            _buildSettingItem('编辑资料', Icons.edit, isDark, () {
              context.pop();
              // TODO: 编辑资料
            }),
            
            _buildSettingItem('同步数据', Icons.sync, isDark, () {
              context.pop();
              // TODO: 同步数据
            }),
            
            _buildSettingItem('解除绑定', Icons.link_off, isDark, () {
              context.pop();
              _showUnbindDialog(isDark);
            }),
            
            Space.h48,
          ],
        ),
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingItem(String title, IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.pagePadding,
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.getTextSecondaryColor(isDark),
            ),
            
            Space.w16,
            
            Text(
              title,
              style: AppTypography.bodyMediumStyle(isDark: isDark),
            ),
            
            const Spacer(),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示解绑确认对话框
  void _showUnbindDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getBackgroundColor(isDark),
        title: Text(
          '解除绑定',
          style: AppTypography.titleMediumStyle(isDark: isDark),
        ),
        content: Text(
          '确定要解除情侣绑定吗？这将清除所有共同数据。',
          style: AppTypography.bodyMediumStyle(isDark: isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              '取消',
              style: AppTypography.bodyMediumStyle(isDark: isDark),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              final currentUserId = ref.read(currentUserIdProvider);
              ref.read(coupleAccountProvider.notifier).unbindCouple(currentUserId);
            },
            child: Text(
              '确定',
              style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 组队打卡卡片
  Widget _buildTeamCheckInCard(CoupleAccount account, bool isDark) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // 模拟打卡数据（实际应该从服务器获取）
    final myProfile = account.getMyProfile(currentUserId);
    final partnerProfile = account.getPartnerProfile(currentUserId);
    final myCheckedIn = myProfile?.lastCheckIn == todayString;
    final partnerCheckedIn = partnerProfile?.lastCheckIn == todayString;
    
    return BreathingWidget(
      child: MinimalCard(
        child: Column(
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 24,
                  color: Colors.red[400],
                ),
                Space.w8,
                Text(
                  '今日组队打卡',
                  style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (myCheckedIn && partnerCheckedIn) ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (myCheckedIn && partnerCheckedIn) ? '已完成' : '进行中',
                    style: TextStyle(
                      fontSize: 12,
                      color: (myCheckedIn && partnerCheckedIn) ? Colors.green[800] : Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            Space.h16,
            
            Text(
              '和TA一起坚持每日美食打卡，增进感情～',
              style: AppTypography.bodySmallStyle(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            
            Space.h20,
            
            // 打卡状态
            Row(
              children: [
                // 我的打卡状态
                Expanded(
                  child: _buildCheckInStatus(
                    '我',
                    myProfile?.nickname ?? '我',
                    myCheckedIn,
                    isDark,
                  ),
                ),
                
                Space.w16,
                
                // 连接线
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: (myCheckedIn && partnerCheckedIn) 
                        ? Colors.red[300] 
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite,
                      size: 16,
                      color: (myCheckedIn && partnerCheckedIn) 
                          ? Colors.red[400] 
                          : Colors.grey[400],
                    ),
                  ),
                ),
                
                Space.w16,
                
                // TA的打卡状态
                Expanded(
                  child: _buildCheckInStatus(
                    'TA',
                    partnerProfile?.nickname ?? 'TA',
                    partnerCheckedIn,
                    isDark,
                  ),
                ),
              ],
            ),
            
            Space.h20,
            
            // 打卡按钮
            if (!myCheckedIn)
              BreathingWidget(
                child: GestureDetector(
                  onTap: () => _performCheckIn(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.pink[400]!],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        Space.w8,
                        Text(
                          '今日打卡',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    Space.w8,
                    Text(
                      '今日已打卡',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// 构建单个打卡状态
  Widget _buildCheckInStatus(String label, String name, bool checkedIn, bool isDark) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: checkedIn ? Colors.green[100] : Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(
              color: checkedIn ? Colors.green[300]! : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              checkedIn ? Icons.check : Icons.person,
              color: checkedIn ? Colors.green[600] : Colors.grey[600],
              size: 30,
            ),
          ),
        ),
        
        Space.h8,
        
        Text(
          name,
          style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        Space.h4,
        
        Text(
          checkedIn ? '已打卡' : '未打卡',
          style: TextStyle(
            fontSize: 12,
            color: checkedIn ? Colors.green[600] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// 执行打卡
  void _performCheckIn() {
    HapticFeedback.mediumImpact();
    
    // 显示打卡成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.favorite, color: Colors.white),
            Space.w8,
            Text('打卡成功！坚持和TA一起努力～'),
          ],
        ),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    
    // TODO: 实际项目中应该调用API更新打卡状态
    // ref.read(coupleAccountProvider.notifier).checkIn(currentUserId);
    
    // 模拟状态更新
    setState(() {
      // 这里会触发重建，显示已打卡状态
    });
  }

  // ==================== 辅助方法 ====================

  Color _getStatusColor(CoupleStatus status) {
    switch (status) {
      case CoupleStatus.active:
        return Colors.green;
      case CoupleStatus.pending:
        return Colors.orange;
      case CoupleStatus.paused:
        return Colors.grey;
      case CoupleStatus.unbound:
        return Colors.red;
    }
  }

  String _getStatusText(CoupleStatus status) {
    switch (status) {
      case CoupleStatus.active:
        return '已绑定';
      case CoupleStatus.pending:
        return '等待绑定';
      case CoupleStatus.paused:
        return '已暂停';
      case CoupleStatus.unbound:
        return '已解绑';
    }
  }

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return '男';
      case Gender.female:
        return '女';
      case Gender.other:
        return '其他';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_notification.dart';
import '../../domain/models/challenge.dart';
import 'send_challenge_screen.dart';
import 'challenge_detail_screen.dart';

/// 挑战系统主页面
/// 显示发送/接收的挑战列表，支持新建挑战
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  
  List<Challenge> _challenges = [];
  bool _hasNewChallenge = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    );
    
    _loadChallenges();
    _checkForNewChallenges();
    
    // 启动FAB动画
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _loadChallenges() {
    setState(() {
      _challenges = ChallengeData.getSampleChallenges();
    });
  }

  void _checkForNewChallenges() {
    // 检查是否有新的待处理挑战
    final pendingChallenges = _challenges
        .where((c) => c.status == ChallengeStatus.pending)
        .toList();
    
    if (pendingChallenges.isNotEmpty) {
      setState(() {
        _hasNewChallenge = true;
      });
      
      // 显示新挑战通知
      _showNewChallengeNotification(pendingChallenges.first);
    }
  }

  void _showNewChallengeNotification(Challenge challenge) {
    // 触发震动反馈
    HapticFeedback.heavyImpact();
    
    // 显示挑战通知
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChallengeNotification(
        challenge: challenge,
        onAccept: () => _acceptChallenge(challenge),
        onReject: () => _rejectChallenge(challenge),
        onViewDetail: () => _viewChallengeDetail(challenge),
      ),
    );
  }

  void _acceptChallenge(Challenge challenge) {
    HapticFeedback.lightImpact();
    setState(() {
      _hasNewChallenge = false;
      final index = _challenges.indexWhere((c) => c.id == challenge.id);
      if (index != -1) {
        _challenges[index] = challenge.copyWith(
          status: ChallengeStatus.accepted,
          acceptedAt: DateTime.now(),
        );
      }
    });
    
    Navigator.of(context).pop(); // 关闭通知
    _showSuccessMessage('挑战已接受！去厨房大显身手吧～');
  }

  void _rejectChallenge(Challenge challenge) {
    HapticFeedback.lightImpact();
    setState(() {
      _hasNewChallenge = false;
      final index = _challenges.indexWhere((c) => c.id == challenge.id);
      if (index != -1) {
        _challenges[index] = challenge.copyWith(
          status: ChallengeStatus.rejected,
        );
      }
    });
    
    Navigator.of(context).pop(); // 关闭通知
    _showSuccessMessage('已拒绝挑战');
  }

  void _viewChallengeDetail(Challenge challenge) {
    Navigator.of(context).pop(); // 关闭通知
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(challenge: challenge),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '挑战系统',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        actions: [
          // 新挑战提示
          if (_hasNewChallenge)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _checkForNewChallenges,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: Color(0xFF5B6FED),
          indicatorWeight: 2,
          tabs: const [
            Tab(text: '接收'),
            Tab(text: '发送'),
            Tab(text: '历史'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedChallenges(),
          _buildSentChallenges(),
          _buildChallengeHistory(),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _createNewChallenge,
          backgroundColor: Color(0xFF5B6FED),
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            '发起挑战',
            style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedChallenges() {
    final receivedChallenges = _challenges
        .where((c) => c.receiverId == 'user1') // 当前用户ID
        .where((c) => c.status == ChallengeStatus.pending || 
                      c.status == ChallengeStatus.accepted)
        .toList();

    return _buildChallengeList(
      challenges: receivedChallenges,
      emptyTitle: '暂无接收的挑战',
      emptySubtitle: '等待你的另一半发起挑战吧～',
      emptyIcon: Icons.inbox,
    );
  }

  Widget _buildSentChallenges() {
    final sentChallenges = _challenges
        .where((c) => c.senderId == 'user1') // 当前用户ID
        .where((c) => c.status == ChallengeStatus.pending || 
                      c.status == ChallengeStatus.accepted)
        .toList();

    return _buildChallengeList(
      challenges: sentChallenges,
      emptyTitle: '暂无发送的挑战',
      emptySubtitle: '点击下方按钮发起一个新挑战吧！',
      emptyIcon: Icons.send,
    );
  }

  Widget _buildChallengeHistory() {
    final historyeChallenges = _challenges
        .where((c) => c.status == ChallengeStatus.completed || 
                      c.status == ChallengeStatus.rejected ||
                      c.status == ChallengeStatus.expired)
        .toList();

    return _buildChallengeList(
      challenges: historyeChallenges,
      emptyTitle: '暂无历史记录',
      emptySubtitle: '完成一些挑战来积累美好回忆吧～',
      emptyIcon: Icons.history,
    );
  }

  Widget _buildChallengeList({
    required List<Challenge> challenges,
    required String emptyTitle,
    required String emptySubtitle,
    required IconData emptyIcon,
  }) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ChallengeCard(
            challenge: challenge,
            onTap: () => _viewChallengeDetail(challenge),
            onAccept: challenge.status == ChallengeStatus.pending 
                ? () => _acceptChallenge(challenge)
                : null,
            onReject: challenge.status == ChallengeStatus.pending 
                ? () => _rejectChallenge(challenge)
                : null,
          ),
        );
      },
    );
  }

  void _createNewChallenge() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SendChallengeScreen(),
      ),
    ).then((result) {
      if (result == true) {
        // 刷新挑战列表
        _loadChallenges();
        _showSuccessMessage('挑战已发送！');
      }
    });
  }
}
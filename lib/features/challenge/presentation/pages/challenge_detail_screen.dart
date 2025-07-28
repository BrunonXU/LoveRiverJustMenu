import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/challenge.dart';

/// 挑战详情页面
/// 显示挑战完整信息，支持操作和状态更新
class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _ratingNoteController = TextEditingController();
  late Challenge _challenge;
  double _currentRating = 0.0;
  bool _isCompleting = false;
  bool _isRating = false;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getProgressValue(),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _progressController.forward();
    
    // 预填充现有数据
    if (_challenge.completionNote != null) {
      _noteController.text = _challenge.completionNote!;
    }
    if (_challenge.ratingNote != null) {
      _ratingNoteController.text = _challenge.ratingNote!;
    }
    if (_challenge.rating != null) {
      _currentRating = _challenge.rating!;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    _noteController.dispose();
    _ratingNoteController.dispose();
    super.dispose();
  }

  double _getProgressValue() {
    switch (_challenge.status) {
      case ChallengeStatus.pending:
        return 0.2;
      case ChallengeStatus.accepted:
        return 0.6;
      case ChallengeStatus.completed:
        return 1.0;
      case ChallengeStatus.rejected:
      case ChallengeStatus.expired:
        return 0.0;
    }
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
          '挑战详情',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // 🔧 修复溢出：使用Expanded包装可滚动内容
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 挑战状态卡片
                      _buildStatusCard(),
                      
                      const SizedBox(height: 24),
                      
                      // 菜谱信息卡片
                      _buildRecipeCard(),
                      
                      const SizedBox(height: 24),
                      
                      // 挑战消息
                      _buildMessageCard(),
                      
                      const SizedBox(height: 24),
                      
                      // 进度追踪
                      _buildProgressCard(),
                      
                      const SizedBox(height: 24),
                      
                      // 时间信息
                      _buildTimelineCard(),
                      
                      // 完成相关操作
                      if (_shouldShowCompletionSection()) ...[ 
                        const SizedBox(height: 24),
                        _buildCompletionSection(),
                      ],
                      
                      // 评分相关操作
                      if (_shouldShowRatingSection()) ...[ 
                        const SizedBox(height: 24),
                        _buildRatingSection(),
                      ],
                      
                      // 底部留白，确保按钮不被遮挡
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              
              // 🔧 修复溢出：将操作按钮固定在底部
              if (_shouldShowActionButtons())
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: _buildActionButtons(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor = _getStatusColor();
    IconData statusIcon = _getStatusIcon();
    
    return BreathingWidget(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 状态指示条
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLarge),
                  topRight: Radius.circular(AppSpacing.radiusLarge),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // 状态图标
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 状态信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _challenge.statusText,
                          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusDescription(),
                          style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 超时提示
                  if (_challenge.isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      child: Text(
                        '超时',
                        style: AppTypography.captionStyle(isDark: false).copyWith(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildRecipeCard() {
    return BreathingWidget(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // 菜谱图标 - 🔧 减小尺寸以适应小屏幕
              Container(
                width: 60, // 从80减少到60
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF5B6FED).withOpacity(0.3),
                      blurRadius: 12, // 减小阴影
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _challenge.recipeIcon,
                    style: const TextStyle(fontSize: 24), // 减小图标
                  ),
                ),
              ),
              
              const SizedBox(width: 16), // 减少间距
              
              // 菜谱信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _challenge.recipeName,
                      style: AppTypography.titleMediumStyle(isDark: false).copyWith( // 减小字体
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 2, // 限制行数防止溢出
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 🔧 修复溢出：使用Wrap替代Row以支持换行
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                          icon: Icons.timer,
                          text: '${_challenge.estimatedTime}分钟',
                          color: Color(0xFF5B6FED),
                        ),
                        _buildInfoChip(
                          icon: Icons.star,
                          text: _challenge.difficultyText,
                          color: Color(0xFFFF6B6B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '挑战消息',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 🔧 修复溢出：使用灵活布局的Text组件
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 120, // 限制最大高度
              ),
              child: SingleChildScrollView(
                child: Text(
                  _challenge.message,
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith( // 减小字体
                    height: 1.4, // 减小行高
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '挑战进度',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 进度条
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: AppColors.backgroundSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(),
                      ),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progressAnimation.value * 100).round()}% 完成',
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '时间线',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 时间线项目
            _buildTimelineItem(
              icon: Icons.send,
              title: '挑战发起',
              time: _challenge.createdAt,
              isCompleted: true,
            ),
            
            if (_challenge.acceptedAt != null)
              _buildTimelineItem(
                icon: Icons.play_circle,
                title: '接受挑战',
                time: _challenge.acceptedAt!,
                isCompleted: true,
              ),
            
            if (_challenge.completedAt != null)
              _buildTimelineItem(
                icon: Icons.check_circle,
                title: '完成挑战',
                time: _challenge.completedAt!,
                isCompleted: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required DateTime time,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Color(0xFF5B6FED) 
                  : AppColors.backgroundSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isCompleted ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDetailTime(time),
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_add,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '完成记录',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 完成备注输入
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '分享你的制作心得和感受...',
                  hintStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: AppTypography.bodyMediumStyle(isDark: false),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 上传照片按钮
            GestureDetector(
              onTap: _uploadCompletionPhoto,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF5B6FED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: Color(0xFF5B6FED).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Color(0xFF5B6FED),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '上传完成照片',
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: Color(0xFF5B6FED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_challenge.completionPhotoUrl != null) ...[
              const SizedBox(height: 16),
              Text(
                '已上传照片',
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  color: Color(0xFF4ECB71),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '评分点评',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 星级评分
            Row(
              children: [
                Text(
                  '评分：',
                  style: AppTypography.bodyMediumStyle(isDark: false),
                ),
                const SizedBox(width: 12),
                ...List.generate(5, (index) {
                  final starValue = index + 1;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _currentRating = starValue.toDouble();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        starValue <= _currentRating ? Icons.star : Icons.star_border,
                        color: starValue <= _currentRating 
                            ? Color(0xFFFFD700) 
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${_currentRating.toStringAsFixed(1)}⭐',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 评分备注
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: TextField(
                controller: _ratingNoteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: '说说对这道菜的评价吧...',
                  hintStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: AppTypography.bodyMediumStyle(isDark: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttons = <Widget>[];
    
    if (_challenge.status == ChallengeStatus.pending) {
      // 待处理状态：接受/拒绝
      buttons.addAll([
        Expanded(
          child: _buildActionButton(
            text: '拒绝',
            color: AppColors.textSecondary,
            backgroundColor: AppColors.backgroundColor,
            onTap: _rejectChallenge,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            text: '接受挑战',
            color: Colors.white,
            backgroundColor: Color(0xFF5B6FED),
            onTap: _acceptChallenge,
          ),
        ),
      ]);
    } else if (_challenge.status == ChallengeStatus.accepted) {
      // 进行中状态：完成挑战
      buttons.add(
        _buildActionButton(
          text: _isCompleting ? '提交中...' : '完成挑战',
          color: Colors.white,
          backgroundColor: Color(0xFF4ECB71),
          onTap: _isCompleting ? null : _completeChallenge,
        ),
      );
    } else if (_challenge.status == ChallengeStatus.completed && 
               _challenge.rating == null && 
               _challenge.senderId == 'user1') { // 当前用户是发起者
      // 已完成但未评分：提交评分
      buttons.add(
        _buildActionButton(
          text: _isRating ? '提交中...' : '提交评分',
          color: Colors.white,
          backgroundColor: Color(0xFFFFD700),
          onTap: _isRating ? null : _submitRating,
        ),
      );
    }
    
    if (buttons.isEmpty) return const SizedBox.shrink();
    
    return Row(children: buttons);
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: backgroundColor == AppColors.backgroundColor
              ? Border.all(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  width: 1,
                )
              : null,
          boxShadow: backgroundColor != AppColors.backgroundColor
              ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowCompletionSection() {
    return _challenge.status == ChallengeStatus.accepted || 
           _challenge.status == ChallengeStatus.completed;
  }

  bool _shouldShowRatingSection() {
    return _challenge.status == ChallengeStatus.completed && 
           _challenge.senderId == 'user1'; // 当前用户是发起者
  }

  bool _shouldShowActionButtons() {
    return _challenge.status == ChallengeStatus.pending ||
           _challenge.status == ChallengeStatus.accepted ||
           (_challenge.status == ChallengeStatus.completed && 
            _challenge.rating == null && 
            _challenge.senderId == 'user1');
  }

  Color _getStatusColor() {
    switch (_challenge.status) {
      case ChallengeStatus.pending:
        return Color(0xFFFF6B6B);
      case ChallengeStatus.accepted:
        return Color(0xFF5B6FED);
      case ChallengeStatus.completed:
        return Color(0xFF4ECB71);
      case ChallengeStatus.rejected:
      case ChallengeStatus.expired:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (_challenge.status) {
      case ChallengeStatus.pending:
        return Icons.schedule;
      case ChallengeStatus.accepted:
        return Icons.play_circle;
      case ChallengeStatus.completed:
        return Icons.check_circle;
      case ChallengeStatus.rejected:
        return Icons.cancel;
      case ChallengeStatus.expired:
        return Icons.access_time;
    }
  }

  String _getStatusDescription() {
    switch (_challenge.status) {
      case ChallengeStatus.pending:
        return '等待对方接受挑战';
      case ChallengeStatus.accepted:
        return '挑战进行中，加油！';
      case ChallengeStatus.completed:
        return '挑战已完成，真棒！';
      case ChallengeStatus.rejected:
        return '挑战被拒绝了';
      case ChallengeStatus.expired:
        return '挑战已过期';
    }
  }

  String _formatDetailTime(DateTime time) {
    return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _acceptChallenge() {
    HapticFeedback.mediumImpact();
    setState(() {
      _challenge = _challenge.copyWith(
        status: ChallengeStatus.accepted,
        acceptedAt: DateTime.now(),
      );
    });
    
    // 重新启动进度动画
    _progressController.reset();
    _progressAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
    
    _showSuccessMessage('挑战已接受！去厨房大显身手吧～');
  }

  void _rejectChallenge() {
    HapticFeedback.lightImpact();
    setState(() {
      _challenge = _challenge.copyWith(
        status: ChallengeStatus.rejected,
      );
    });
    _showSuccessMessage('已拒绝挑战');
  }

  void _completeChallenge() {
    if (_noteController.text.trim().isEmpty) {
      _showErrorMessage('请填写完成备注');
      return;
    }
    
    setState(() {
      _isCompleting = true;
    });
    
    HapticFeedback.mediumImpact();
    
    // 模拟提交过程
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCompleting = false;
          _challenge = _challenge.copyWith(
            status: ChallengeStatus.completed,
            completedAt: DateTime.now(),
            completionNote: _noteController.text.trim(),
          );
        });
        
        // 重新启动进度动画
        _progressController.reset();
        _progressAnimation = Tween<double>(
          begin: 0.6,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeInOut,
        ));
        _progressController.forward();
        
        _showSuccessMessage('挑战完成！等待对方评分～');
      }
    });
  }

  void _submitRating() {
    if (_currentRating == 0) {
      _showErrorMessage('请给出评分');
      return;
    }
    
    setState(() {
      _isRating = true;
    });
    
    HapticFeedback.mediumImpact();
    
    // 模拟提交过程
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isRating = false;
          _challenge = _challenge.copyWith(
            rating: _currentRating,
            ratingNote: _ratingNoteController.text.trim(),
          );
        });
        
        _showSuccessMessage('评分已提交！');
      }
    });
  }

  void _uploadCompletionPhoto() {
    HapticFeedback.lightImpact();
    // 这里应该调用图片选择器
    // 暂时模拟上传成功
    setState(() {
      _challenge = _challenge.copyWith(
        completionPhotoUrl: 'uploaded_photo.jpg',
      );
    });
    _showSuccessMessage('照片上传成功！');
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
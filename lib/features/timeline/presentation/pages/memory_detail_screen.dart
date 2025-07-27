import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/memory.dart';

/// 记忆详情页面
/// 显示完整的美食故事，支持一句话点评功能
class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;
  final Function(Memory)? onMemoryUpdated;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    this.onMemoryUpdated,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _commentAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _commentAnimation;
  
  final TextEditingController _commentTextController = TextEditingController();
  late Memory _memory;
  bool _isCommenting = false;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _memory = widget.memory;
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _commentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _commentAnimation = CurvedAnimation(
      parent: _commentAnimationController,
      curve: Curves.easeOut,
    );
    
    _fadeController.forward();
    
    // 预填充现有评论
    if (_memory.oneLineComment != null) {
      _commentTextController.text = _memory.oneLineComment!;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _commentAnimationController.dispose();
    _commentTextController.dispose();
    super.dispose();
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
          '美食回忆',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_canComment())
            IconButton(
              icon: Icon(
                _isCommenting ? Icons.close : Icons.rate_review,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: _toggleCommentMode,
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 记忆标题卡片
              _buildHeaderCard(),
              
              const SizedBox(height: 24),
              
              // 美食故事卡片
              if (_memory.story != null) ...[
                _buildStoryCard(),
                const SizedBox(height: 24),
              ],
              
              // 制作详情卡片
              _buildDetailsCard(),
              
              const SizedBox(height: 24),
              
              // 点评区域
              _buildCommentSection(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
          // 特殊记忆的彩色边框
          border: _memory.special
              ? Border.all(
                  color: Color(0xFF5B6FED).withOpacity(0.3),
                  width: 2,
                )
              : null,
        ),
        child: Column(
          children: [
            // 特殊记忆顶部装饰
            if (_memory.special)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusLarge),
                    topRight: Radius.circular(AppSpacing.radiusLarge),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // 主要信息
                  Row(
                    children: [
                      // 表情图标
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _memory.special
                              ? Color(0xFF5B6FED).withOpacity(0.1)
                              : AppColors.backgroundSecondary,
                          shape: BoxShape.circle,
                          border: _memory.special
                              ? Border.all(
                                  color: Color(0xFF5B6FED).withOpacity(0.3),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _memory.emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // 标题信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _memory.title,
                              style: AppTypography.titleLargeStyle(isDark: false).copyWith(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatMemoryDate(_memory.date),
                              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 心情标签
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _memory.special 
                                    ? Color(0xFF5B6FED).withOpacity(0.1)
                                    : AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                              ),
                              child: Text(
                                _memory.mood,
                                style: AppTypography.captionStyle(isDark: false).copyWith(
                                  color: _memory.special 
                                      ? Color(0xFF5B6FED)
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // 简短描述
                  if (_memory.description != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                      child: Text(
                        _memory.description!,
                        style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard() {
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
                  Icons.auto_stories,
                  size: 20,
                  color: Color(0xFF5B6FED),
                ),
                const SizedBox(width: 8),
                Text(
                  '美食故事',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF5B6FED),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _memory.story!,
              style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
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
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '制作详情',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 详情列表
            if (_memory.difficulty != null)
              _buildDetailItem(
                icon: Icons.star,
                label: '制作难度',
                value: _getDifficultyText(_memory.difficulty!),
                color: Color(0xFFFF6B6B),
              ),
            
            if (_memory.cookingTime != null)
              _buildDetailItem(
                icon: Icons.timer,
                label: '制作用时',
                value: '${_memory.cookingTime}分钟',
                color: Color(0xFF5B6FED),
              ),
            
            if (_memory.cookId != null)
              _buildDetailItem(
                icon: Icons.person,
                label: '制作者',
                value: _getCookName(_memory.cookId!),
                color: Color(0xFF4ECB71),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 现有评论显示
        if (_memory.oneLineComment != null && !_isCommenting)
          _buildExistingComment(),
        
        // 评论输入区域（动画显示/隐藏）
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _isCommenting 
              ? _buildCommentInput()
              : const SizedBox.shrink(),
        ),
        
        // 评论按钮（当没有评论且不在编辑模式时显示）
        if (_memory.oneLineComment == null && !_isCommenting && _canComment())
          _buildAddCommentButton(),
      ],
    );
  }

  Widget _buildExistingComment() {
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
      child: Column(
        children: [
          // 彩色顶部装饰
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLarge),
                topRight: Radius.circular(AppSpacing.radiusLarge),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 20,
                      color: Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '一句话点评',
                      style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                        fontWeight: FontWeight.w300,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    const Spacer(),
                    if (_canEditComment())
                      GestureDetector(
                        onTap: _toggleCommentMode,
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  _memory.oneLineComment!,
                  style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Text(
                      '—— ${_getCommenterName(_memory.commenterId!)}',
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCommentTime(_memory.commentedAt!),
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
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
                  Icons.rate_review,
                  size: 20,
                  color: Color(0xFF5B6FED),
                ),
                const SizedBox(width: 8),
                Text(
                  '写下你的点评',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF5B6FED),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: TextField(
                controller: _commentTextController,
                maxLines: 3,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: '用一句话说说你的感受...',
                  hintStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: AppTypography.captionStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                style: AppTypography.bodyMediumStyle(isDark: false),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    text: '取消',
                    color: AppColors.textSecondary,
                    backgroundColor: AppColors.backgroundColor,
                    onTap: _cancelComment,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    text: _isSubmittingComment ? '提交中...' : '提交点评',
                    color: Colors.white,
                    backgroundColor: Color(0xFF5B6FED),
                    onTap: _isSubmittingComment ? null : _submitComment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCommentButton() {
    return GestureDetector(
      onTap: _toggleCommentMode,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFF5B6FED).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: Color(0xFF5B6FED).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_comment,
              color: Color(0xFF5B6FED),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '写一句话点评',
              style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                color: Color(0xFF5B6FED),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _canComment() {
    // 当前用户不是制作者，且还没有评论过
    return _memory.cookId != 'user1' || _memory.commenterId == null;
  }

  bool _canEditComment() {
    // 当前用户是评论者
    return _memory.commenterId == 'user1';
  }

  void _toggleCommentMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isCommenting = !_isCommenting;
    });
    
    if (_isCommenting) {
      _commentAnimationController.forward();
    } else {
      _commentAnimationController.reverse();
      // 重置输入
      if (_memory.oneLineComment != null) {
        _commentTextController.text = _memory.oneLineComment!;
      } else {
        _commentTextController.clear();
      }
    }
  }

  void _cancelComment() {
    _toggleCommentMode();
  }

  void _submitComment() {
    if (_commentTextController.text.trim().isEmpty) {
      _showErrorMessage('请输入点评内容');
      return;
    }
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    HapticFeedback.mediumImpact();
    
    // 模拟提交过程
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
          _isCommenting = false;
          _memory = _memory.copyWith(
            oneLineComment: _commentTextController.text.trim(),
            commenterId: 'user1', // 当前用户ID
            commentedAt: DateTime.now(),
          );
        });
        
        _commentAnimationController.reverse();
        widget.onMemoryUpdated?.call(_memory);
        _showSuccessMessage('点评已提交！');
      }
    });
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return '简单';
      case 2:
        return '容易';
      case 3:
        return '中等';
      case 4:
        return '困难';
      case 5:
        return '专业';
      default:
        return '未知';
    }
  }

  String _getCookName(String cookId) {
    return cookId == 'user1' ? '我' : 'TA';
  }

  String _getCommenterName(String commenterId) {
    return commenterId == 'user1' ? '我' : 'TA';
  }

  String _formatMemoryDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference天前';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  String _formatCommentTime(DateTime time) {
    return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
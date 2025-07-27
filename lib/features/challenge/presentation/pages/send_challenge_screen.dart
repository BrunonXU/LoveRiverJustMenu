import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../domain/models/challenge.dart';

/// 发送挑战页面
/// 选择菜谱并发送挑战给情侣
class SendChallengeScreen extends StatefulWidget {
  const SendChallengeScreen({super.key});

  @override
  State<SendChallengeScreen> createState() => _SendChallengeScreenState();
}

class _SendChallengeScreenState extends State<SendChallengeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _messageController = TextEditingController();
  String? _selectedRecipeId;
  String _selectedRecipeName = '';
  String _selectedRecipeIcon = '';
  int _selectedDifficulty = 3;
  int _estimatedTime = 30;
  
  final List<Map<String, dynamic>> _availableRecipes = [
    {
      'id': 'recipe_001',
      'name': '爱心蛋炒饭',
      'icon': '🍳',
      'difficulty': 2,
      'time': 15,
      'description': '简单易做的温馨早餐',
    },
    {
      'id': 'recipe_002',
      'name': '红烧肉',
      'icon': '🥩',
      'difficulty': 3,
      'time': 45,
      'description': '经典家常菜，需要耐心炖煮',
    },
    {
      'id': 'recipe_003',
      'name': '提拉米苏',
      'icon': '🧁',
      'difficulty': 4,
      'time': 60,
      'description': '精致甜品，制作工艺复杂',
    },
    {
      'id': 'recipe_004',
      'name': '麻婆豆腐',
      'icon': '🌶️',
      'difficulty': 3,
      'time': 20,
      'description': '川菜经典，麻辣鲜香',
    },
    {
      'id': 'recipe_005',
      'name': '蒸蛋羹',
      'icon': '🥚',
      'difficulty': 1,
      'time': 10,
      'description': '嫩滑营养，老少皆宜',
    },
    {
      'id': 'recipe_006',
      'name': '可乐鸡翅',
      'icon': '🍗',
      'difficulty': 2,
      'time': 25,
      'description': '孩子最爱的甜味鸡翅',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _messageController.text = '一起来做这道菜吧！期待你的作品～';
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
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
          '发起挑战',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selectedRecipeId != null ? _sendChallenge : null,
            child: Text(
              '发送',
              style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                color: _selectedRecipeId != null 
                    ? Color(0xFF5B6FED) 
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
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
              // 标题说明
              _buildSectionTitle('选择挑战菜谱'),
              const SizedBox(height: 16),
              
              // 菜谱选择
              _buildRecipeGrid(),
              
              const SizedBox(height: 32),
              
              // 挑战消息
              _buildSectionTitle('挑战消息'),
              const SizedBox(height: 16),
              _buildMessageInput(),
              
              const SizedBox(height: 32),
              
              // 挑战设置
              if (_selectedRecipeId != null) ...[
                _buildSectionTitle('挑战设置'),
                const SizedBox(height: 16),
                _buildChallengeSettings(),
                
                const SizedBox(height: 32),
                
                // 预览卡片
                _buildPreviewCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleMediumStyle(isDark: false).copyWith(
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildRecipeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _availableRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _availableRecipes[index];
        final isSelected = _selectedRecipeId == recipe['id'];
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedRecipeId = recipe['id'];
              _selectedRecipeName = recipe['name'];
              _selectedRecipeIcon = recipe['icon'];
              _selectedDifficulty = recipe['difficulty'];
              _estimatedTime = recipe['time'];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Color(0xFF5B6FED).withOpacity(0.1)
                  : AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: isSelected 
                    ? Color(0xFF5B6FED)
                    : AppColors.backgroundSecondary,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 菜谱图标
                  Text(
                    recipe['icon'],
                    style: const TextStyle(fontSize: 36),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 菜谱名称
                  Text(
                    recipe['name'],
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Color(0xFF5B6FED) : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 难度和时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMiniChip(
                        icon: Icons.star,
                        text: _getDifficultyText(recipe['difficulty']),
                      ),
                      const SizedBox(width: 8),
                      _buildMiniChip(
                        icon: Icons.timer,
                        text: '${recipe['time']}分',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _messageController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: '写一句鼓励的话吧～',
          hintStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: AppTypography.bodyMediumStyle(isDark: false),
      ),
    );
  }

  Widget _buildChallengeSettings() {
    return Column(
      children: [
        // 难度设置
        _buildSettingRow(
          title: '难度等级',
          child: Row(
            children: List.generate(5, (index) {
              final level = index + 1;
              final isSelected = level == _selectedDifficulty;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedDifficulty = level;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Color(0xFF5B6FED)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Text(
                    _getDifficultyText(level),
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 预估时间
        _buildSettingRow(
          title: '预估时间',
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_estimatedTime > 5) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _estimatedTime -= 5;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF5B6FED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Text(
                  '$_estimatedTime分钟',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: Color(0xFF5B6FED),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              GestureDetector(
                onTap: () {
                  if (_estimatedTime < 120) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _estimatedTime += 5;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required String title,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: AppTypography.bodySmallStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildPreviewCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 预览标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF5B6FED).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLarge),
                topRight: Radius.circular(AppSpacing.radiusLarge),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.preview,
                  size: 16,
                  color: Color(0xFF5B6FED),
                ),
                const SizedBox(width: 8),
                Text(
                  '挑战预览',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: Color(0xFF5B6FED),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // 预览内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 菜谱信息
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                      child: Center(
                        child: Text(
                          _selectedRecipeIcon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedRecipeName,
                            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildMiniChip(
                                icon: Icons.timer,
                                text: '${_estimatedTime}分钟',
                              ),
                              const SizedBox(width: 8),
                              _buildMiniChip(
                                icon: Icons.star,
                                text: _getDifficultyText(_selectedDifficulty),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 挑战消息
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Text(
                    _messageController.text.isEmpty 
                        ? '一起来做这道菜吧！期待你的作品～'
                        : _messageController.text,
                    style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  void _sendChallenge() {
    if (_selectedRecipeId == null) return;
    
    HapticFeedback.mediumImpact();
    
    // 这里应该调用API发送挑战
    // 暂时模拟发送成功
    
    Navigator.of(context).pop(true); // 返回成功标志
  }
}
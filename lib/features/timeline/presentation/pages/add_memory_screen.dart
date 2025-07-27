import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/memory.dart';

/// 添加美食记忆页面
/// 记录每道菜的故事，创建美好回忆
class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedEmoji = '🍳';
  String _selectedMood = '开心';
  bool _isSpecial = false;
  int _difficulty = 3;
  int _cookingTime = 30;
  bool _isSubmitting = false;

  final List<String> _availableEmojis = [
    '🍳', '🥘', '🍲', '🍜', '🍝', '🍕', '🍔', '🌮', '🥗', '🍱',
    '🍙', '🍘', '🍚', '🍛', '🍤', '🍣', '🍖', '🥩', '🍗', '🍞',
    '🥐', '🧁', '🍰', '🎂', '🍮', '🍭', '🍫', '🍿', '🥤', '☕'
  ];

  final List<String> _availableMoods = [
    '开心', '满足', '兴奋', '浪漫', '温馨', '感恩', '惊喜', '舒适', '怀念', '期待'
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _titleController.dispose();
    _storyController.dispose();
    _descriptionController.dispose();
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
          '记录美食时光',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _canSubmit() ? _submitMemory : null,
            child: Text(
              _isSubmitting ? '保存中...' : '保存',
              style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                color: _canSubmit() 
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
              // 基本信息卡片
              _buildBasicInfoCard(),
              
              const SizedBox(height: 24),
              
              // 美食故事卡片
              _buildStoryCard(),
              
              const SizedBox(height: 24),
              
              // 详细设置卡片
              _buildDetailCard(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题输入
              _buildSectionTitle('美食名称'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: '今天做了什么好吃的？',
                    hintStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: AppTypography.bodyMediumStyle(isDark: false),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 表情选择
              _buildSectionTitle('选择表情'),
              const SizedBox(height: 12),
              Container(
                height: 100,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableEmojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _availableEmojis[index];
                    final isSelected = emoji == _selectedEmoji;
                    
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedEmoji = emoji;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Color(0xFF5B6FED).withOpacity(0.1)
                              : AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          border: Border.all(
                            color: isSelected 
                                ? Color(0xFF5B6FED)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 心情选择
              _buildSectionTitle('当时心情'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _availableMoods.map((mood) {
                  final isSelected = mood == _selectedMood;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedMood = mood;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Color(0xFF5B6FED)
                            : AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                      ),
                      child: Text(
                        mood,
                        style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // 特殊记忆开关
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '特殊记忆',
                          style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '标记为特殊记忆会在时光机中突出显示',
                          style: AppTypography.captionStyle(isDark: false).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isSpecial,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isSpecial = value;
                      });
                    },
                    activeColor: Color(0xFF5B6FED),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard() {
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
              const SizedBox(height: 4),
              Text(
                '记录制作过程中的点点滴滴',
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 故事输入
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: TextField(
                  controller: _storyController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: '说说制作这道菜时的故事吧...\n\n比如：为什么选择做这道菜？制作过程中有什么有趣的事？和谁一起分享？',
                    hintStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 简短描述
              Text(
                '简短描述',
                style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: '一句话总结这道菜...',
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
      ),
    );
  }

  Widget _buildDetailCard() {
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
            _buildSectionTitle('制作详情'),
            const SizedBox(height: 16),
            
            // 难度选择
            _buildDetailRow(
              title: '制作难度',
              child: Row(
                children: List.generate(5, (index) {
                  final level = index + 1;
                  final isSelected = level == _difficulty;
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _difficulty = level;
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
            
            // 用时设置
            _buildDetailRow(
              title: '制作用时',
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_cookingTime > 5) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _cookingTime -= 5;
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
                      '$_cookingTime分钟',
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: Color(0xFF5B6FED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  GestureDetector(
                    onTap: () {
                      if (_cookingTime < 300) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _cookingTime += 5;
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
            
            const SizedBox(height: 20),
            
            // 日期选择
            _buildDetailRow(
              title: '制作日期',
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatSelectedDate(_selectedDate),
                        style: AppTypography.bodyMediumStyle(isDark: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDetailRow({
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

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    if (selectedDay == today) {
      return '今天';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF5B6FED),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  bool _canSubmit() {
    return _titleController.text.trim().isNotEmpty &&
           _storyController.text.trim().isNotEmpty &&
           !_isSubmitting;
  }

  void _submitMemory() {
    if (!_canSubmit()) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    HapticFeedback.mediumImpact();
    
    // 创建新记忆
    final newMemory = Memory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      title: _titleController.text.trim(),
      emoji: _selectedEmoji,
      special: _isSpecial,
      mood: _selectedMood,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      story: _storyController.text.trim(),
      difficulty: _difficulty,
      cookingTime: _cookingTime,
      cookId: 'user1', // 当前用户ID
    );
    
    // 模拟保存过程
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(newMemory);
        _showSuccessMessage('美食记忆已保存！');
      }
    });
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
}
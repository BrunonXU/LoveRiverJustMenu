import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../timeline/domain/models/memory.dart';
import '../../../../shared/widgets/breathing_widget.dart';

/// 美食日记页面
/// 实现翻页日记本风格的极简设计
class FoodJournalScreen extends StatefulWidget {
  const FoodJournalScreen({super.key});

  @override
  State<FoodJournalScreen> createState() => _FoodJournalScreenState();
}

class _FoodJournalScreenState extends State<FoodJournalScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  
  int _currentPage = 0;
  final List<List<Memory>> _journalPages = [];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAnimations();
    _organizeMemoriesIntoPages();
  }
  
  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _breathingController.repeat(reverse: true);
      }
    });
  }
  
  /// 将记忆数据组织成页面
  void _organizeMemoriesIntoPages() {
    final memories = MemoryData.getSampleMemories();
    
    // 按日期排序，最新的在前
    memories.sort((a, b) => b.date.compareTo(a.date));
    
    // 根据记忆数量决定每页显示数量
    for (int i = 0; i < memories.length;) {
      final remainingMemories = memories.length - i;
      int pageSize;
      
      if (remainingMemories >= 9) {
        pageSize = 9; // 3x3网格
      } else if (remainingMemories >= 6) {
        pageSize = 6; // 3x2网格
      } else if (remainingMemories >= 4) {
        pageSize = 4; // 2x2网格
      } else {
        pageSize = remainingMemories; // 剩余数量
      }
      
      final pageMemories = memories.sublist(i, i + pageSize);
      _journalPages.add(pageMemories);
      i += pageSize;
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF0), // 纸质背景色
      appBar: _buildAppBar(),
      body: _buildJournalContent(),
    );
  }
  
  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        '美食日记',
        style: AppTypography.titleMediumStyle(isDark: false).copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w300,
        ),
      ),
      centerTitle: true,
      actions: [
        // 页码指示器
        if (_journalPages.isNotEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1}/${_journalPages.length}',
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  /// 构建日记本内容
  Widget _buildJournalContent() {
    if (_journalPages.isEmpty) {
      return _buildEmptyJournal();
    }
    
    return Container(
      margin: AppSpacing.pagePadding,
      decoration: _buildPaperDecoration(),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
          HapticFeedback.lightImpact();
        },
        itemCount: _journalPages.length,
        itemBuilder: (context, index) => _buildJournalPage(index),
      ),
    );
  }
  
  /// 构建纸质装饰
  BoxDecoration _buildPaperDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        // 主要阴影
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
        // 纸质层次感
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 40,
          offset: const Offset(0, 16),
          spreadRadius: -8,
        ),
      ],
      // 纸质纹理
      border: Border.all(
        color: Colors.grey.withOpacity(0.1),
        width: 0.5,
      ),
    );
  }
  
  /// 构建单个日记页面
  Widget _buildJournalPage(int pageIndex) {
    final memories = _journalPages[pageIndex];
    final gridSize = _getOptimalGridSize(memories.length);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // 页面标题区域
          _buildPageHeader(pageIndex, memories),
          
          const SizedBox(height: 24),
          
          // 记忆网格
          Expanded(
            child: _buildMemoryGrid(memories, gridSize),
          ),
          
          // 页面装饰线
          _buildPageDecoration(),
        ],
      ),
    );
  }
  
  /// 构建页面头部
  Widget _buildPageHeader(int pageIndex, List<Memory> memories) {
    if (memories.isEmpty) return const SizedBox.shrink();
    
    // 获取这一页的日期范围
    final startDate = memories.last.date;
    final endDate = memories.first.date;
    final isSameMonth = startDate.year == endDate.year && startDate.month == endDate.month;
    
    String dateRange;
    if (isSameMonth) {
      dateRange = '${startDate.year}年${startDate.month}月';
    } else {
      dateRange = '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    }
    
    return BreathingWidget(
      child: Column(
        children: [
          Text(
            dateRange,
            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w300,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${memories.length} 个美食记忆',
            style: AppTypography.bodySmallStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建记忆网格
  Widget _buildMemoryGrid(List<Memory> memories, GridSize gridSize) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize.columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85, // 稍微高一些的卡片比例
      ),
      itemCount: memories.length,
      itemBuilder: (context, index) => _buildMemoryCard(memories[index], index),
    );
  }
  
  /// 构建记忆卡片
  Widget _buildMemoryCard(Memory memory, int index) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          final breathingScale = 1.0 + (_breathingAnimation.value * 0.02);
          final breathingOpacity = 0.9 + (_breathingAnimation.value * 0.1);
          
          return Transform.scale(
            scale: breathingScale,
            child: Opacity(
              opacity: breathingOpacity,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showMemoryDetail(memory);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: memory.special
                        ? Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          )
                        : Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 0.5,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: memory.special
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: memory.special ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji
                      Flexible(
                        flex: 3,
                        child: Text(
                          memory.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // 标题
                      Flexible(
                        flex: 2,
                        child: Text(
                          memory.title,
                          style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // 日期
                      Text(
                        '${memory.date.month}/${memory.date.day}',
                        style: AppTypography.captionStyle(isDark: false).copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      
                      const SizedBox(height: 3),
                      
                      // 心情标签
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            memory.mood,
                            style: AppTypography.captionStyle(isDark: false).copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 构建页面装饰
  Widget _buildPageDecoration() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
  
  /// 构建空日记
  Widget _buildEmptyJournal() {
    return Container(
      margin: AppSpacing.pagePadding,
      decoration: _buildPaperDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BreathingWidget(
              child: Text(
                '📖',
                style: const TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '日记本是空的',
              style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '开始记录你们的美食时光吧',
              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 显示记忆详情
  void _showMemoryDetail(Memory memory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildMemoryDetailSheet(memory),
    );
  }
  
  /// 构建记忆详情底部面板
  Widget _buildMemoryDetailSheet(Memory memory) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和emoji
                  Row(
                    children: [
                      Text(
                        memory.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              memory.title,
                              style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatFullDate(memory.date),
                              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 心情标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      memory.mood,
                      style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 描述
                  if (memory.description != null) ...[
                    Text(
                      memory.description!,
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 故事
                  if (memory.story != null) ...[
                    Text(
                      '记忆片段',
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      memory.story!,
                      style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 获取最佳网格尺寸
  GridSize _getOptimalGridSize(int itemCount) {
    if (itemCount >= 9) return GridSize(3, 3);
    if (itemCount >= 6) return GridSize(3, 2);
    if (itemCount >= 4) return GridSize(2, 2);
    if (itemCount >= 3) return GridSize(3, 1);
    if (itemCount >= 2) return GridSize(2, 1);
    return GridSize(1, 1);
  }
  
  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月';
  }
  
  /// 格式化完整日期
  String _formatFullDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// 网格尺寸类
class GridSize {
  final int columns;
  final int rows;
  
  GridSize(this.columns, this.rows);
}
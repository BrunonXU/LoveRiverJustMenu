import 'package:flutter/material.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../widgets/timeline_3d_widget.dart';
import '../../domain/models/memory.dart';

/// 3D时光机界面
/// 已集成完整的3D时光机功能，支持手势操作和呼吸动画
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取示例记忆数据
    final memories = MemoryData.getSampleMemories();
    
    return Scaffold(
      body: Timeline3DWidget(
        memories: memories,
        onMemoryTap: (memory) {
          // 显示记忆详情
          _showMemoryDetail(context, memory);
        },
      ),
    );
  }
  
  void _showMemoryDetail(BuildContext context, Memory memory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLarge),
              ),
            ),
            padding: AppSpacing.pagePadding,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 拖拽指示器
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  Space.h24,
                  
                  // 记忆标题
                  Row(
                    children: [
                      Text(
                        memory.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      
                      Space.w16,
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              memory.title,
                              style: AppTypography.titleLargeStyle(
                                isDark: false,
                              ).copyWith(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            
                            Space.h8,
                            
                            Text(
                              _formatMemoryDate(memory.date),
                              style: AppTypography.bodySmallStyle(
                                isDark: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  Space.h24,
                  
                  // 心情标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: memory.special 
                        ? AppColors.primaryGradient.colors.first.withOpacity(0.1)
                        : AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    child: Text(
                      memory.mood,
                      style: AppTypography.bodySmallStyle(
                        isDark: false,
                      ).copyWith(
                        color: memory.special 
                          ? AppColors.primaryGradient.colors.first
                          : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  if (memory.description != null) ...[
                    Space.h24,
                    Text(
                      memory.description!,
                      style: AppTypography.bodyMediumStyle(
                        isDark: false,
                      ).copyWith(
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
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
}
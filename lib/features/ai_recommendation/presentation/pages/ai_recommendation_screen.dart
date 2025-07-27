import 'package:flutter/material.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../shared/widgets/minimal_card.dart';

/// AI智能推荐界面占位
/// 将在后续任务中实现完整功能
class AiRecommendationScreen extends StatelessWidget {
  const AiRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      appBar: AppBar(
        title: Text(
          'AI推荐',
          style: AppTypography.titleLargeStyle(isDark: isDark),
        ),
      ),
      body: Center(
        child: MinimalCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.emotionGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AI智能推荐',
                style: AppTypography.titleMediumStyle(isDark: isDark),
              ),
              const SizedBox(height: 8),
              Text(
                '故事化推荐开发中...',
                style: AppTypography.bodySmallStyle(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
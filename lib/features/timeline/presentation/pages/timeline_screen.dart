import 'package:flutter/material.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../shared/widgets/minimal_card.dart';

/// 3D时光机界面占位
/// 将在后续任务中实现完整功能
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      appBar: AppBar(
        title: Text(
          '美食时光机',
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
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.timeline,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '3D时光机功能',
                style: AppTypography.titleMediumStyle(isDark: isDark),
              ),
              const SizedBox(height: 8),
              Text(
                '开发中...',
                style: AppTypography.bodySmallStyle(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../shared/widgets/minimal_card.dart';

/// 烹饪模式界面占位
/// 将在后续任务中实现完整功能
class CookingModeScreen extends StatelessWidget {
  const CookingModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      appBar: AppBar(
        title: Text(
          '烹饪模式',
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
                  gradient: AppColors.specialGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '烹饪模式',
                style: AppTypography.titleMediumStyle(isDark: isDark),
              ),
              const SizedBox(height: 8),
              Text(
                '横屏全屏模式开发中...',
                style: AppTypography.bodySmallStyle(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 添加缺失的图标
extension on Icons {
  static const IconData chef_hat = IconData(
    0xe0d0,
    fontFamily: 'MaterialIcons',
  );
}
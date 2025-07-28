import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../domain/models/province_cuisine.dart';

/// 🚀 极简高性能中国地图
class ChinaMapSimple extends StatelessWidget {
  final List<ProvinceCuisine> provinces;
  final ChineseProvince? selectedProvince;
  final Function(ChineseProvince) onProvinceSelected;

  const ChinaMapSimple({
    super.key,
    required this.provinces,
    this.selectedProvince,
    required this.onProvinceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          // 地图标题
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🗺️', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '中华美食地图',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // 简化的地图区域
          Container(
            height: 300,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // 中国轮廓背景
                Center(
                  child: Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        '🇨🇳',
                        style: TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                ),
                
                // 省份标记点 - 简化位置
                ..._buildSimpleProvinceMarkers(),
              ],
            ),
          ),
          
          // 省份网格列表
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildProvinceGrid(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSimpleProvinceMarkers() {
    // 只显示前6个省份的简化标记
    final displayProvinces = provinces.take(6).toList();
    
    return displayProvinces.asMap().entries.map((entry) {
      final index = entry.key;
      final province = entry.value;
      
      // 简单的网格位置计算
      final row = index ~/ 3;
      final col = index % 3;
      final left = 50.0 + col * 60.0;
      final top = 80.0 + row * 60.0;
      
      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onProvinceSelected(province.province);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: province.isUnlocked 
                  ? province.themeColor.withValues(alpha: 0.8)
                  : AppColors.backgroundSecondary,
              border: Border.all(
                color: province.isUnlocked 
                    ? province.themeColor
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                province.iconEmoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildProvinceGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          '美食省份',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 省份网格
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: provinces.map((province) => 
            _buildProvinceChip(province)
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildProvinceChip(ProvinceCuisine province) {
    final isSelected = selectedProvince == province.province;
    final isUnlocked = province.isUnlocked;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onProvinceSelected(province.province);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? province.themeColor.withValues(alpha: 0.2)
              : isUnlocked 
                  ? province.themeColor.withValues(alpha: 0.1)
                  : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? province.themeColor
                : isUnlocked 
                    ? province.themeColor.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              province.iconEmoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              province.provinceName,
              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                color: isUnlocked 
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: province.themeColor,
              ),
            ] else if (province.isNearUnlock) ...[
              const SizedBox(width: 4),
              Text(
                '${province.progressPercentage}%',
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  fontSize: 10,
                  color: AppColors.emotionGradient.colors.first,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
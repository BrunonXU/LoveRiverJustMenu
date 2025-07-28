import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../domain/models/province_cuisine.dart';

/// 中国地图组件 - 简化版可视化
class ChinaMapWidget extends StatefulWidget {
  final List<ProvinceCuisine> provinces;
  final ChineseProvince? selectedProvince;
  final Function(ChineseProvince) onProvinceSelected;

  const ChinaMapWidget({
    super.key,
    required this.provinces,
    this.selectedProvince,
    required this.onProvinceSelected,
  });

  @override
  State<ChinaMapWidget> createState() => _ChinaMapWidgetState();
}

class _ChinaMapWidgetState extends State<ChinaMapWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 背景装饰
            _buildBackground(),
            
            // 简化的省份布局
            ..._buildProvinceMarkers(constraints),
            
            // 图例
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildLegend(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundSecondary.withOpacity(0.3),
            AppColors.backgroundColor,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _MapBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }

  List<Widget> _buildProvinceMarkers(BoxConstraints constraints) {
    final markers = <Widget>[];
    
    // 简化的省份位置映射
    final provincePositions = _getProvincePositions(constraints);
    
    for (final province in widget.provinces) {
      final position = provincePositions[province.province];
      if (position != null) {
        markers.add(_buildProvinceMarker(province, position));
      }
    }
    
    return markers;
  }

  Widget _buildProvinceMarker(ProvinceCuisine province, Offset position) {
    final isSelected = widget.selectedProvince == province.province;
    final isUnlocked = province.isUnlocked;
    final isNearUnlock = province.isNearUnlock;
    
    Widget marker = GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onProvinceSelected(province.province);
      },
      child: Container(
        width: isSelected ? 70 : 60,
        height: isSelected ? 70 : 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isUnlocked 
              ? province.themeColor.withOpacity(0.9)
              : AppColors.backgroundColor,
          border: Border.all(
            color: isUnlocked 
                ? province.themeColor
                : isNearUnlock 
                    ? AppColors.emotionGradient.colors.first
                    : AppColors.textSecondary.withOpacity(0.3),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (isUnlocked || isNearUnlock)
              BoxShadow(
                color: isUnlocked 
                    ? province.themeColor.withOpacity(0.5)
                    : AppColors.emotionGradient.colors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                province.iconEmoji,
                style: TextStyle(
                  fontSize: isSelected ? 26 : 22,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 2),
                Text(
                  province.provinceName,
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    color: isUnlocked ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    
    // 添加动画效果
    if (isNearUnlock && !isUnlocked) {
      marker = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.1),
            child: marker,
          );
        },
      );
    }
    
    if (isUnlocked) {
      marker = AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatController.value * 4 - 2),
            child: marker,
          );
        },
      );
    }
    
    return Positioned(
      left: position.dx - 30,
      top: position.dy - 30,
      child: marker,
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(
            color: const Color(0xFF4ECB71),
            label: '已解锁',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            color: AppColors.emotionGradient.colors.first,
            label: '即将解锁',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            color: AppColors.textSecondary.withOpacity(0.3),
            label: '未解锁',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.captionStyle(isDark: false).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // 简化的省份位置映射
  Map<ChineseProvince, Offset> _getProvincePositions(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    
    return {
      // 华北地区
      ChineseProvince.beijing: Offset(width * 0.65, height * 0.25),
      ChineseProvince.tianjin: Offset(width * 0.68, height * 0.28),
      ChineseProvince.hebei: Offset(width * 0.63, height * 0.30),
      ChineseProvince.shanxi: Offset(width * 0.58, height * 0.35),
      ChineseProvince.neimenggu: Offset(width * 0.60, height * 0.15),
      
      // 东北地区
      ChineseProvince.liaoning: Offset(width * 0.75, height * 0.25),
      ChineseProvince.jilin: Offset(width * 0.78, height * 0.18),
      ChineseProvince.heilongjiang: Offset(width * 0.80, height * 0.10),
      
      // 华东地区
      ChineseProvince.shanghai: Offset(width * 0.75, height * 0.55),
      ChineseProvince.jiangsu: Offset(width * 0.72, height * 0.52),
      ChineseProvince.zhejiang: Offset(width * 0.73, height * 0.60),
      ChineseProvince.anhui: Offset(width * 0.68, height * 0.55),
      ChineseProvince.fujian: Offset(width * 0.70, height * 0.70),
      ChineseProvince.jiangxi: Offset(width * 0.65, height * 0.65),
      ChineseProvince.shandong: Offset(width * 0.70, height * 0.40),
      
      // 华中地区
      ChineseProvince.henan: Offset(width * 0.60, height * 0.48),
      ChineseProvince.hubei: Offset(width * 0.58, height * 0.58),
      ChineseProvince.hunan: Offset(width * 0.55, height * 0.65),
      
      // 华南地区
      ChineseProvince.guangdong: Offset(width * 0.60, height * 0.80),
      ChineseProvince.guangxi: Offset(width * 0.52, height * 0.78),
      ChineseProvince.hainan: Offset(width * 0.55, height * 0.90),
      ChineseProvince.hongkong: Offset(width * 0.62, height * 0.85),
      ChineseProvince.macao: Offset(width * 0.60, height * 0.85),
      
      // 西南地区
      ChineseProvince.chongqing: Offset(width * 0.48, height * 0.60),
      ChineseProvince.sichuan: Offset(width * 0.40, height * 0.58),
      ChineseProvince.guizhou: Offset(width * 0.48, height * 0.68),
      ChineseProvince.yunnan: Offset(width * 0.38, height * 0.75),
      ChineseProvince.xizang: Offset(width * 0.20, height * 0.55),
      
      // 西北地区
      ChineseProvince.shaanxi: Offset(width * 0.52, height * 0.45),
      ChineseProvince.gansu: Offset(width * 0.40, height * 0.40),
      ChineseProvince.qinghai: Offset(width * 0.30, height * 0.45),
      ChineseProvince.ningxia: Offset(width * 0.48, height * 0.38),
      ChineseProvince.xinjiang: Offset(width * 0.15, height * 0.25),
      
      // 台湾
      ChineseProvince.taiwan: Offset(width * 0.80, height * 0.72),
    };
  }
}

/// 地图背景绘制器
class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // 绘制简化的中国轮廓
    final path = Path();
    
    // 这里绘制一个简化的中国地图轮廓
    path.moveTo(size.width * 0.1, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.1,
      size.width * 0.5, size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.1,
      size.width * 0.85, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.6,
      size.width * 0.7, size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.9,
      size.width * 0.3, size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.6,
      size.width * 0.1, size.height * 0.3,
    );
    
    canvas.drawPath(path, paint);
    
    // 绘制网格线
    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // 垂直线
    for (int i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    // 水平线
    for (int i = 1; i < 10; i++) {
      final y = size.height * i / 10;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
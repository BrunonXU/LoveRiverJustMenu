import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../domain/models/province_cuisine.dart';

/// 🗺️ 真正的中国地图可视化组件
class ChinaMapVisual extends StatefulWidget {
  final List<ProvinceCuisine> provinces;
  final ChineseProvince? selectedProvince;
  final Function(ChineseProvince) onProvinceSelected;

  const ChinaMapVisual({
    super.key,
    required this.provinces,
    this.selectedProvince,
    required this.onProvinceSelected,
  });

  @override
  State<ChinaMapVisual> createState() => _ChinaMapVisualState();
}

class _ChinaMapVisualState extends State<ChinaMapVisual>
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
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                // 中国地图轮廓背景
                CustomPaint(
                  painter: _ChinaMapPainter(),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
                
                // 省份标记点
                ..._buildProvinceMarkers(constraints),
                
                // 图例
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildLegend(),
                ),
                
                // 地图标题
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildMapTitle(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建省份标记点
  List<Widget> _buildProvinceMarkers(BoxConstraints constraints) {
    final markers = <Widget>[];
    
    for (final province in widget.provinces) {
      final position = _getProvincePosition(province.province, constraints);
      if (position != null) {
        markers.add(_buildProvinceMarker(province, position));
      }
    }
    
    return markers;
  }

  /// 构建单个省份标记
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
        width: isSelected ? 70 : 50,
        height: isSelected ? 70 : 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isUnlocked 
              ? LinearGradient(
                  colors: [
                    province.themeColor,
                    province.themeColor.withValues(alpha: 0.7),
                  ],
                )
              : null,
          color: isUnlocked 
              ? null 
              : isNearUnlock 
                  ? AppColors.emotionGradient.colors.first.withValues(alpha: 0.3)
                  : AppColors.backgroundSecondary,
          border: Border.all(
            color: isUnlocked 
                ? province.themeColor
                : isNearUnlock 
                    ? AppColors.emotionGradient.colors.first
                    : AppColors.textSecondary.withValues(alpha: 0.3),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (isUnlocked || isNearUnlock)
              BoxShadow(
                color: isUnlocked 
                    ? province.themeColor.withValues(alpha: 0.5)
                    : AppColors.emotionGradient.colors.first.withValues(alpha: 0.3),
                blurRadius: isSelected ? 16 : 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 省份图标
            Text(
              province.iconEmoji,
              style: TextStyle(
                fontSize: isSelected ? 24 : 18,
              ),
            ),
            
            // 进度环
            if (!isUnlocked)
              Positioned(
                right: -2,
                top: -2,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: province.unlockProgress,
                    strokeWidth: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isNearUnlock 
                          ? AppColors.emotionGradient.colors.first
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            
            // 完成标记
            if (isUnlocked)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ECB71),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
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
            offset: Offset(0, _floatController.value * 3 - 1.5),
            child: marker,
          );
        },
      );
    }
    
    return Positioned(
      left: position.dx - (isSelected ? 35 : 25),
      top: position.dy - (isSelected ? 35 : 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          marker,
          if (isSelected) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    province.provinceName,
                    style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${province.progressPercentage}%',
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      color: isUnlocked 
                          ? const Color(0xFF4ECB71)
                          : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建地图标题
  Widget _buildMapTitle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🇨🇳',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            '中华美食地图',
            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图例
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
            color: AppColors.textSecondary.withValues(alpha: 0.3),
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

  /// 获取省份在地图上的位置（相对坐标）
  Offset? _getProvincePosition(ChineseProvince province, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    
    // 🗺️ 真实的中国省份相对位置（基于地理坐标简化）
    final positions = <ChineseProvince, Offset>{
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
    
    return positions[province];
  }
}

/// 🗺️ 中国地图轮廓绘制器
class _ChinaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制中国地图轮廓
    _drawChinaOutline(canvas, size);
    
    // 绘制省界线（简化）
    _drawProvinceLines(canvas, size);
    
    // 绘制海岸线装饰
    _drawCoastline(canvas, size);
  }

  /// 绘制中国地图轮廓
  void _drawChinaOutline(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final fillPaint = Paint()
      ..color = AppColors.backgroundSecondary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    // 🗺️ 简化的中国地图轮廓路径
    final chinaPath = Path();
    
    // 东北角起点
    chinaPath.moveTo(size.width * 0.85, size.height * 0.08);
    
    // 东北边界
    chinaPath.quadraticBezierTo(
      size.width * 0.82, size.height * 0.15,
      size.width * 0.78, size.height * 0.20,
    );
    
    // 华北、华东海岸线
    chinaPath.quadraticBezierTo(
      size.width * 0.80, size.height * 0.35,
      size.width * 0.76, size.height * 0.50,
    );
    
    chinaPath.quadraticBezierTo(
      size.width * 0.78, size.height * 0.65,
      size.width * 0.74, size.height * 0.75,
    );
    
    // 华南海岸线
    chinaPath.quadraticBezierTo(
      size.width * 0.65, size.height * 0.85,
      size.width * 0.55, size.height * 0.88,
    );
    
    // 南疆边界
    chinaPath.quadraticBezierTo(
      size.width * 0.45, size.height * 0.82,
      size.width * 0.35, size.height * 0.78,
    );
    
    // 西南边界
    chinaPath.quadraticBezierTo(
      size.width * 0.25, size.height * 0.70,
      size.width * 0.18, size.height * 0.60,
    );
    
    // 西北边界
    chinaPath.quadraticBezierTo(
      size.width * 0.10, size.height * 0.45,
      size.width * 0.15, size.height * 0.30,
    );
    
    chinaPath.quadraticBezierTo(
      size.width * 0.25, size.height * 0.15,
      size.width * 0.40, size.height * 0.12,
    );
    
    // 北方边界
    chinaPath.quadraticBezierTo(
      size.width * 0.60, size.height * 0.08,
      size.width * 0.85, size.height * 0.08,
    );
    
    chinaPath.close();
    
    // 绘制填充和轮廓
    canvas.drawPath(chinaPath, fillPaint);
    canvas.drawPath(chinaPath, outlinePaint);
  }

  /// 绘制主要省界线
  void _drawProvinceLines(Canvas canvas, Size size) {
    final provincePaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // 主要分界线（简化）
    
    // 南北分界线（秦岭-淮河）
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.50),
      Offset(size.width * 0.75, size.height * 0.48),
      provincePaint,
    );
    
    // 东西分界线
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.15),
      Offset(size.width * 0.52, size.height * 0.85),
      provincePaint,
    );
    
    // 西部分界线
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.20),
      Offset(size.width * 0.28, size.height * 0.75),
      provincePaint,
    );
  }

  /// 绘制海岸线装饰
  void _drawCoastline(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // 简单的波浪线装饰东部海岸
    for (double y = size.height * 0.3; y < size.height * 0.8; y += 20) {
      final waveStart = Offset(size.width * 0.76, y);
      final waveEnd = Offset(size.width * 0.78, y + 10);
      
      canvas.drawLine(waveStart, waveEnd, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
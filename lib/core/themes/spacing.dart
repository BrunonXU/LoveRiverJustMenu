import 'package:flutter/material.dart';

/// 爱心食谱间距系统
/// 基于8px栅格系统，确保设计一致性
class AppSpacing {
  // ==================== 基础间距单位 ====================
  
  /// 基础单位 - 8px
  static const double baseUnit = 8.0;
  
  /// 紧密间距 - 4px（图标与文字）
  static const double xs = 4.0;
  
  /// 元素内间距 - 8px
  static const double sm = 8.0;
  
  /// 相关元素间距 - 16px
  static const double md = 16.0;
  
  /// 模块内间距 - 24px
  static const double lg = 24.0;
  
  /// 页面边距 - 48px（重要！）
  static const double xl = 48.0;
  
  /// 大模块间距 - 64px
  static const double xxl = 64.0;
  
  /// 超大间距 - 96px（特殊场景）
  static const double xxxl = 96.0;
  
  // ==================== 黄金比例应用 ====================
  
  /// 黄金比例常数
  static const double goldenRatio = 1.618;
  
  /// 基于黄金比例的间距
  static double goldenSpacing(double base) => base * goldenRatio;
  
  // ==================== 留白策略 ====================
  
  /// 顶部留白（状态栏 + 安全区域）
  static double topSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top + xl;
  }
  
  /// 底部留白
  static const double bottomSafeArea = xl;
  
  /// 底部导航留白
  static const double bottomWithNavigation = 80.0;
  
  /// 卡片内留白（必须≥内容区域30%）
  static const double cardPadding = xl; // 48px
  
  /// 卡片间距
  static const double cardMargin = lg; // 24px
  
  // ==================== 组件专用间距 ====================
  
  /// 按钮内边距
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg, // 24px
    vertical: md,   // 16px
  );
  
  /// 页面边距（标准）
  static const EdgeInsets pagePadding = EdgeInsets.all(xl); // 48px
  
  /// 页面边距（紧凑）
  static const EdgeInsets pageCompactPadding = EdgeInsets.all(lg); // 24px
  
  /// 卡片内边距（标准）
  static const EdgeInsets cardContentPadding = EdgeInsets.all(xl); // 48px
  
  /// 列表项内边距
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg, // 24px
    vertical: md,   // 16px
  );
  
  /// 输入框内边距
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md, // 16px
    vertical: sm,   // 8px
  );
  
  /// 图标与文字间距
  static const double iconTextSpacing = xs; // 4px
  
  /// 标题与内容间距
  static const double titleContentSpacing = md; // 16px
  
  /// 段落间距
  static const double paragraphSpacing = lg; // 24px
  
  // ==================== 圆角系统 ====================
  
  /// 小圆角 - 组件内元素
  static const double radiusSmall = 8.0;
  
  /// 中圆角 - 按钮等
  static const double radiusMedium = 16.0;
  
  /// 大圆角 - 卡片（重要！）
  static const double radiusLarge = 24.0;
  
  /// 超大圆角 - 特殊组件
  static const double radiusXLarge = 32.0;
  
  /// 圆形
  static const double radiusCircle = 999.0;
  
  // ==================== 阴影系统 ====================
  
  /// 卡片阴影偏移
  static const Offset shadowOffset = Offset(0, 8);
  
  /// 卡片阴影模糊半径
  static const double shadowBlurRadius = 32.0;
  
  /// 卡片阴影扩散半径
  static const double shadowSpreadRadius = 0.0;
  
  // ==================== 动画相关间距 ====================
  
  /// 呼吸动画缩放范围
  static const double breathingScale = 0.02; // 1.0 → 1.02
  
  /// 手势触发阈值
  static const double gestureThreshold = 50.0;
  
  /// 磁性吸附半径
  static const double magneticRadius = 150.0;
  
  // ==================== 响应式间距 ====================
  
  /// 获取响应式页面边距
  static EdgeInsets getResponsivePagePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      // 手机
      return pagePadding;
    } else if (screenWidth < 1200) {
      // 平板
      return EdgeInsets.all(xxl); // 64px
    } else {
      // 桌面
      return EdgeInsets.all(xxxl); // 96px
    }
  }
  
  /// 获取响应式卡片边距
  static double getResponsiveCardMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return cardMargin; // 24px
    } else {
      return lg * 2; // 48px
    }
  }
  
  // ==================== 工具方法 ====================
  
  /// 创建对称内边距
  static EdgeInsets symmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) => EdgeInsets.symmetric(
    horizontal: horizontal,
    vertical: vertical,
  );
  
  /// 创建自定义内边距
  static EdgeInsets only({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => EdgeInsets.only(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );
  
  /// 创建全方向相同内边距
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  
  /// 验证间距是否符合8px栅格
  static bool isValidSpacing(double spacing) {
    return spacing % baseUnit == 0;
  }
  
  /// 将任意数值调整为符合8px栅格的值
  static double normalizeSpacing(double spacing) {
    return (spacing / baseUnit).round() * baseUnit;
  }
  
  /// 创建SizedBox高度间距
  static SizedBox verticalSpace(double height) => SizedBox(height: height);
  
  /// 创建SizedBox宽度间距
  static SizedBox horizontalSpace(double width) => SizedBox(width: width);
  
  /// 创建Divider分割线
  static Divider divider({
    double height = sm,
    double thickness = 1.0,
    Color? color,
  }) => Divider(
    height: height,
    thickness: thickness,
    color: color,
  );
}

/// 间距常量 - 便于快速访问
class AppSpacingConstants {
  // 基础间距
  static const xs = AppSpacing.xs;      // 4px
  static const sm = AppSpacing.sm;      // 8px
  static const md = AppSpacing.md;      // 16px
  static const lg = AppSpacing.lg;      // 24px
  static const xl = AppSpacing.xl;      // 48px
  static const xxl = AppSpacing.xxl;    // 64px
  
  // 圆角
  static const radiusSmall = AppSpacing.radiusSmall;     // 8px
  static const radiusMedium = AppSpacing.radiusMedium;   // 16px
  static const radiusLarge = AppSpacing.radiusLarge;     // 24px
  static const radiusXLarge = AppSpacing.radiusXLarge;   // 32px
  
  // 常用内边距
  static const pagePadding = AppSpacing.pagePadding;
  static const cardPadding = AppSpacing.cardContentPadding;
  static const buttonPadding = AppSpacing.buttonPadding;
  static const listItemPadding = AppSpacing.listItemPadding;
}

/// 间距辅助类 - 提供便捷的间距组件
class Space {
  /// 垂直间距组件
  static const h4 = SizedBox(height: 4);
  static const h8 = SizedBox(height: 8);
  static const h16 = SizedBox(height: 16);
  static const h24 = SizedBox(height: 24);
  static const h32 = SizedBox(height: 32);
  static const h48 = SizedBox(height: 48);
  static const h64 = SizedBox(height: 64);
  
  /// 水平间距组件
  static const w4 = SizedBox(width: 4);
  static const w8 = SizedBox(width: 8);
  static const w16 = SizedBox(width: 16);
  static const w24 = SizedBox(width: 24);
  static const w48 = SizedBox(width: 48);
  static const w64 = SizedBox(width: 64);
  
  /// 自定义间距
  static Widget vertical(double height) => SizedBox(height: height);
  static Widget horizontal(double width) => SizedBox(width: width);
}
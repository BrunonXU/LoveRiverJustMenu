import 'package:flutter/material.dart';

/// 爱心食谱色彩系统
/// 严格遵循 95%黑白灰 + 5%彩色焦点 设计原则
class AppColors {
  // ==================== 基础色板（95%使用） ====================
  
  /// 纯白背景 - 主要背景色
  static const Color backgroundColor = Color(0xFFFFFFFF);
  
  /// 纯黑文字 - 主要文字颜色
  static const Color textPrimary = Color(0xFF000000);
  
  /// 高级灰背景 - 次要背景色
  static const Color backgroundSecondary = Color(0xFFF7F7F7);
  
  /// 中灰辅助文字 - 次要信息文字
  static const Color textSecondary = Color(0xFF999999);
  
  /// 浅灰分割线
  static const Color divider = Color(0xFFE0E0E0);
  
  /// 卡片阴影色
  static const Color shadow = Color(0x14000000); // 黑色8%透明度
  
  // ==================== 焦点渐变色（仅5%使用） ====================
  
  /// 主色调 - 蓝紫渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 情感色 - 橙粉渐变
  static const LinearGradient emotionGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 特殊态 - 紫粉渐变
  static const LinearGradient specialGradient = LinearGradient(
    colors: [Color(0xFFB794F6), Color(0xFFF687B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 主色调单色（用于边框等）
  static const Color primary = Color(0xFF5B6FED);
  static const Color primaryLight = Color(0xFF8B9BF3);
  
  // ==================== 语义色（极少使用） ====================
  
  /// 成功色
  static const Color success = Color(0xFF48BB78);
  
  /// 警告色
  static const Color warning = Color(0xFFED8936);
  
  /// 错误色
  static const Color error = Color(0xFFF56565);
  
  /// 信息色
  static const Color info = Color(0xFF74B9FF);
  
  // ==================== 深色模式适配 ====================
  
  /// 深色背景
  static const Color backgroundDark = Color(0xFF1A1A1A);
  
  /// 深色主文字
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  
  /// 深色次要背景
  static const Color backgroundSecondaryDark = Color(0xFF2D2D2D);
  
  /// 深色次要文字
  static const Color textSecondaryDark = Color(0xFF999999);
  
  /// 深色阴影
  static const Color shadowDark = Color(0x4D000000); // 黑色30%透明度
  
  // ==================== 时间感知背景色 ====================
  
  /// 早晨背景色 (6:00-12:00)
  static const Color morningBackground = Color(0xFFFFF5E6);
  
  /// 午后背景色 (12:00-17:00)
  static const Color afternoonBackground = Color(0xFFFFF8DC);
  
  /// 晚霞背景色 (17:00-22:00)
  static const Color eveningBackground = Color(0xFFFFE4E1);
  
  /// 夜空背景色 (22:00-6:00)
  static const Color nightBackground = Color(0xFF191970);
  
  // ==================== 工具方法 ====================
  
  /// 获取当前时段的背景色
  static Color getTimeBasedBackground() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return morningBackground;
    if (hour >= 12 && hour < 17) return afternoonBackground;
    if (hour >= 17 && hour < 22) return eveningBackground;
    return nightBackground;
  }
  
  /// 创建自定义渐变
  static LinearGradient customGradient(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  /// 获取阴影颜色（根据主题模式）
  static Color getShadowColor(bool isDark) {
    return isDark ? shadowDark : shadow;
  }
  
  /// 获取背景色（根据主题模式）
  static Color getBackgroundColor(bool isDark) {
    return isDark ? backgroundDark : backgroundColor;
  }
  
  /// 获取主文字色（根据主题模式）
  static Color getTextPrimaryColor(bool isDark) {
    return isDark ? textPrimaryDark : textPrimary;
  }
  
  /// 获取次要文字色（根据主题模式）
  static Color getTextSecondaryColor(bool isDark) {
    return isDark ? textSecondaryDark : textSecondary;
  }
}

/// 颜色常量 - 便于快速访问
class AppColorConstants {
  // 基础色
  static const white = AppColors.backgroundColor;
  static const black = AppColors.textPrimary;
  static const grey = AppColors.textSecondary;
  static const lightGrey = AppColors.backgroundSecondary;
  
  // 主色
  static const primary = AppColors.primary;
  static const primaryLight = AppColors.primaryLight;
  
  // 语义色
  static const success = AppColors.success;
  static const warning = AppColors.warning;
  static const error = AppColors.error;
  static const info = AppColors.info;
}
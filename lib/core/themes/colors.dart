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
  
  /// 早晨背景色 (6:00-12:00) - 温暖晨光
  static const Color morningBackground = Color(0xFFFFF9F0);
  
  /// 午后背景色 (12:00-17:00) - 明亮午阳
  static const Color afternoonBackground = Color(0xFFFFFAF5);
  
  /// 晚霞背景色 (17:00-22:00) - 浪漫晚霞
  static const Color eveningBackground = Color(0xFFFFF0F5);
  
  /// 夜空背景色 (22:00-6:00) - 深邃夜空
  static const Color nightBackground = Color(0xFFF8F8FA);
  
  // ==================== 时间渐变色 ====================
  
  /// 早晨渐变 - 金色黎明
  static const LinearGradient morningGradient = LinearGradient(
    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// 午后渐变 - 暖阳午后
  static const LinearGradient afternoonGradient = LinearGradient(
    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// 晚霞渐变 - 粉紫晚霞
  static const LinearGradient eveningGradient = LinearGradient(
    colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// 夜空渐变 - 宁静夜空
  static const LinearGradient nightGradient = LinearGradient(
    colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ==================== 工具方法 ====================
  
  /// 获取当前时段的背景色
  static Color getTimeBasedBackground() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return morningBackground;
    if (hour >= 12 && hour < 17) return afternoonBackground;
    if (hour >= 17 && hour < 22) return eveningBackground;
    return nightBackground;
  }
  
  /// 获取当前时段的背景渐变
  static LinearGradient getTimeBasedGradient() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return morningGradient;
    if (hour >= 12 && hour < 17) return afternoonGradient;
    if (hour >= 17 && hour < 22) return eveningGradient;
    return nightGradient;
  }
  
  /// 获取当前时段名称
  static String getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 22) return 'evening';
    return 'night';
  }
  
  /// 获取时段对应的主题色
  static Color getTimeBasedAccent() {
    final timeOfDay = getTimeOfDay();
    switch (timeOfDay) {
      case 'morning':
        return const Color(0xFFFFB74D); // 金色
      case 'afternoon':
        return const Color(0xFFFF8A65); // 橙色
      case 'evening':
        return const Color(0xFFAD7BE9); // 紫色
      case 'night':
        return const Color(0xFF7986CB); // 靛蓝色
      default:
        return primary;
    }
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
  
  /// 获取次要背景色（根据主题模式）
  static Color getBackgroundSecondaryColor(bool isDark) {
    return isDark ? backgroundSecondaryDark : backgroundSecondary;
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
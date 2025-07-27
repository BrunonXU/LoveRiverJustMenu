import 'package:flutter/material.dart';
import 'colors.dart';

/// 爱心食谱字体系统
/// 严格遵循设计规范：100/300/500 字重，禁用粗体
class AppTypography {
  // ==================== 字体家族 ====================
  
  /// iOS系统字体：苹方-简 (PingFang SC)
  static const String fontFamilyiOS = 'PingFang SC';
  
  /// Android系统字体：思源黑体 (Source Han Sans)
  static const String fontFamilyAndroid = 'Source Han Sans';
  
  /// 英文字体：Inter
  static const String fontFamilyEnglish = 'Inter';
  
  // ==================== 字重规范 ====================
  
  /// 超轻 - 仅用于超大展示标题（48px+）
  static const FontWeight ultralight = FontWeight.w100;
  
  /// 轻 - 主要内容文字
  static const FontWeight light = FontWeight.w300;
  
  /// 中等 - 强调文字、按钮
  static const FontWeight medium = FontWeight.w500;
  
  // 禁用粗体 FontWeight.w700 - 破坏简洁感
  
  // ==================== 字号体系 ====================
  
  /// 超大显示 - 时间显示
  static const double displayLarge = 48.0;
  
  /// 页面标题
  static const double titleLarge = 32.0;
  
  /// 卡片标题
  static const double titleMedium = 24.0;
  
  /// 重要信息
  static const double bodyLarge = 18.0;
  
  /// 正文内容 - 基准字号
  static const double bodyMedium = 16.0;
  
  /// 辅助信息
  static const double bodySmall = 14.0;
  
  /// 标签时间戳 - 最小字号
  static const double caption = 12.0;
  
  // ==================== 排版规则 ====================
  
  /// 行高
  static const double lineHeight = 1.6;
  
  /// 字间距
  static const double letterSpacing = 0.02;
  
  /// 段间距倍数
  static const double paragraphSpacing = 1.5;
  
  // ==================== 文本样式定义 ====================
  
  /// 时间显示样式 - 48px 超轻
  static TextStyle displayLargeStyle({bool isDark = false}) => TextStyle(
    fontSize: displayLarge,
    fontWeight: ultralight,
    color: AppColors.getTextPrimaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 页面标题样式 - 32px 中等
  static TextStyle titleLargeStyle({bool isDark = false}) => TextStyle(
    fontSize: titleLarge,
    fontWeight: medium,
    color: AppColors.getTextPrimaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 卡片标题样式 - 24px 中等
  static TextStyle titleMediumStyle({bool isDark = false}) => TextStyle(
    fontSize: titleMedium,
    fontWeight: medium,
    color: AppColors.getTextPrimaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 重要信息样式 - 18px 轻
  static TextStyle bodyLargeStyle({bool isDark = false}) => TextStyle(
    fontSize: bodyLarge,
    fontWeight: light,
    color: AppColors.getTextPrimaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 正文内容样式 - 16px 轻
  static TextStyle bodyMediumStyle({bool isDark = false}) => TextStyle(
    fontSize: bodyMedium,
    fontWeight: light,
    color: AppColors.getTextPrimaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 辅助信息样式 - 14px 轻
  static TextStyle bodySmallStyle({bool isDark = false}) => TextStyle(
    fontSize: bodySmall,
    fontWeight: light,
    color: AppColors.getTextSecondaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 标签样式 - 12px 轻
  static TextStyle captionStyle({bool isDark = false}) => TextStyle(
    fontSize: caption,
    fontWeight: light,
    color: AppColors.getTextSecondaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  // ==================== 特殊样式 ====================
  
  /// 按钮文字样式 - 18px 中等
  static TextStyle buttonStyle({bool isDark = false}) => TextStyle(
    fontSize: bodyLarge,
    fontWeight: medium,
    color: Colors.white,
    letterSpacing: letterSpacing,
    height: 1.0, // 按钮内文字紧凑
    fontFamily: fontFamilyiOS,
  );
  
  /// 问候语样式 - 28px 轻
  static TextStyle greetingStyle({bool isDark = false}) => TextStyle(
    fontSize: 28.0,
    fontWeight: light,
    color: AppColors.getTextPrimaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 时间标签样式 - 18px 次要色
  static TextStyle timeStyle({bool isDark = false}) => TextStyle(
    fontSize: bodyLarge,
    fontWeight: light,
    color: AppColors.getTextSecondaryColor(isDark),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 导航提示样式 - 12px 透明
  static TextStyle hintStyle({bool isDark = false}) => TextStyle(
    fontSize: caption,
    fontWeight: light,
    color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.6),
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  // ==================== 工具方法 ====================
  
  /// 创建自定义文本样式
  static TextStyle customStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    bool isDark = false,
    double? letterSpacing,
    double? height,
  }) => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight ?? light,
    color: color ?? AppColors.getTextPrimaryColor(isDark),
    letterSpacing: letterSpacing ?? AppTypography.letterSpacing,
    height: height ?? lineHeight,
    fontFamily: fontFamilyiOS,
  );
  
  /// 获取TextTheme配置
  static TextTheme getTextTheme({bool isDark = false}) => TextTheme(
    displayLarge: displayLargeStyle(isDark: isDark),
    titleLarge: titleLargeStyle(isDark: isDark),
    titleMedium: titleMediumStyle(isDark: isDark),
    bodyLarge: bodyLargeStyle(isDark: isDark),
    bodyMedium: bodyMediumStyle(isDark: isDark),
    bodySmall: bodySmallStyle(isDark: isDark),
    labelSmall: captionStyle(isDark: isDark),
  );
  
  /// 检查字重是否符合规范
  static bool isValidFontWeight(FontWeight weight) {
    return [ultralight, light, medium].contains(weight);
  }
}

/// 文本样式常量 - 便于快速访问
class AppTextStyles {
  // 标题样式
  static final display = AppTypography.displayLargeStyle();
  static final titleLarge = AppTypography.titleLargeStyle();
  static final titleMedium = AppTypography.titleMediumStyle();
  
  // 正文样式
  static final bodyLarge = AppTypography.bodyLargeStyle();
  static final bodyMedium = AppTypography.bodyMediumStyle();
  static final bodySmall = AppTypography.bodySmallStyle();
  static final caption = AppTypography.captionStyle();
  
  // 特殊样式
  static final button = AppTypography.buttonStyle();
  static final greeting = AppTypography.greetingStyle();
  static final time = AppTypography.timeStyle();
  static final hint = AppTypography.hintStyle();
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// 爱心食谱应用主题
/// 整合色彩、字体、间距系统，严格遵循极简设计原则
class AppTheme {
  // ==================== 主题配置 ====================
  
  /// 浅色主题
  static ThemeData get lightTheme => _buildTheme(isDark: false);
  
  /// 深色主题
  static ThemeData get darkTheme => _buildTheme(isDark: true);
  
  // ==================== 主题构建 ====================
  
  static ThemeData _buildTheme({required bool isDark}) {
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    
    return ThemeData(
      // 基础配置
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      
      // 字体配置
      fontFamily: AppTypography.fontFamilyiOS,
      textTheme: AppTypography.getTextTheme(isDark: isDark),
      
      // 主色调
      primarySwatch: _createMaterialColor(AppColors.primary),
      
      // 背景色
      scaffoldBackgroundColor: AppColors.getBackgroundColor(isDark),
      
      // AppBar主题 - 极简透明
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: AppColors.getBackgroundColor(isDark),
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        titleTextStyle: AppTypography.titleLargeStyle(isDark: isDark),
        iconTheme: IconThemeData(
          color: AppColors.getTextPrimaryColor(isDark),
          size: 24,
        ),
      ),
      
      // 卡片主题 - 极简设计
      cardTheme: CardThemeData(
        color: AppColors.getBackgroundColor(isDark),
        elevation: 0,
        shadowColor: AppColors.getShadowColor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        margin: AppSpacing.all(AppSpacing.cardMargin),
      ),
      
      // 按钮主题 - 禁用Material默认样式
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.buttonStyle(isDark: isDark),
          minimumSize: const Size(88, 56), // 符合无障碍标准
        ),
      ),
      
      // 禁用OutlinedButton和TextButton的默认样式
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.buttonStyle(isDark: isDark).copyWith(
            color: AppColors.primary,
          ),
          minimumSize: const Size(88, 56),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: AppSpacing.inputPadding,
        labelStyle: AppTypography.bodyMediumStyle(isDark: isDark),
        hintStyle: AppTypography.bodySmallStyle(isDark: isDark),
      ),
      
      // 图标主题
      iconTheme: IconThemeData(
        color: AppColors.getTextPrimaryColor(isDark),
        size: 24,
      ),
      
      // 分割线主题
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.sm,
      ),
      
      // 底部导航栏主题 - 极简设计
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.getBackgroundColor(isDark),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.getTextSecondaryColor(isDark),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.captionStyle(isDark: isDark),
        unselectedLabelStyle: AppTypography.captionStyle(isDark: isDark),
      ),
      
      // FloatingActionButton主题 - 自定义样式
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.textPrimary, // 纯黑
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        shape: const CircleBorder(),
        sizeConstraints: const BoxConstraints(
          minWidth: 56,
          minHeight: 56,
          maxWidth: 56,
          maxHeight: 56,
        ),
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.getBackgroundColor(isDark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        titleTextStyle: AppTypography.titleMediumStyle(isDark: isDark),
        contentTextStyle: AppTypography.bodyMediumStyle(isDark: isDark),
      ),
      
      // 禁用Splash效果 - 保持极简
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      // 页面过渡动画
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      
      // 滚动条主题
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(
          AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
        ),
        trackColor: MaterialStateProperty.all(Colors.transparent),
        radius: const Radius.circular(AppSpacing.radiusSmall),
        thickness: MaterialStateProperty.all(4),
        minThumbLength: 48,
      ),
    );
  }
  
  // ==================== 颜色方案 ====================
  
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryLight,
    secondary: AppColors.primary,
    background: AppColors.backgroundColor,
    surface: AppColors.backgroundColor,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
  );
  
  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    primaryContainer: AppColors.primary,
    secondary: AppColors.primaryLight,
    background: AppColors.backgroundDark,
    surface: AppColors.backgroundSecondaryDark,
    error: AppColors.error,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onBackground: AppColors.textPrimaryDark,
    onSurface: AppColors.textPrimaryDark,
    onError: Colors.white,
  );
  
  // ==================== 工具方法 ====================
  
  /// 创建MaterialColor
  static MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
  
  /// 获取卡片装饰
  static BoxDecoration getCardDecoration({bool isDark = false}) {
    return BoxDecoration(
      color: AppColors.getBackgroundColor(isDark),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      boxShadow: [
        BoxShadow(
          color: AppColors.getShadowColor(isDark),
          blurRadius: AppSpacing.shadowBlurRadius,
          offset: AppSpacing.shadowOffset,
          spreadRadius: AppSpacing.shadowSpreadRadius,
        ),
      ],
    );
  }
  
  /// 获取渐变装饰
  static BoxDecoration getGradientDecoration({
    required Gradient gradient,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge),
    );
  }
  
  /// 获取系统UI样式
  static SystemUiOverlayStyle getSystemUiOverlayStyle({bool isDark = false}) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.getBackgroundColor(isDark),
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }
}

/// 主题扩展 - 提供自定义主题属性
extension AppThemeExtension on ThemeData {
  /// 是否为深色主题
  bool get isDark => brightness == Brightness.dark;
  
  /// 获取卡片装饰
  BoxDecoration get cardDecoration => AppTheme.getCardDecoration(isDark: isDark);
  
  /// 获取主色渐变
  LinearGradient get primaryGradient => AppColors.primaryGradient;
  
  /// 获取情感色渐变
  LinearGradient get emotionGradient => AppColors.emotionGradient;
}
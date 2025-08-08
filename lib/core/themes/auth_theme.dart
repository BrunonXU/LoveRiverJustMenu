/// 🎮 登录认证页面专用设计系统
/// 
/// 星露谷像素风格 + 极简设计原则
/// 只适用于登录相关页面（欢迎页、登录页、注册页、游客页）
/// 
/// 作者: Claude Code
/// 创建时间: 2025-08-08

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 登录认证页面专用颜色系统
class AuthColors {
  // ==================== 星露谷像素风色彩 ====================
  
  /// 奶茶色系背景渐变 - 温暖舒适
  static const LinearGradient pixelBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAF7F0), // 温暖白色
      Color(0xFFF0EBE3), // 奶茶色
      Color(0xFFE6D7C3), // 浅咖啡色
    ],
  );
  
  /// 主要文字色 - 深森林绿
  static const Color pixelTextPrimary = Color(0xFF2D4A3E);
  
  /// 标题文字色 - 中森林绿  
  static const Color pixelTextTitle = Color(0xFF4A6B3A);
  
  /// 描述文字色 - 棕褐色
  static const Color pixelTextDescription = Color(0xFF6B4423);
  
  /// 次要文字色 - 暖灰棕
  static const Color pixelTextSecondary = Color(0xFF9B8B7A);
  
  /// 边框色 - 与描述文字同色
  static const Color pixelBorder = Color(0xFF6B4423);
  
  /// 分割线色 - 浅奶茶色
  static const Color pixelDivider = Color(0xFFE6D7C3);
  
  /// 按钮主色 - 深森林绿
  static const Color pixelButtonPrimary = Color(0xFF2D4A3E);
  
  /// 按钮次要色 - 中森林绿
  static const Color pixelButtonSecondary = Color(0xFF4A6B3A);
  
  /// Logo阴影色 - 金褐色
  static const Color pixelLogoShadow = Color(0xFFD4B678);
}

/// 登录认证页面专用字体系统
class AuthTypography {
  // ==================== 像素风字体配置 ====================
  
  /// 像素风字体 - Press Start 2P
  static String get pixelFont => 'Press Start 2P';
  
  /// 获取像素风文字样式
  static TextStyle pixelStyle({
    required double fontSize,
    required Color color,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.pressStart2p(
    fontSize: fontSize,
    color: color,
    letterSpacing: letterSpacing ?? 1.0,
    height: height ?? 1.5,
  );
  
  // ==================== 预定义样式 ====================
  
  /// 大标题 - 28px LRJ
  static TextStyle get logoLarge => pixelStyle(
    fontSize: 28,
    color: AuthColors.pixelTextPrimary,
    letterSpacing: 2.0,
  );
  
  /// 副标题 - 12px LOVE-RECIPE JOURNAL  
  static TextStyle get logoSubtitle => pixelStyle(
    fontSize: 12,
    color: AuthColors.pixelTextTitle,
    letterSpacing: 1.0,
  );
  
  /// 描述文字 - 10px 中文描述
  static TextStyle get description => pixelStyle(
    fontSize: 10,
    color: AuthColors.pixelTextDescription,
    letterSpacing: 1.0,
    height: 1.5,
  );
  
  /// 页面标题 - 14px 开始你们的美食之旅
  static TextStyle get pageTitle => pixelStyle(
    fontSize: 14,
    color: AuthColors.pixelTextPrimary,
    letterSpacing: 1.0,
  );
  
  /// 按钮文字 - 10px 按钮标签
  static TextStyle get buttonText => pixelStyle(
    fontSize: 10,
    color: Colors.white,
    letterSpacing: 1.0,
  );
  
  /// 按钮文字次要 - 10px 游客体验
  static TextStyle get buttonTextSecondary => pixelStyle(
    fontSize: 10,
    color: AuthColors.pixelTextDescription,
    letterSpacing: 1.0,
  );
  
  /// 版权信息 - 8px 最小文字
  static TextStyle get copyright => pixelStyle(
    fontSize: 8,
    color: AuthColors.pixelTextSecondary,
    letterSpacing: 0.5,
  );
  
  /// 页面标题（非首页） - 20px 游客体验等
  static TextStyle get screenTitle => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  
  /// 特性说明 - 16px 功能介绍
  static TextStyle get featureText => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: Colors.black,
  );
  
  /// 特性标题 - 16px 粗体
  static TextStyle get featureTitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  
  /// 普通描述 - 16px 介绍文字
  static TextStyle get normalDescription => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: Color(0xFF666666),
    height: 1.5,
  );
  
  /// 副标题 - 24px 免注册体验
  static TextStyle get subtitle => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w300,
    color: Colors.black,
    letterSpacing: 0.5,
  );
  
  /// 小提示 - 14px 链接文字
  static TextStyle get smallHint => TextStyle(
    fontSize: 14,
    color: Color(0xFF999999),
  );
  
  /// 链接文字 - 14px 蓝色链接
  static TextStyle get linkText => TextStyle(
    fontSize: 14,
    color: Color(0xFF5B6FED),
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );
}

/// 登录认证页面专用布局系统
class AuthLayout {
  // ==================== 响应式布局常量 ====================
  
  /// Logo尺寸 - 160px
  static const double logoSize = 160.0;
  
  /// 按钮固定宽度 - 200px （需要改为响应式）
  static const double buttonWidth = 200.0;
  
  /// 按钮高度 - 44px
  static const double buttonHeight = 44.0;
  
  /// 页面水平边距 - 32px （需要响应式）
  static const double pageHorizontalPadding = 32.0;
  
  /// 页面垂直边距 - 24px
  static const double pageVerticalPadding = 24.0;
  
  /// 元素间距 - 基础间距体系
  static const double spacing_xs = 8.0;   // 小间距
  static const double spacing_sm = 16.0;  // 标准间距
  static const double spacing_md = 24.0;  // 中等间距
  static const double spacing_lg = 32.0;  // 大间距
  static const double spacing_xl = 48.0;  // 超大间距
  
  // ==================== 响应式布局方法 ====================
  
  /// 获取响应式页面边距
  static EdgeInsets getResponsivePagePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 400) {
      // 小屏手机
      return EdgeInsets.symmetric(horizontal: 16, vertical: pageVerticalPadding);
    } else if (screenWidth < 600) {
      // 标准手机
      return EdgeInsets.symmetric(horizontal: pageHorizontalPadding, vertical: pageVerticalPadding);
    } else if (screenWidth < 900) {
      // 大屏手机/小平板
      return EdgeInsets.symmetric(horizontal: 48, vertical: pageVerticalPadding);
    } else {
      // 平板/桌面
      return EdgeInsets.symmetric(horizontal: 64, vertical: pageVerticalPadding);
    }
  }
  
  /// 获取响应式按钮宽度
  static double getResponsiveButtonWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 400) {
      // 小屏手机 - 80% 宽度
      return screenWidth * 0.8;
    } else if (screenWidth < 600) {
      // 标准手机 - 固定240px
      return 240.0;
    } else {
      // 大屏设备 - 固定280px
      return 280.0;
    }
  }
  
  /// 获取响应式Logo尺寸
  static double getResponsiveLogoSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 基于屏幕高度调整Logo尺寸
    if (screenHeight < 600) {
      return 120.0; // 小屏设备
    } else if (screenHeight < 800) {
      return logoSize; // 标准设备 160px
    } else {
      return 200.0; // 大屏设备
    }
  }
  
  /// 获取页面内容的最小高度（确保居中显示）
  static double getContentMinHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    // 减去安全区域和页面边距
    return screenHeight - safeAreaTop - safeAreaBottom - (pageVerticalPadding * 2);
  }
}

/// 登录认证页面专用组件样式
class AuthStyles {
  // ==================== 容器装饰样式 ====================
  
  /// 像素按钮装饰（主要按钮）
  static BoxDecoration get pixelButtonPrimary => BoxDecoration(
    color: AuthColors.pixelButtonPrimary,
    border: Border.all(
      color: AuthColors.pixelButtonPrimary,
      width: 2,
    ),
  );
  
  /// 像素按钮装饰（次要按钮）
  static BoxDecoration get pixelButtonSecondary => BoxDecoration(
    color: Colors.transparent,
    border: Border.all(
      color: AuthColors.pixelButtonSecondary,
      width: 2,
    ),
  );
  
  /// 游客体验按钮装饰
  static BoxDecoration get guestButton => BoxDecoration(
    border: Border.all(
      color: AuthColors.pixelBorder,
      width: 1,
    ),
    color: Colors.transparent,
  );
  
  /// 卡片装饰 - 白色卡片
  static BoxDecoration get whiteCard => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  );
  
  /// 警告卡片装饰 - 黄色背景
  static BoxDecoration get warningCard => BoxDecoration(
    color: Color(0xFFFFF8DC),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Color(0xFFFFE66D).withOpacity(0.3),
      width: 1,
    ),
  );
  
  /// 页面背景装饰
  static BoxDecoration get pageBackground => BoxDecoration(
    gradient: AuthColors.pixelBackgroundGradient,
  );
  
  /// 返回按钮装饰
  static BoxDecoration get backButton => BoxDecoration(
    color: Color(0xFFF7F7F7),
    borderRadius: BorderRadius.circular(20),
  );
}

/// 登录认证页面专用动画常量
class AuthAnimations {
  // ==================== 动画时长 ====================
  
  /// 页面淡入动画时长
  static const Duration fadeInDuration = Duration(milliseconds: 800);
  
  /// 页面切换动画时长
  static const Duration transitionDuration = Duration(milliseconds: 300);
  
  /// 按钮点击动画时长
  static const Duration buttonTapDuration = Duration(milliseconds: 150);
  
  /// Logo呼吸动画时长
  static const Duration breathingDuration = Duration(seconds: 4);
  
  // ==================== 动画曲线 ====================
  
  /// 淡入曲线
  static const Curve fadeInCurve = Curves.easeOut;
  
  /// 切换曲线
  static const Curve transitionCurve = Curves.easeInOut;
  
  /// 呼吸曲线
  static const Curve breathingCurve = Curves.easeInOut;
}
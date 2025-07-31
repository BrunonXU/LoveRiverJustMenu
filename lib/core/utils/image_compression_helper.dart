import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
// 条件导入，Web端使用dart:html
import 'dart:html' as html if (dart.library.io) 'dart:io';

/// 📷 图片压缩工具类 - 专为Firestore免费版优化
/// 
/// 解决Firebase Storage需要会员的问题
/// 将图片压缩到100KB以下，适合Firestore存储
class ImageCompressionHelper {
  
  /// 🎯 目标压缩大小（KB）
  static const int targetSizeKB = 100;
  static const int maxSizeBytes = targetSizeKB * 1024;
  
  /// 📷 压缩图片到指定大小
  /// 
  /// [base64Image] 原始base64图片
  /// [maxSizeKB] 最大大小（KB），默认100KB
  /// 返回压缩后的base64图片
  static Future<String?> compressImage(
    String base64Image, {
    int maxSizeKB = targetSizeKB,
  }) async {
    if (!kIsWeb) {
      // 移动端暂时返回原图（后续可以实现）
      debugPrint('📱 移动端图片压缩暂未实现');
      return base64Image;
    }
    
    try {
      debugPrint('🚀 开始压缩图片，目标大小: ${maxSizeKB}KB');
      
      // 1. 解析原始图片
      final originalSize = _getBase64Size(base64Image);
      debugPrint('📏 原始图片大小: ${originalSize.toStringAsFixed(1)}KB');
      
      if (originalSize <= maxSizeKB) {
        debugPrint('✅ 图片已符合大小要求，无需压缩');
        return base64Image;
      }
      
      // 2. Web端压缩
      final compressedBase64 = await _compressImageWeb(base64Image, maxSizeKB);
      
      if (compressedBase64 != null) {
        final compressedSize = _getBase64Size(compressedBase64);
        debugPrint('✅ 压缩完成: ${originalSize.toStringAsFixed(1)}KB → ${compressedSize.toStringAsFixed(1)}KB');
        return compressedBase64;
      } else {
        debugPrint('❌ 压缩失败，返回原图');
        return base64Image;
      }
      
    } catch (e) {
      debugPrint('❌ 图片压缩异常: $e');
      return base64Image; // 失败时返回原图
    }
  }
  
  /// 🌐 Web端图片压缩实现
  static Future<String?> _compressImageWeb(String base64Image, int maxSizeKB) async {
    if (!kIsWeb) return null;
    
    try {
      // 创建Canvas进行图片处理
      final canvas = html.CanvasElement();
      final ctx = canvas.getContext('2d') as html.CanvasRenderingContext2D;
      
      // 创建Image元素
      final img = html.ImageElement();
      
      // 等待图片加载
      await _loadImage(img, base64Image);
      
      // 计算压缩比例
      final originalSize = _getBase64Size(base64Image);
      final compressionRatio = (maxSizeKB / originalSize).clamp(0.1, 1.0);
      
      // 计算新尺寸
      final newWidth = (img.width! * sqrt(compressionRatio)).round();
      final newHeight = (img.height! * sqrt(compressionRatio)).round();
      
      debugPrint('🔄 压缩尺寸: ${img.width}x${img.height} → ${newWidth}x${newHeight}');
      
      // 设置Canvas尺寸
      canvas.width = newWidth;
      canvas.height = newHeight;
      
      // 绘制压缩后的图片
      ctx.drawImageScaled(img, 0, 0, newWidth, newHeight);
      
      // 转换为base64
      String? compressedBase64;
      
      // 尝试不同质量等级
      for (double quality = 0.8; quality > 0.1; quality -= 0.1) {
        compressedBase64 = canvas.toDataUrl('image/jpeg', quality);
        final size = _getBase64Size(compressedBase64);
        
        debugPrint('🎯 质量${(quality*100).toInt()}%: ${size.toStringAsFixed(1)}KB');
        
        if (size <= maxSizeKB) {
          break;
        }
      }
      
      return compressedBase64;
      
    } catch (e) {
      debugPrint('❌ Web端压缩失败: $e');
      return null;
    }
  }
  
  /// 📥 加载图片
  static Future<void> _loadImage(html.ImageElement img, String base64Image) async {
    final completer = Completer<void>();
    
    img.onLoad.listen((_) => completer.complete());
    img.onError.listen((e) => completer.completeError('图片加载失败'));
    
    img.src = base64Image;
    
    return completer.future;
  }
  
  /// 📏 获取base64图片大小（KB）
  static double _getBase64Size(String base64String) {
    if (base64String.isEmpty) return 0.0;
    
    // 移除data URL前缀
    String cleanBase64 = base64String;
    if (base64String.startsWith('data:image/')) {
      final commaIndex = base64String.indexOf(',');
      if (commaIndex != -1) {
        cleanBase64 = base64String.substring(commaIndex + 1);
      }
    }
    
    // Base64编码大约增加33%的大小
    final originalSize = (cleanBase64.length * 3) / 4;
    return originalSize / 1024; // 转换为KB
  }
  
  /// 🔍 检查图片是否符合Firestore限制
  static bool isFirestoreCompatible(String base64Image) {
    final sizeKB = _getBase64Size(base64Image);
    return sizeKB <= targetSizeKB;
  }
  
  /// 📊 获取压缩统计信息
  static Map<String, dynamic> getCompressionStats(String originalBase64, String compressedBase64) {
    final originalSize = _getBase64Size(originalBase64);
    final compressedSize = _getBase64Size(compressedBase64);
    final ratio = compressedSize / originalSize;
    final savings = originalSize - compressedSize;
    
    return {
      'originalSizeKB': originalSize,
      'compressedSizeKB': compressedSize,
      'compressionRatio': ratio,
      'savingsKB': savings,
      'savingsPercent': (1 - ratio) * 100,
      'firestoreCompatible': isFirestoreCompatible(compressedBase64),
    };
  }
}
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// 条件导入，Web端使用dart:html，移动端跳过
import 'dart:html' as html if (dart.library.io) 'dart:io';

/// 📷 Base64图片处理工具类 - 分平台实现
/// Web端：真实文件上传，移动端：占位符（待实现）
class ImageBase64Helper {
  
  /// 📱 从图库/电脑选择图片并转换为Base64
  static Future<String?> pickImageFromGallery() async {
    if (kIsWeb) {
      // 🌐 Web端：真实文件上传
      return await _pickImageFromWebFile();
    } else {
      // 📱 移动端：占位符（等待后续集成image_picker）
      return await _generateMobilePlaceholder();
    }
  }
  
  /// 📷 拍照并转换为Base64
  static Future<String?> pickImageFromCamera() async {
    if (kIsWeb) {
      // 🌐 Web端：不支持拍照，重定向到文件选择
      return null; // 返回null表示不支持
    } else {
      // 📱 移动端：占位符（等待后续实现）
      return await _generateMobilePlaceholder();
    }
  }
  
  /// 🌐 Web端：真实文件选择和上传
  static Future<String?> _pickImageFromWebFile() async {
    if (!kIsWeb) return null;
    
    try {
      // 创建文件选择器
      final html.FileUploadInputElement input = html.FileUploadInputElement()
        ..accept = 'image/*' // 只接受图片文件
        ..multiple = false;  // 单选
      
      // 触发文件选择对话框
      input.click();
      
      // 等待用户选择文件
      await input.onChange.first;
      
      if (input.files?.isNotEmpty == true) {
        final html.File file = input.files!.first;
        
        // 检查文件大小（限制50MB - 支持现代手机拍照）
        if (file.size > 50 * 1024 * 1024) {
          print('❌ 图片文件过大，请选择小于50MB的图片');
          print('ℹ️ 建议：现代手机照片通常10-20MB，我们的智能压缩会自动优化');
          return null;
        }
        
        // 检查文件类型
        if (!file.type.startsWith('image/')) {
          print('❌ 请选择图片文件');
          return null;
        }
        
        // 读取文件内容
        final html.FileReader reader = html.FileReader();
        reader.readAsDataUrl(file);
        
        // 等待读取完成
        await reader.onLoad.first;
        
        final String? dataUrl = reader.result as String?;
        if (dataUrl != null) {
          print('✅ Web端图片上传成功: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)');
          return dataUrl; // 直接返回data URL格式的Base64
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Web端图片选择失败: $e');
      return null;
    }
  }
  
  /// 📱 移动端：占位符数据（等待后续实现）
  static Future<String?> _generateMobilePlaceholder() async {
    // 生成不同颜色的占位符图片
    final List<String> placeholderImages = [
      // 深蓝色方块 - 移动端占位符标识
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYGBgAAAABQABXvOqCwAAAABJRU5ErkJggg==',
      // 深绿色方块
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGA4GbIyQAAAABJRU5ErkJggg==',
      // 深红色方块
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==',
    ];
    
    // 模拟异步操作
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 随机选择占位符
    final randomIndex = DateTime.now().millisecond % placeholderImages.length;
    print('📱 移动端占位符图片生成（等待真实实现）');
    return placeholderImages[randomIndex];
  }
  
  /// 🖼️ 从Base64字符串解码为Uint8List（用于显示图片）
  static Uint8List? decodeBase64ToBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    
    try {
      // 移除数据URL前缀（如果存在）
      String cleanBase64 = base64String;
      if (base64String.startsWith('data:image/')) {
        final commaIndex = base64String.indexOf(',');
        if (commaIndex != -1) {
          cleanBase64 = base64String.substring(commaIndex + 1);
        }
      }
      
      return base64Decode(cleanBase64);
    } catch (e) {
      print('❌ Base64解码失败: $e');
      return null;
    }
  }
  
  /// 📏 获取Base64字符串的大小（KB）
  static double getBase64Size(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return 0.0;
    }
    
    // Base64编码大约增加33%的大小
    final originalSize = (base64String.length * 3) / 4;
    return originalSize / 1024; // 转换为KB
  }
  
  /// ✨ 显示图片选择对话框 - 分平台UI
  static Future<String?> showImagePickerDialog(BuildContext context) async {
    if (kIsWeb) {
      // 🌐 Web端：只显示文件选择选项
      return await _showWebImagePickerDialog(context);
    } else {
      // 📱 移动端：显示拍照和相册选项
      return await _showMobileImagePickerDialog(context);
    }
  }
  
  /// 🌐 Web端图片选择对话框
  static Future<String?> _showWebImagePickerDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图片'),
        content: const Text('从电脑选择图片文件'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'computer'),
            child: const Text('从电脑选择'),
          ),
        ],
      ),
    );
    
    if (result == 'computer') {
      return await pickImageFromGallery();
    }
    
    return null;
  }
  
  /// 📱 移动端图片选择对话框
  static Future<String?> _showMobileImagePickerDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图片'),
        content: const Text('请选择图片来源'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'gallery'),
            child: const Text('相册'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'camera'),
            child: const Text('拍照'),
          ),
        ],
      ),
    );
    
    switch (result) {
      case 'gallery':
        return await pickImageFromGallery();
      case 'camera':
        return await pickImageFromCamera();
      default:
        return null;
    }
  }
  
  /// 🎯 检查Base64字符串是否有效
  static bool isValidBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return false;
    }
    
    try {
      decodeBase64ToBytes(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 🔍 获取图片文件信息
  static Map<String, dynamic> getImageInfo(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return {'valid': false};
    }
    
    try {
      // 解析数据URL前缀获取文件类型
      String mimeType = 'image/jpeg'; // 默认
      if (base64String.startsWith('data:image/')) {
        final semicolonIndex = base64String.indexOf(';');
        if (semicolonIndex != -1) {
          mimeType = base64String.substring(5, semicolonIndex); // 去掉 'data:' 前缀
        }
      }
      
      return {
        'valid': true,
        'size': getBase64Size(base64String),
        'mimeType': mimeType,
        'platform': kIsWeb ? 'web' : 'mobile',
      };
    } catch (e) {
      return {'valid': false, 'error': e.toString()};
    }
  }
}
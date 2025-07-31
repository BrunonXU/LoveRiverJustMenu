import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:html' as html;

import '../themes/colors.dart';
import '../themes/typography.dart';
import '../themes/spacing.dart';

/// 图片选择工具类
/// 支持相机拍照和相册选择
class ImagePickerHelper {
  /// 🎨 直接从相机拍照（公共方法）
  static Future<String?> takePhotoFromCamera(BuildContext context) async {
    return await _takePhoto();
  }
  
  /// 🎨 直接从相册选择（公共方法）
  static Future<String?> pickImageFromGallery(BuildContext context) async {
    return await _pickFromGallery();
  }
  
  /// 显示图片选择对话框
  static Future<String?> showImagePickerDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: AppColors.getBackgroundColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDark),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    
                    Space.w12,
                    
                    Expanded(
                      child: Text(
                        '选择图片',
                        style: AppTypography.titleMediumStyle(isDark: isDark),
                      ),
                    ),
                    
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.getTextSecondaryColor(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 选项列表
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    // 拍照选项
                    _buildOptionTile(
                      icon: Icons.camera,
                      title: '拍照',
                      subtitle: '使用相机拍摄新照片',
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        navigator.pop();
                        final imageUrl = await _takePhoto();
                        if (imageUrl != null) {
                          navigator.pop(imageUrl);
                        }
                      },
                      isDark: isDark,
                    ),
                    
                    Space.h12,
                    
                    // 相册选项
                    _buildOptionTile(
                      icon: Icons.photo_library,
                      title: '从相册选择',
                      subtitle: '从设备相册中选择图片',
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        navigator.pop();
                        final imageUrl = await _pickFromGallery();
                        if (imageUrl != null) {
                          navigator.pop(imageUrl);
                        }
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              
              Space.h24,
            ],
          ),
        ),
      ),
    );
  }
  
  static Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundSecondaryColor(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            Space.w16,
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                  
                  Space.h4,
                  
                  Text(
                    subtitle,
                    style: AppTypography.captionStyle(isDark: isDark),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 拍照功能
  static Future<String?> _takePhoto() async {
    try {
      // 在Web端使用getUserMedia API
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {'facingMode': 'environment'}, // 后置摄像头
        'audio': false,
      });
      
      if (stream != null) {
        // 创建video元素
        final video = html.VideoElement()
          ..srcObject = stream
          ..autoplay = true
          ..muted = true
          ..style.width = '100%'
          ..style.height = '100%';
        
        // 创建canvas用于捕获
        final canvas = html.CanvasElement();
        final context = canvas.getContext('2d') as html.CanvasRenderingContext2D;
        
        // 等待视频加载
        await video.onLoadedMetadata.first;
        
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        
        // 捕获当前帧
        context.drawImage(video, 0, 0);
        
        // 停止摄像头
        stream.getTracks().forEach((track) => track.stop());
        
        // 转换为base64
        final dataUrl = canvas.toDataUrl('image/jpeg', 0.8);
        
        return dataUrl; // 返回base64格式的图片
      }
    } catch (e) {
      print('拍照失败: $e');
      return await _pickFromGallery(); // 如果拍照失败，回退到选择图片
    }
    
    return null;
  }
  
  /// 从相册选择
  static Future<String?> _pickFromGallery() async {
    try {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();
      
      await input.onChange.first;
      
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        
        reader.readAsDataUrl(file);
        await reader.onLoad.first;
        
        return reader.result as String?; // base64格式
      }
    } catch (e) {
      print('选择图片失败: $e');
    }
    
    return null;
  }
  
  /// 压缩图片（可选）
  static Future<String?> compressImage(String imageUrl, {double quality = 0.7}) async {
    try {
      final canvas = html.CanvasElement();
      final context = canvas.getContext('2d') as html.CanvasRenderingContext2D;
      final image = html.ImageElement();
      
      image.src = imageUrl;
      await image.onLoad.first;
      
      // 计算压缩后的尺寸
      const maxWidth = 800;
      const maxHeight = 600;
      
      double width = image.width!.toDouble();
      double height = image.height!.toDouble();
      
      if (width > maxWidth) {
        height = height * maxWidth / width;
        width = maxWidth.toDouble();
      }
      
      if (height > maxHeight) {
        width = width * maxHeight / height;
        height = maxHeight.toDouble();
      }
      
      canvas.width = width.toInt();
      canvas.height = height.toInt();
      
      // 绘制压缩后的图片
      context.drawImageScaled(image, 0, 0, width, height);
      
      return canvas.toDataUrl('image/jpeg', quality);
    } catch (e) {
      print('图片压缩失败: $e');
      return imageUrl; // 返回原图
    }
  }
  
  /// 显示图片预览
  static void showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // 图片
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 48),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // 关闭按钮
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
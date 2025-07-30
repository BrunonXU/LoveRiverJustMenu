import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../core/utils/image_base64_helper.dart';

/// 🖼️ Base64图片显示组件
/// 统一处理Base64图片的显示逻辑，支持占位符和错误处理
class Base64ImageWidget extends StatelessWidget {
  final String? base64Data;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  
  const Base64ImageWidget({
    super.key,
    this.base64Data,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    // 如果没有Base64数据，显示占位符
    if (base64Data == null || base64Data!.isEmpty) {
      return _buildPlaceholder();
    }
    
    // 尝试解码Base64数据
    final Uint8List? imageBytes = ImageBase64Helper.decodeBase64ToBytes(base64Data);
    
    if (imageBytes == null) {
      return _buildErrorWidget();
    }
    
    Widget imageWidget = Image.memory(
      imageBytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        print('❌ 图片显示失败: $error');
        return _buildErrorWidget();
      },
    );
    
    // 如果有圆角，应用圆角
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
  
  /// 🎨 构建占位符
  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            '暂无图片',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  /// ❌ 构建错误组件
  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: borderRadius,
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Base64图片上传区域组件
/// 结合了点击上传和图片显示功能
class Base64ImageUploadWidget extends StatelessWidget {
  final String? base64Data;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final String? uploadHint;
  final BorderRadius? borderRadius;
  
  const Base64ImageUploadWidget({
    super.key,
    this.base64Data,
    this.width,
    this.height,
    this.onTap,
    this.uploadHint,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: base64Data != null && base64Data!.isNotEmpty
            ? Stack(
                children: [
                  // 显示已选择的图片
                  Base64ImageWidget(
                    base64Data: base64Data,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    borderRadius: borderRadius ?? BorderRadius.circular(10),
                  ),
                  
                  // 右上角编辑按钮
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            : _buildUploadPlaceholder(),
      ),
    );
  }
  
  /// 🎨 构建上传占位符
  Widget _buildUploadPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: width != null && width! < 150 ? 32 : 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            uploadHint ?? '点击上传图片',
            style: TextStyle(
              fontSize: width != null && width! < 150 ? 12 : 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
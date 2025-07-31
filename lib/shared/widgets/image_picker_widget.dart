import 'package:flutter/material.dart';
import '../../core/utils/image_base64_helper.dart';
import '../../core/utils/image_compression_helper.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/spacing.dart';

/// 🖼️ 免费版图片选择组件
/// 
/// 核心功能：
/// - 图片选择（Web端文件上传）
/// - 智能压缩到100KB以下（免费Firestore存储）
/// - 实时预览（原图 → 压缩图对比）
/// - 完全免费，无需Firebase Storage
class ImagePickerWidget extends StatefulWidget {
  /// 图片选择完成回调
  final Function(String compressedBase64)? onImageSelected;
  
  /// 初始图片base64（用于编辑场景）
  final String? initialImage;
  
  /// 是否显示压缩详情
  final bool showCompressionDetails;
  
  /// 自定义样式
  final BoxDecoration? decoration;
  
  const ImagePickerWidget({
    super.key,
    this.onImageSelected,
    this.initialImage,
    this.showCompressionDetails = true,
    this.decoration,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _selectedImageBase64;
  String? _compressedImageBase64;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _compressedImageBase64 = widget.initialImage;
    }
  }

  /// 📷 选择并压缩图片
  Future<void> _selectAndCompressImage() async {
    setState(() => _isProcessing = true);
    
    try {
      // 1. 选择图片
      final imageData = await ImageBase64Helper.pickImageFromGallery();
      if (imageData == null) {
        _showMessage('❌ 未选择图片');
        return;
      }
      
      setState(() {
        _selectedImageBase64 = imageData;
      });
      
      final originalSize = ImageBase64Helper.getBase64Size(imageData);
      
      // 2. 智能压缩
      String finalImage = imageData;
      if (originalSize > 100) {
        final compressedImage = await ImageCompressionHelper.compressImage(
          imageData,
          maxSizeKB: 100,
        );
        
        if (compressedImage != null) {
          finalImage = compressedImage;
          final compressedSize = ImageBase64Helper.getBase64Size(compressedImage);
          
          _showMessage(
            '✅ 压缩完成: ${originalSize.toStringAsFixed(1)}KB → ${compressedSize.toStringAsFixed(1)}KB',
            isSuccess: true,
          );
        } else {
          _showMessage('⚠️ 压缩失败，使用原图');
        }
      } else {
        _showMessage('✅ 图片已选择: ${originalSize.toStringAsFixed(1)}KB', isSuccess: true);
      }
      
      setState(() {
        _compressedImageBase64 = finalImage;
      });
      
      // 3. 回调通知父组件
      widget.onImageSelected?.call(finalImage);
      
    } catch (e) {
      _showMessage('❌ 图片处理失败: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// 显示消息
  void _showMessage(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: widget.decoration ?? BoxDecoration(
        color: AppColors.getBackgroundColor(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: _compressedImageBase64 != null 
              ? Colors.green.shade300 
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 选择按钮区域
          InkWell(
            onTap: _isProcessing ? null : _selectAndCompressImage,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  if (_isProcessing) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '正在处理图片...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ] else if (_compressedImageBase64 != null) ...[
                    // 显示已选择的图片
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        child: Image.memory(
                          ImageBase64Helper.decodeBase64ToBytes(_compressedImageBase64!)!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.error, size: 32),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '✅ 图片已选择',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '点击重新选择',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    // 未选择状态
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '选择图片',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '免费版 · 自动压缩优化',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // 压缩详情（可选显示）
          if (widget.showCompressionDetails && 
              _selectedImageBase64 != null && 
              _compressedImageBase64 != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _buildCompressionDetails(),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建压缩详情
  Widget _buildCompressionDetails() {
    if (_selectedImageBase64 == null || _compressedImageBase64 == null) {
      return const SizedBox.shrink();
    }
    
    final originalSize = ImageBase64Helper.getBase64Size(_selectedImageBase64!);
    final compressedSize = ImageBase64Helper.getBase64Size(_compressedImageBase64!);
    final compressionRatio = ((originalSize - compressedSize) / originalSize * 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 压缩详情',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            // 原图信息
            Expanded(
              child: Column(
                children: [
                  Text(
                    '原图',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${originalSize.toStringAsFixed(1)}KB',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(Icons.arrow_forward, color: Colors.grey.shade600, size: 16),
            
            // 压缩后信息
            Expanded(
              child: Column(
                children: [
                  Text(
                    '压缩后',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
                  Text(
                    '${compressedSize.toStringAsFixed(1)}KB',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Text(
              '节省空间: ${compressionRatio.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
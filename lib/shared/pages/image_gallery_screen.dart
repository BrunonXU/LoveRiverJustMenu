import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../widgets/image_gallery_widget.dart';

/// 🖼️ 全屏图片画廊页面
/// 支持Hero动画过渡效果
class ImageGalleryScreen extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final String? heroTag;
  
  const ImageGalleryScreen({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    // 设置全屏沉浸式状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    return Hero(
      tag: heroTag ?? 'image_gallery_${initialIndex}',
      child: ImageGalleryWidget(
        imagePaths: imagePaths,
        initialIndex: initialIndex,
        onClose: () {
          // 恢复状态栏
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          Navigator.of(context).pop();
        },
      ),
    );
  }
  
  /// 🚀 显示图片画廊（带Hero动画）
  static void show(
    BuildContext context, {
    required List<String> imagePaths,
    int initialIndex = 0,
    String? heroTag,
  }) {
    if (imagePaths.isEmpty) return;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImageGalleryScreen(
            imagePaths: imagePaths,
            initialIndex: initialIndex,
            heroTag: heroTag,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        opaque: false,
      ),
    );
  }
}

/// 🖼️ 可点击的画廊触发器组件
/// 点击时打开全屏画廊
class GalleryTrigger extends StatelessWidget {
  final String imagePath;
  final List<String> allImagePaths;
  final String? heroTag;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  
  const GalleryTrigger({
    super.key,
    required this.imagePath,
    required this.allImagePaths,
    this.heroTag,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = allImagePaths.indexOf(imagePath);
    final tag = heroTag ?? 'gallery_trigger_$imagePath';
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ImageGalleryScreen.show(
          context,
          imagePaths: allImagePaths,
          initialIndex: currentIndex >= 0 ? currentIndex : 0,
          heroTag: tag,
        );
      },
      child: Hero(
        tag: tag,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: _buildImage(),
          ),
        ),
      ),
    );
  }
  
  /// 构建图片组件
  Widget _buildImage() {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
      );
    } else {
      return kIsWeb
          ? Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorPlaceholder();
              },
            )
          : Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorPlaceholder();
              },
            );
    }
  }
  
  /// 加载占位符
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  /// 错误占位符
  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🖼️ 画廊网格组件
/// 显示多张图片的网格，点击任意一张打开画廊
class ImageGalleryGrid extends StatelessWidget {
  final List<String> imagePaths;
  final int crossAxisCount;
  final double spacing;
  final double aspectRatio;
  
  const ImageGalleryGrid({
    super.key,
    required this.imagePaths,
    this.crossAxisCount = 3,
    this.spacing = 8,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        final imagePath = imagePaths[index];
        return GalleryTrigger(
          imagePath: imagePath,
          allImagePaths: imagePaths,
          heroTag: 'grid_image_$index',
        );
      },
    );
  }
}

/// 🖼️ 水平滚动画廊组件
/// 水平滚动显示多张图片，点击任意一张打开画廊
class HorizontalImageGallery extends StatelessWidget {
  final List<String> imagePaths;
  final double height;
  final double itemWidth;
  final double spacing;
  
  const HorizontalImageGallery({
    super.key,
    required this.imagePaths,
    this.height = 120,
    this.itemWidth = 120,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          final imagePath = imagePaths[index];
          return Container(
            margin: EdgeInsets.only(
              right: index < imagePaths.length - 1 ? spacing : 0,
            ),
            child: GalleryTrigger(
              imagePath: imagePath,
              allImagePaths: imagePaths,
              width: itemWidth,
              height: height,
              heroTag: 'horizontal_image_$index',
            ),
          );
        },
      ),
    );
  }
}
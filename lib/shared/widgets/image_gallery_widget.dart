import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// 🖼️ 极简图片画廊组件
/// 全屏黑色背景+缩略图切换+捏合缩放功能
class ImageGalleryWidget extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final VoidCallback? onClose;
  
  const ImageGalleryWidget({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    this.onClose,
  });

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget>
    with TickerProviderStateMixin {
  
  // ==================== 控制器和动画 ====================
  
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _thumbnailController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _thumbnailAnimation;
  
  // ==================== 状态变量 ====================
  
  int _currentIndex = 0;
  bool _showThumbnails = false;
  bool _showUI = true;
  TransformationController _transformationController = TransformationController();
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    _initializeAnimations();
    _hideUIAfterDelay();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _thumbnailController.dispose();
    _transformationController.dispose();
    super.dispose();
  }
  
  /// 初始化动画
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _thumbnailController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _thumbnailAnimation = CurvedAnimation(
      parent: _thumbnailController,
      curve: Curves.easeOutCubic,
    );
    
    _fadeController.forward();
  }
  
  /// 延迟隐藏UI
  void _hideUIAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showUI) {
        setState(() {
          _showUI = false;
        });
      }
    });
  }
  
  /// 切换UI显示状态
  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
    
    if (_showUI) {
      _hideUIAfterDelay();
    }
  }
  
  /// 切换缩略图显示
  void _toggleThumbnails() {
    setState(() {
      _showThumbnails = !_showThumbnails;
    });
    
    if (_showThumbnails) {
      _thumbnailController.forward();
    } else {
      _thumbnailController.reverse();
    }
    
    HapticFeedback.lightImpact();
  }
  
  // ==================== 界面构建 ====================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🖼️ 主图片展示区域
          _buildMainImageView(),
          
          // 🎨 顶部工具栏
          if (_showUI) _buildTopToolbar(),
          
          // 🎨 底部缩略图区域
          if (_showThumbnails) _buildThumbnailStrip(),
          
          // 🎨 底部控制栏
          if (_showUI && !_showThumbnails) _buildBottomControls(),
        ],
      ),
    );
  }
  
  /// 🖼️ 主图片展示区域
  Widget _buildMainImageView() {
    return GestureDetector(
      onTap: _toggleUI,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          // 重置缩放
          _transformationController.value = Matrix4.identity();
          HapticFeedback.selectionClick();
        },
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          return _buildZoomableImage(widget.imagePaths[index]);
        },
      ),
    );
  }
  
  /// 🔍 可缩放图片组件
  Widget _buildZoomableImage(String imagePath) {
    return Center(
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 4.0,
        onInteractionStart: (details) {
          // 开始交互时保持UI显示
          if (!_showUI) {
            setState(() {
              _showUI = true;
            });
          }
        },
        onInteractionEnd: (details) {
          // 交互结束后延迟隐藏UI
          _hideUIAfterDelay();
        },
        child: _buildImageWidget(imagePath),
      ),
    );
  }
  
  /// 🖼️ 图片组件
  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
      );
    } else {
      // 对于Web使用asset，对于mobile使用file
      return kIsWeb
          ? Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorPlaceholder();
              },
            )
          : Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorPlaceholder();
              },
            );
    }
  }
  
  /// 🔄 加载占位符
  Widget _buildLoadingPlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
  
  /// ❌ 错误占位符
  Widget _buildErrorPlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.white54,
            size: 48,
          ),
          SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 顶部工具栏
  Widget _buildTopToolbar() {
    return AnimatedOpacity(
      opacity: _showUI ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 关闭按钮
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _fadeController.reverse().then((_) {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.of(context).pop();
                  }
                });
              },
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
                  size: 20,
                ),
              ),
            ),
            
            // 图片计数
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imagePaths.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // 更多选项按钮
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showMoreOptions();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 🎨 底部控制栏
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _showUI ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 上一张按钮
              _buildControlButton(
                icon: Icons.skip_previous,
                onTap: _currentIndex > 0 ? _previousImage : null,
              ),
              
              // 缩略图按钮
              _buildControlButton(
                icon: Icons.photo_library,
                onTap: _toggleThumbnails,
              ),
              
              // 下一张按钮
              _buildControlButton(
                icon: Icons.skip_next,
                onTap: _currentIndex < widget.imagePaths.length - 1 ? _nextImage : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 🎨 控制按钮
  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap();
      } : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(isEnabled ? 0.5 : 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.white38,
          size: 24,
        ),
      ),
    );
  }
  
  /// 🎨 底部缩略图条
  Widget _buildThumbnailStrip() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_thumbnailAnimation),
        child: Container(
          height: 120 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            children: [
              // 缩略图列表
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imagePaths.length,
                  itemBuilder: (context, index) {
                    return _buildThumbnailItem(index);
                  },
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 隐藏缩略图按钮
              GestureDetector(
                onTap: _toggleThumbnails,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 🖼️ 缩略图项目
  Widget _buildThumbnailItem(int index) {
    final isSelected = index == _currentIndex;
    
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        HapticFeedback.selectionClick();
      },
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: _buildThumbnailImage(widget.imagePaths[index]),
        ),
      ),
    );
  }
  
  /// 🖼️ 缩略图图片
  Widget _buildThumbnailImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildThumbnailError();
        },
      );
    } else {
      return kIsWeb
          ? Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildThumbnailError();
              },
            )
          : Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildThumbnailError();
              },
            );
    }
  }
  
  /// ❌ 缩略图错误占位符
  Widget _buildThumbnailError() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(
        Icons.broken_image,
        color: Colors.white38,
        size: 24,
      ),
    );
  }
  
  // ==================== 交互处理方法 ====================
  
  /// 上一张图片
  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  /// 下一张图片
  void _nextImage() {
    if (_currentIndex < widget.imagePaths.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('分享', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现分享功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.white),
              title: const Text('保存到相册', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现保存功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现删除功能
              },
            ),
          ],
        ),
      ),
    );
  }
}
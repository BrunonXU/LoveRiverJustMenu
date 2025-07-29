import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../domain/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

/// 🎨 极简创建菜谱页面 - 单步骤编辑设计
/// 虚线框上传+极简输入框+专注单步骤体验
class CreateRecipeScreenV2 extends ConsumerStatefulWidget {
  const CreateRecipeScreenV2({super.key});

  @override
  ConsumerState<CreateRecipeScreenV2> createState() => _CreateRecipeScreenV2State();
}

class _CreateRecipeScreenV2State extends ConsumerState<CreateRecipeScreenV2> {
  // ==================== 表单控制器 ====================
  
  final _recipeNameController = TextEditingController();
  final _recipeDescriptionController = TextEditingController();
  final _pageController = PageController();
  
  // ==================== 状态变量 ====================
  
  String? _coverImagePath;
  final List<RecipeStepData> _steps = [];
  int _currentStepIndex = 0;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // 初始化第一个步骤
    _addNewStep();
  }
  
  @override
  void dispose() {
    _recipeNameController.dispose();
    _recipeDescriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  // ==================== 界面构建 ====================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildMainContent(),
      ),
    );
  }
  
  /// 🎨 加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF5B6FED),
          ),
          SizedBox(height: 16),
          Text(
            '正在保存菜谱...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 主要内容
  Widget _buildMainContent() {
    if (_steps.isEmpty) {
      return const Center(child: Text('无步骤数据'));
    }
    
    return Column(
      children: [
        // 🎨 极简顶部导航
        _buildMinimalAppBar(),
        
        // 🎨 菜谱基本信息（仅第一页显示）
        if (_currentStepIndex == 0) _buildRecipeBasicInfo(),
        
        // 🎨 步骤编辑区域
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentStepIndex = index;
              });
              HapticFeedback.lightImpact();
            },
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return _buildStepEditPage(_steps[index], index + 1);
            },
          ),
        ),
        
        // 🎨 底部操作按钮
        _buildBottomActions(),
      ],
    );
  }
  
  /// 🎨 菜谱基本信息区域
  Widget _buildRecipeBasicInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 菜谱名称输入框
          TextField(
            controller: _recipeNameController,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              hintText: '菜谱名称',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              HapticFeedback.selectionClick();
            },
          ),
          
          const SizedBox(height: 8),
          
          // 菜谱描述输入框
          TextField(
            controller: _recipeDescriptionController,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
            decoration: const InputDecoration(
              hintText: '简单描述这道菜...',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              HapticFeedback.selectionClick();
            },
          ),
          
          // 分割线
          Container(
            height: 1,
            color: Colors.grey[200],
            margin: const EdgeInsets.only(top: 16),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 极简顶部导航栏
  Widget _buildMinimalAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showExitConfirmation();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 标题
          const Text(
            '创建食谱',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          
          // 预览按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _previewRecipe();
            },
            child: const Text(
              '预览',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5B6FED),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 单个步骤编辑页面
  Widget _buildStepEditPage(RecipeStepData stepData, int stepNumber) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          // 🎨 步骤标题区域
          Row(
            children: [
              // 步骤编号圆圈
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF5B6FED),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 步骤标题输入框
              Expanded(
                child: TextField(
                  controller: stepData.titleController,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: '步骤标题',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 🎨 虚线框图片上传区域
          _buildImageUploadArea(stepData),
          
          const SizedBox(height: 32),
          
          // 🎨 步骤描述输入框
          TextField(
            controller: stepData.descriptionController,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
            decoration: const InputDecoration(
              hintText: '描述具体的操作步骤...',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              HapticFeedback.selectionClick();
            },
          ),
          
          const SizedBox(height: 32),
          
          // 🎨 时间和操作控制区域
          _buildTimeAndActions(stepData),
          
          const SizedBox(height: 100), // 底部留白
        ],
      ),
    );
  }
  
  /// 🎨 虚线框图片上传区域
  Widget _buildImageUploadArea(RecipeStepData stepData) {
    return GestureDetector(
      onTap: () => _selectStepImage(stepData),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: Colors.grey[400]!,
            strokeWidth: 2,
            dashWidth: 8,
            dashSpace: 4,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: stepData.imagePath != null
                ? _buildImagePreview(stepData.imagePath!)
                : _buildImagePlaceholder(stepData),
          ),
        ),
      ),
    );
  }
  
  /// 🎨 图片预览
  Widget _buildImagePreview(String imagePath) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : kIsWeb
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                    ),
        ),
        
        // 重新选择按钮
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
  
  /// 🎨 图片上传占位符
  Widget _buildImagePlaceholder(RecipeStepData stepData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          '${stepData.titleController.text.isEmpty ? "步骤" : stepData.titleController.text}图片',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '点击上传图片',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
  
  /// 🎨 时间和操作控制区域
  Widget _buildTimeAndActions(RecipeStepData stepData) {
    return Row(
      children: [
        // 时间控制
        Row(
          children: [
            // 减少时间按钮
            GestureDetector(
              onTap: () {
                if (stepData.duration > 1) {
                  setState(() {
                    stepData.duration--;
                  });
                  HapticFeedback.lightImpact();
                }
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 时间显示
            Text(
              '${stepData.duration}分钟',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 增加时间按钮
            GestureDetector(
              onTap: () {
                setState(() {
                  stepData.duration++;
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        // 复制按钮
        GestureDetector(
          onTap: () => _duplicateStep(stepData),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '复制',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5B6FED),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 删除按钮（仅当步骤数量大于1时显示）
        if (_steps.length > 1)
          GestureDetector(
            onTap: () => _deleteStep(stepData),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '删除',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  /// 🎨 底部操作按钮
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 添加新步骤按钮
          GestureDetector(
            onTap: _addNewStep,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF5B6FED),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '添加新步骤',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 保存菜谱按钮
          GestureDetector(
            onTap: _saveRecipe,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF5B6FED),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text(
                  '保存菜谱',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ==================== 交互处理方法 ====================
  
  /// 添加新步骤
  void _addNewStep() {
    setState(() {
      _steps.add(RecipeStepData());
      _currentStepIndex = _steps.length - 1;
    });
    
    // 滚动到新步骤
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    
    HapticFeedback.mediumImpact();
  }
  
  /// 复制步骤
  void _duplicateStep(RecipeStepData stepData) {
    final newStep = RecipeStepData();
    newStep.titleController.text = stepData.titleController.text;
    newStep.descriptionController.text = stepData.descriptionController.text;
    newStep.duration = stepData.duration;
    newStep.imagePath = stepData.imagePath;
    
    setState(() {
      _steps.insert(_currentStepIndex + 1, newStep);
    });
    
    HapticFeedback.mediumImpact();
  }
  
  /// 删除步骤
  void _deleteStep(RecipeStepData stepData) {
    if (_steps.length <= 1) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除步骤'),
        content: const Text('确定要删除这个步骤吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _steps.indexOf(stepData);
                _steps.remove(stepData);
                stepData.dispose();
                
                if (_currentStepIndex >= _steps.length) {
                  _currentStepIndex = _steps.length - 1;
                }
              });
              HapticFeedback.mediumImpact();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// 选择步骤图片
  void _selectStepImage(RecipeStepData stepData) async {
    // 使用内置的图片选择对话框
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
            onPressed: () {
              Navigator.pop(context, 'gallery');
            },
            child: const Text('相册'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'camera');
            },
            child: const Text('拍照'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      // 模拟图片路径（实际使用时需要集成图片选择器）
      setState(() {
        stepData.imagePath = 'assets/images/placeholder_step.jpg';
      });
      HapticFeedback.mediumImpact();
    }
  }
  
  /// 预览菜谱
  void _previewRecipe() {
    // TODO: 实现预览功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('预览功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// 保存菜谱
  void _saveRecipe() async {
    // 验证表单
    if (_recipeNameController.text.trim().isEmpty) {
      _showErrorDialog('请输入菜谱名称');
      return;
    }
    
    if (_steps.isEmpty || _steps.first.titleController.text.trim().isEmpty) {
      _showErrorDialog('请至少添加一个步骤');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 构建菜谱数据
      final recipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _recipeNameController.text.trim(),
        description: _recipeDescriptionController.text.trim(),
        iconType: 'AppIcon3DType.recipe',
        totalTime: _steps.fold(0, (sum, step) => sum + step.duration),
        difficulty: '中等', // 默认中等难度
        servings: 2, // 默认2人份
        steps: _steps.map((stepData) => RecipeStep(
          title: stepData.titleController.text.trim(),
          description: stepData.descriptionController.text.trim(),
          duration: stepData.duration,
          imagePath: stepData.imagePath,
        )).toList(),
        imagePath: _coverImagePath, // 使用imagePath而不是coverImagePath
        createdBy: 'user1', // 默认创建者
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublic: false, // 默认私有
        rating: 0.0, // 默认评分
        cookCount: 0, // 默认制作次数
      );
      
      // 保存到数据库
      final repository = await ref.read(initializedRecipeRepositoryProvider.future);
      await repository.saveRecipe(recipe);
      
      // 显示成功消息并返回
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('菜谱保存成功！'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      print('❌ 保存菜谱失败: $e');
      if (mounted) {
        _showErrorDialog('保存失败，请重试');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// 显示退出确认对话框
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('离开编辑'),
        content: const Text('确定要离开吗？未保存的内容将丢失。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('离开', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// 显示错误对话框
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 🎨 步骤数据类
class RecipeStepData {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int duration = 10; // 默认10分钟
  String? imagePath;
  
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}

/// 🎨 虚线边框绘制器
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  
  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));
    
    _drawDashedPath(canvas, path, paint);
  }
  
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
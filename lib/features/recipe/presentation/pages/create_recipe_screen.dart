import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/utils/image_base64_helper.dart';
import '../../../../core/utils/image_compression_helper.dart';
import '../../../../shared/widgets/base64_image_widget.dart';
import '../../../../shared/widgets/image_picker_widget.dart';
import '../../domain/models/recipe.dart';
import '../../../../core/firestore/repositories/recipe_repository.dart';
import '../../../../core/auth/providers/auth_providers.dart';

/// 🎨 极简创建菜谱页面 V2.1 - 垂直滚动设计
/// 所有内容在一页展示，垂直滚动浏览
/// 包含：300px封面上传+菜谱信息+所有步骤编辑
/// ✏️ 支持编辑模式：通过editId参数加载现有菜谱数据
class CreateRecipeScreen extends ConsumerStatefulWidget {
  final String? editId; // ✏️ 编辑模式：传入菜谱ID
  
  const CreateRecipeScreen({super.key, this.editId});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  // ==================== 表单控制器 ====================
  
  final _recipeNameController = TextEditingController();
  final _recipeDescriptionController = TextEditingController();
  final _scrollController = ScrollController(); // 改用滚动控制器
  
  // 新增的表单控制器
  final _totalTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  
  // ==================== 状态变量 ====================
  
  String? _coverImagePath; // 已废弃，保留兼容性
  String? _coverImageBase64; // 📷 Base64封面图片数据
  final List<RecipeStepData> _steps = [];
  bool _isLoading = false;
  String _selectedDifficulty = '简单'; // 默认难度
  
  // ✏️ 编辑模式相关状态
  bool get _isEditMode => widget.editId != null;
  Recipe? _editingRecipe;
  
  // UI 尺寸常量
  static const double _coverImageHeight = 300.0; // 封面图片高度
  static const double _stepImageHeight = 120.0;  // 步骤图片高度
  static const double _pageHorizontalPadding = 24.0; // 页面水平边距
  static const double _sectionSpacing = 24.0; // 区块间距
  
  @override
  void initState() {
    super.initState();
    
    // ✏️ 根据模式进行不同的初始化
    if (_isEditMode) {
      _loadRecipeForEdit();
    } else {
      // 创建模式：初始化第一个步骤
      _addNewStep();
    }
  }
  
  @override
  void dispose() {
    _recipeNameController.dispose();
    _recipeDescriptionController.dispose();
    _scrollController.dispose();
    _totalTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }
  
  // ✏️ 编辑模式：加载菜谱数据并预填充表单
  void _loadRecipeForEdit() async {
    if (widget.editId == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      final recipe = await repository.getRecipe(widget.editId!);
      
      if (recipe != null) {
        setState(() {
          _editingRecipe = recipe;
          // 预填充基本信息
          _recipeNameController.text = recipe.name;
          _recipeDescriptionController.text = recipe.description ?? '';
          _totalTimeController.text = recipe.totalTime.toString();
          _servingsController.text = recipe.servings.toString();
          _selectedDifficulty = recipe.difficulty;
          _coverImagePath = recipe.imagePath;
          _coverImageBase64 = recipe.imageBase64; // 📷 加载Base64图片数据
          
          // 清空现有步骤，重新添加
          _steps.clear();
          for (final step in recipe.steps) {
            final stepData = RecipeStepData();
            stepData.titleController.text = step.title;
            stepData.descriptionController.text = step.description;
            stepData.duration = step.duration;
            stepData.imagePath = step.imagePath;
            stepData.imageBase64 = step.imageBase64; // 📷 加载Base64图片数据
            // 注意：当前RecipeStepData不支持tips，暂时跳过
            _steps.add(stepData);
          }
          
          // 如果没有步骤，至少添加一个空步骤
          if (_steps.isEmpty) {
            _addNewStep();
          }
          
          _isLoading = false;
        });
      } else {
        // 菜谱不存在，回退到创建模式
        setState(() {
          _isLoading = false;
        });
        _addNewStep();
      }
    } catch (e) {
      print('❌ 加载编辑菜谱失败: $e');
      setState(() {
        _isLoading = false;
      });
      _addNewStep();
    }
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
  
  /// 🎨 主要内容 - 垂直滚动设计
  Widget _buildMainContent() {
    return Column(
      children: [
        // 🎨 顶部导航栏
        _buildAppBar(),
        
        // 🎨 主要内容区域
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(_pageHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ 封面图片上传区域
                _buildCoverImageUpload(),
                
                const SizedBox(height: _sectionSpacing),
                
                // 📝 菜谱基本信息
                _buildRecipeBasicInfo(),
                
                const SizedBox(height: _sectionSpacing),
                
                // 📊 菜谱元数据
                _buildRecipeMetadata(),
                
                const SizedBox(height: _sectionSpacing),
                
                // 📋 所有步骤编辑
                _buildAllStepsEdit(),
                
                // 底部安全区域
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
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
  
  /// 🎨 构建顶部导航栏
  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 取消按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          
          // 中央标题 - 根据编辑模式动态显示
          Expanded(
            child: Center(
              child: Text(
                _isEditMode ? '编辑菜谱' : '创建菜谱',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          // 保存按钮
          GestureDetector(
            onTap: _saveRecipe,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5B6FED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '保存',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 构建封面图片上传区域 - 集成免费版压缩功能
  Widget _buildCoverImageUpload() {
    return SizedBox(
      height: _coverImageHeight,
      child: ImagePickerWidget(
        initialImage: _coverImageBase64,
        showCompressionDetails: true,
        onImageSelected: (compressedBase64) {
          setState(() {
            _coverImageBase64 = compressedBase64;
            _coverImagePath = null; // 清空旧的路径数据
          });
          HapticFeedback.mediumImpact();
        },
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _coverImageBase64 != null 
                ? Colors.green.shade300 
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
      ),
    );
  }
  
  /// 🎨 默认封面上传界面（已废弃，由Base64ImageUploadWidget替代）
  
  /// 🎨 构建菜谱元数据（时间、难度、份量）
  Widget _buildRecipeMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 制作时间
        Row(
          children: [
            const Text(
              '制作时间',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _totalTimeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: '45',
                  suffixText: '分钟',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) => HapticFeedback.selectionClick(),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 难度选择
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '难度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ['简单', '中等', '困难'].map((difficulty) {
                final isSelected = _selectedDifficulty == difficulty;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5B6FED) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 份量
        Row(
          children: [
            const Text(
              '份量',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: '2',
                  suffixText: '人份',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) => HapticFeedback.selectionClick(),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// 🎨 构建所有步骤编辑区域
  Widget _buildAllStepsEdit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 步骤标题
        Row(
          children: [
            const Text(
              '制作步骤',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            // 添加步骤按钮
            GestureDetector(
              onTap: _addNewStep,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6FED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFF5B6FED),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '添加步骤',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5B6FED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 步骤列表
        if (_steps.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: Text(
                '还没有添加步骤\\n点击上方按钮开始添加',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ...List.generate(_steps.length, (index) {
            final step = _steps[index];
            final stepNumber = index + 1;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: _buildStepEditItem(step, stepNumber, index),
            );
          }),
      ],
    );
  }
  
  /// 🎨 单个步骤编辑项
  Widget _buildStepEditItem(RecipeStepData stepData, int stepNumber, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 步骤标题行
          Row(
            children: [
              // 步骤编号
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6FED),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 删除按钮
              const Spacer(),
              if (_steps.length > 1)
                GestureDetector(
                  onTap: () => _removeStep(index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red[400],
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 步骤图片上传区域
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片上传区域 - 🔧 修复双重点击事件冲突
              Base64ImageUploadWidget(
                base64Data: stepData.imageBase64,
                width: _stepImageHeight,
                height: _stepImageHeight,
                onTap: () => _selectStepImage(stepData),
                uploadHint: '+ 图片',
                borderRadius: BorderRadius.circular(12),
              ),
              
              const SizedBox(width: 16),
              
              // 步骤信息输入区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 步骤说明
                    TextField(
                      controller: stepData.descriptionController,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        hintText: '步骤说明...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) => HapticFeedback.selectionClick(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 🎨 默认步骤图片上传（已废弃，由Base64ImageUploadWidget替代）
  
  /// 🎨 底部操作按钮 (已废弃，改为顶部保存)
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
    });
    
    // 滚动到新步骤
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    HapticFeedback.mediumImpact();
  }
  
  /// 删除步骤
  void _removeStep(int index) {
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
                _steps[index].dispose();
                _steps.removeAt(index);
              });
              HapticFeedback.mediumImpact();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// 📷 封面图片选择现已集成到 ImagePickerWidget 中
  /// 包含智能压缩功能，自动优化到100KB以下，完全免费
  
  /// 复制步骤
  void _duplicateStep(RecipeStepData stepData) {
    final newStep = RecipeStepData();
    newStep.titleController.text = stepData.titleController.text;
    newStep.descriptionController.text = stepData.descriptionController.text;
    newStep.duration = stepData.duration;
    newStep.imagePath = stepData.imagePath;
    newStep.imageBase64 = stepData.imageBase64; // 📷 复制Base64图片数据
    
    setState(() {
      _steps.add(newStep);
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
                
                // 在垂直滚动设计中不需要当前步骤索引
              });
              HapticFeedback.mediumImpact();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// 📷 选择步骤图片 - 集成智能压缩功能
  void _selectStepImage(RecipeStepData stepData) async {
    try {
      // 1. 选择图片
      final imageData = await ImageBase64Helper.pickImageFromGallery();
      if (imageData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 未选择图片')),
        );
        return;
      }
      
      final originalSize = ImageBase64Helper.getBase64Size(imageData);
      
      // 2. 智能压缩 - 步骤图片压缩到50KB以下（更小尺寸）
      String finalImage = imageData;
      if (originalSize > 50) {
        final compressedImage = await ImageCompressionHelper.compressImage(
          imageData,
          maxSizeKB: 50, // 步骤图片更小压缩
        );
        
        if (compressedImage != null) {
          finalImage = compressedImage;
          final compressedSize = ImageBase64Helper.getBase64Size(compressedImage);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ 步骤图片压缩完成: ${originalSize.toStringAsFixed(1)}KB → ${compressedSize.toStringAsFixed(1)}KB'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ 压缩失败，使用原图')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 步骤图片已选择: ${originalSize.toStringAsFixed(1)}KB'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // 3. 更新状态
      setState(() {
        stepData.imageBase64 = finalImage;
        stepData.imagePath = null; // 清空旧的路径数据
      });
      HapticFeedback.mediumImpact();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ 步骤图片处理失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    
    if (_steps.isEmpty || _steps.first.descriptionController.text.trim().isEmpty) {
      _showErrorDialog('请至少添加一个步骤');
      return;
    }
    
    // 获取当前用户ID
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      _showErrorDialog('请先登录');
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
        totalTime: int.tryParse(_totalTimeController.text) ?? 
                  _steps.fold(0, (sum, step) => sum + step.duration),
        difficulty: _selectedDifficulty,
        servings: int.tryParse(_servingsController.text) ?? 2,
        steps: _steps.map((stepData) => RecipeStep(
          title: stepData.descriptionController.text.trim().isNotEmpty 
                 ? stepData.descriptionController.text.trim() 
                 : '步骤${_steps.indexOf(stepData) + 1}',
          description: stepData.descriptionController.text.trim(),
          duration: stepData.duration,
          imagePath: stepData.imagePath, // 保留兼容性
          imageBase64: stepData.imageBase64, // 📷 使用Base64数据
        )).toList(),
        imagePath: _coverImagePath, // 保留兼容性
        imageBase64: _coverImageBase64, // 📷 使用Base64数据
        createdBy: currentUser.uid, // ✅ 使用真实用户ID
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublic: false,
        rating: 0.0,
        cookCount: 0,
      );
      
      // 保存到数据库
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      await repository.saveRecipe(recipe, currentUser.uid); // ✅ 传入用户ID参数
      
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
  String? imagePath; // 保留兼容性
  String? imageBase64; // 📷 Base64图片数据
  
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
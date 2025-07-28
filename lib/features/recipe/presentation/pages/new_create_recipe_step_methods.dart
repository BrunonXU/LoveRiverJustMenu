// 🔥 新的烹饪模式风格步骤编辑方法
// 这些方法将添加到 create_recipe_screen.dart 中

/// 🔥 完全重构：与烹饪模式对齐的步骤编辑面板
/// 一次只显示一个步骤，占满整个页面，格式与烹饪模式完全一致
Widget _buildStepsPanel(bool isDark) {
  return BreathingWidget(
    child: MinimalCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔧 缩小标题区域，优化空间利用
          _buildStepsHeader(isDark),
          
          Space.h12, // 减少间距
          
          // 🔥 全屏步骤编辑界面 - 与烹饪模式格式完全一致
          Expanded(
            child: _steps.isEmpty
                ? _buildFirstStepCreator(isDark)
                : _buildCookingModeStepEditor(isDark),
          ),
        ],
      ),
    ),
  );
}

/// 🔧 缩小的步骤标题区域
Widget _buildStepsHeader(bool isDark) {
  return Row(
    children: [
      Text(
        '制作步骤',
        style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith( // 使用更小字体
          fontWeight: AppTypography.medium,
        ),
      ),
      const Spacer(),
      if (_steps.isNotEmpty) ...[ 
        // 步骤导航指示器
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Text(
            '${_currentStepIndex + 1}/${_steps.length}',
            style: AppTypography.captionStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
              fontWeight: AppTypography.medium,
            ),
          ),
        ),
      ],
    ],
  );
}

/// 🔥 首次创建步骤界面 - 引导用户创建第一个步骤
Widget _buildFirstStepCreator(bool isDark) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 大号图标，模拟烹饪模式样式
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '🍳',
              style: const TextStyle(fontSize: 60), // 与烹饪模式一致的大图标
            ),
          ),
        ),
        
        Space.h24,
        
        Text(
          '开始创建第一个步骤',
          style: AppTypography.customStyle(
            fontSize: 32, // 接近烹饪模式的48px，但适合创建界面
            fontWeight: AppTypography.light,
            isDark: isDark,
          ),
        ),
        
        Space.h12,
        
        Text(
          '每个步骤都会以全屏形式呈现\n就像烹饪模式一样清晰易懂',
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
            height: 1.8, // 与烹饪模式一致的行高
          ),
          textAlign: TextAlign.center,
        ),
        
        Space.h32,
        
        // 开始创建按钮
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _addNewStep();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                Space.w8,
                Text(
                  '创建第一步',
                  style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// 🔥 烹饪模式风格的步骤编辑器 - 完全对齐格式
Widget _buildCookingModeStepEditor(bool isDark) {
  return PageView.builder(
    controller: _stepPageController,
    onPageChanged: (index) {
      setState(() {
        _currentStepIndex = index;
      });
    },
    itemCount: _steps.length,
    itemBuilder: (context, index) {
      return _buildSingleStepEditor(index, isDark);
    },
  );
}

/// 🔥 单个步骤编辑器 - 完全模拟烹饪模式布局
Widget _buildSingleStepEditor(int stepIndex, bool isDark) {
  final stepControllers = _stepControllers[stepIndex];
  final titleController = stepControllers['title']!;
  final descriptionController = stepControllers['description']!;
  
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 步骤标题区 - 完全模拟烹饪模式
        Row(
          children: [
            // 步骤图标 - 80px大小，与烹饪模式一致
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getStepIcon(stepIndex),
                  style: const TextStyle(fontSize: 40), // 大图标
                ),
              ),
            ),
            
            Space.w16,
            
            // 步骤信息区
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '第${stepIndex + 1}步',
                    style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                  
                  Space.h8,
                  
                  // 步骤标题输入框 - 28px大字体风格
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: titleController.text.isEmpty 
                              ? Colors.red.withOpacity(0.3)
                              : AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: titleController,
                      style: AppTypography.customStyle(
                        fontSize: 28, // 接近烹饪模式的48px，但适合输入
                        fontWeight: AppTypography.light,
                        isDark: isDark,
                      ),
                      decoration: InputDecoration(
                        hintText: '步骤标题（如：准备食材）',
                        hintStyle: AppTypography.customStyle(
                          fontSize: 28,
                          fontWeight: AppTypography.light,
                          isDark: isDark,
                        ).copyWith(
                          color: AppColors.getTextSecondaryColor(isDark),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      ),
                      onChanged: (value) {
                        setState(() {}); // 更新边框颜色
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        Space.h32,
        
        // 🔥 步骤描述区 - 与烹饪模式布局一致
        Text(
          '详细描述',
          style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
        
        Space.h12,
        
        Container(
          decoration: BoxDecoration(
            color: AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: descriptionController.text.isEmpty 
                  ? Colors.red.withOpacity(0.3)
                  : AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: descriptionController,
            maxLines: 4,
            style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
              height: 1.8, // 与烹饪模式一致的行高
              fontWeight: AppTypography.light,
            ),
            decoration: InputDecoration(
              hintText: '详细描述操作步骤...',
              hintStyle: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
                height: 1.8,
                fontWeight: AppTypography.light,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
            onChanged: (value) {
              setState(() {}); // 更新边框颜色
            },
          ),
        ),
        
        Space.h24,
        
        // 🔧 操作区域 - 紧凑布局
        Row(
          children: [
            // 时长设置
            Expanded(
              child: _buildTimeSelector(stepIndex, isDark),
            ),
            
            Space.w16,
            
            // 删除步骤按钮
            if (_steps.length > 1)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _removeStep(stepIndex);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        
        const Spacer(),
        
        // 🔥 底部导航区域 - 与烹饪模式风格一致
        _buildStepNavigation(stepIndex, isDark),
      ],
    ),
  );
}

/// 🔥 步骤导航区域 - 模拟烹饪模式的导航控制
Widget _buildStepNavigation(int stepIndex, bool isDark) {
  return Row(
    children: [
      // 上一步按钮
      if (stepIndex > 0)
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _stepPageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundSecondaryColor(isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: AppColors.getTextSecondaryColor(isDark),
                    size: 20,
                  ),
                  Space.w4,
                  Text(
                    '上一步',
                    style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      
      if (stepIndex > 0) Space.w12,
      
      // 主操作按钮
      Expanded(
        flex: stepIndex == _steps.length - 1 ? 2 : 1,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (stepIndex == _steps.length - 1) {
              // 最后一步：添加新步骤
              _addNewStep();
            } else {
              // 不是最后一步：下一步
              _stepPageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (stepIndex == _steps.length - 1) ...[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                  Space.w4,
                  Text(
                    '继续添加',
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ] else ...[
                  Text(
                    '下一步',
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                  Space.w4,
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

/// 获取步骤图标
String _getStepIcon(int stepIndex) {
  final icons = ['🥄', '🔥', '🍳', '⏰', '✨', '🍽️', '💫', '🎯'];
  return icons[stepIndex % icons.length];
}

/// 时长选择器
Widget _buildTimeSelector(int stepIndex, bool isDark) {
  final duration = _steps[stepIndex].duration;
  
  return Container(
    height: 48,
    decoration: BoxDecoration(
      color: AppColors.getBackgroundSecondaryColor(isDark),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
    ),
    child: Row(
      children: [
        Space.w12,
        
        GestureDetector(
          onTap: () {
            if (duration > 1) {
              setState(() {
                _steps[stepIndex] = _steps[stepIndex].copyWith(
                  duration: duration - 1,
                );
              });
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: duration > 1 
                  ? AppColors.getTextSecondaryColor(isDark).withOpacity(0.1)
                  : AppColors.getTextSecondaryColor(isDark).withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(
              Icons.remove,
              size: 16,
              color: duration > 1 
                  ? AppColors.getTextSecondaryColor(isDark)
                  : AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
            ),
          ),
        ),
        
        Expanded(
          child: Center(
            child: Text(
              '$duration 分钟',
              style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
        ),
        
        GestureDetector(
          onTap: () {
            setState(() {
              _steps[stepIndex] = _steps[stepIndex].copyWith(
                duration: duration + 1,
              );
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(
              Icons.add,
              size: 16,
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
        ),
        
        Space.w12,
      ],
    ),
  );
}
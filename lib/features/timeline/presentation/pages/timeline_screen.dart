import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../widgets/timeline_3d_widget.dart';
import '../../domain/models/memory.dart';
import 'add_memory_screen.dart';
import 'memory_detail_screen.dart';

/// 3D时光机界面
/// 已集成完整的3D时光机功能，支持手势操作和呼吸动画
/// 现已支持记录美食故事和一句话点评
class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Memory> _memories = [];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  void _loadMemories() {
    setState(() {
      _memories = MemoryData.getSampleMemories();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '美食时光机',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: AppColors.textPrimary,
              size: 24,
            ),
            onPressed: _addNewMemory,
          ),
        ],
      ),
      body: _memories.isEmpty
          ? _buildEmptyState()
          : Timeline3DWidget(
              memories: _memories,
              onMemoryTap: (memory) {
                _showMemoryDetail(memory);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewMemory,
        backgroundColor: Color(0xFF5B6FED),
        icon: Icon(Icons.auto_stories, color: Colors.white),
        label: Text(
          '记录美食',
          style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无美食记忆',
            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '记录每道菜的故事，留下美好回忆',
            style: AppTypography.bodySmallStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _addNewMemory,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Color(0xFF5B6FED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                border: Border.all(
                  color: Color(0xFF5B6FED).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Color(0xFF5B6FED),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '创建第一个记忆',
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
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
    );
  }

  void _showMemoryDetail(Memory memory) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(
          memory: memory,
          onMemoryUpdated: (updatedMemory) {
            _updateMemory(updatedMemory);
          },
        ),
      ),
    );
  }

  void _addNewMemory() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMemoryScreen(),
      ),
    ).then((newMemory) {
      if (newMemory != null && newMemory is Memory) {
        _addMemory(newMemory);
      }
    });
  }

  void _addMemory(Memory memory) {
    setState(() {
      _memories.insert(0, memory); // 新记忆插入到最前面
    });
    _showSuccessMessage('美食记忆已添加到时光机！');
  }

  void _updateMemory(Memory updatedMemory) {
    setState(() {
      final index = _memories.indexWhere((m) => m.id == updatedMemory.id);
      if (index != -1) {
        _memories[index] = updatedMemory;
      }
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

/// 🔧 数据备份恢复服务 - JSON格式导入导出
class DataBackupService {
  final RecipeRepository _repository;
  
  DataBackupService(this._repository);
  
  /// 📤 导出数据为JSON文件
  Future<File?> exportData({
    required BuildContext context,
    bool shareDirectly = true,
  }) async {
    try {
      // 获取所有菜谱数据
      final recipes = _repository.getAllRecipes();
      
      if (recipes.isEmpty) {
        _showMessage(context, '暂无菜谱数据可导出');
        return null;
      }
      
      // 构建导出数据结构
      final exportData = {
        'app': '爱心食谱',
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalRecipes': recipes.length,
        'recipes': recipes.map((recipe) => _recipeToJson(recipe)).toList(),
      };
      
      // 生成文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '爱心食谱备份_$timestamp.json';
      
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      
      // 格式化JSON（美观易读）
      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(exportData);
      
      // 写入文件
      await file.writeAsString(jsonString, encoding: utf8);
      
      if (shareDirectly) {
        // 直接分享文件
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: '爱心食谱数据备份',
          text: '备份时间：${DateTime.now().toString().split('.')[0]}\n共${recipes.length}个菜谱',
        );
        
        _showMessage(context, '导出成功！共${recipes.length}个菜谱');
      }
      
      return file;
    } catch (e) {
      _showMessage(context, '导出失败：$e', isError: true);
      return null;
    }
  }
  
  /// 📥 从JSON文件导入数据
  Future<void> importData({
    required BuildContext context,
    bool merge = true, // 是否合并（true）还是覆盖（false）
  }) async {
    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: '选择爱心食谱备份文件',
      );
      
      if (result == null || result.files.single.path == null) {
        return;
      }
      
      // 读取文件
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString(encoding: utf8);
      final data = jsonDecode(jsonString);
      
      // 验证文件格式
      if (data['app'] != '爱心食谱') {
        _showMessage(context, '无效的备份文件', isError: true);
        return;
      }
      
      // 版本检查
      final version = data['version'] as String;
      if (!_isVersionCompatible(version)) {
        final proceed = await _showConfirmDialog(
          context,
          '版本警告',
          '备份文件版本($version)与当前版本(1.0.0)不一致，继续导入可能出现问题。是否继续？',
        );
        if (!proceed) return;
      }
      
      // 统计信息
      final totalRecipes = data['totalRecipes'] as int;
      final exportDate = DateTime.parse(data['exportDate']);
      
      // 确认导入
      final message = merge 
          ? '发现${totalRecipes}个菜谱（备份时间：${_formatDate(exportDate)}）\n\n选择导入方式：'
          : '⚠️ 覆盖模式将删除所有现有菜谱！\n\n备份包含${totalRecipes}个菜谱';
      
      if (!merge) {
        final proceed = await _showConfirmDialog(
          context,
          '确认覆盖',
          message,
        );
        if (!proceed) return;
      }
      
      // 开始导入
      int importedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;
      
      // 如果是覆盖模式，先清空数据
      if (!merge) {
        final allRecipes = _repository.getAllRecipes();
        for (final recipe in allRecipes) {
          await _repository.deleteRecipe(recipe.id);
        }
      }
      
      // 导入菜谱
      for (final recipeJson in data['recipes']) {
        try {
          final recipe = _jsonToRecipe(recipeJson);
          
          // 合并模式下检查是否已存在
          if (merge && _repository.getRecipe(recipe.id) != null) {
            skippedCount++;
            continue;
          }
          
          await _repository.saveRecipe(recipe);
          importedCount++;
        } catch (e) {
          errorCount++;
          print('导入菜谱失败: $e');
        }
      }
      
      // 显示结果
      String resultMessage = '导入完成！\n';
      resultMessage += '✅ 成功导入：$importedCount 个菜谱\n';
      if (skippedCount > 0) {
        resultMessage += '⏭️ 跳过重复：$skippedCount 个菜谱\n';
      }
      if (errorCount > 0) {
        resultMessage += '❌ 导入失败：$errorCount 个菜谱';
      }
      
      _showMessage(context, resultMessage);
      
      // 震动反馈
      HapticFeedback.mediumImpact();
      
    } catch (e) {
      _showMessage(context, '导入失败：$e', isError: true);
    }
  }
  
  /// 🔄 快速备份到应用文档目录
  Future<void> quickBackup(BuildContext context) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/backups');
      
      // 创建备份目录
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // 导出到备份目录
      final file = await exportData(context: context, shareDirectly: false);
      if (file != null) {
        final backupFile = File('${backupDir.path}/${file.uri.pathSegments.last}');
        await file.copy(backupFile.path);
        
        // 只保留最近10个备份
        await _cleanOldBackups(backupDir, maxBackups: 10);
        
        _showMessage(context, '备份成功！');
      }
    } catch (e) {
      _showMessage(context, '备份失败：$e', isError: true);
    }
  }
  
  /// 🔧 Recipe转JSON（包含所有字段）
  Map<String, dynamic> _recipeToJson(Recipe recipe) {
    return {
      'id': recipe.id,
      'name': recipe.name,
      'description': recipe.description,
      'iconType': recipe.iconType,
      'totalTime': recipe.totalTime,
      'difficulty': recipe.difficulty,
      'servings': recipe.servings,
      'steps': recipe.steps.map((step) => {
        'title': step.title,
        'description': step.description,
        'duration': step.duration,
        'tips': step.tips,
        'imagePath': step.imagePath,
        'ingredients': step.ingredients,
      }).toList(),
      'imagePath': recipe.imagePath,
      'createdBy': recipe.createdBy,
      'createdAt': recipe.createdAt.toIso8601String(),
      'updatedAt': recipe.updatedAt.toIso8601String(),
      'isPublic': recipe.isPublic,
      'rating': recipe.rating,
      'cookCount': recipe.cookCount,
    };
  }
  
  /// 🔧 JSON转Recipe
  Recipe _jsonToRecipe(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconType: json['iconType'],
      totalTime: json['totalTime'],
      difficulty: json['difficulty'],
      servings: json['servings'],
      steps: (json['steps'] as List).map((stepJson) => RecipeStep(
        title: stepJson['title'],
        description: stepJson['description'],
        duration: stepJson['duration'],
        tips: stepJson['tips'],
        imagePath: stepJson['imagePath'],
        ingredients: List<String>.from(stepJson['ingredients'] ?? []),
      )).toList(),
      imagePath: json['imagePath'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isPublic: json['isPublic'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      cookCount: json['cookCount'] ?? 0,
    );
  }
  
  /// 🔧 版本兼容性检查
  bool _isVersionCompatible(String version) {
    // 简单的版本检查，后续可以扩展
    final parts = version.split('.');
    final major = int.tryParse(parts[0]) ?? 0;
    return major == 1; // 主版本号相同即可
  }
  
  /// 🗑️ 清理旧备份
  Future<void> _cleanOldBackups(Directory backupDir, {int maxBackups = 10}) async {
    final files = backupDir.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    
    if (files.length <= maxBackups) return;
    
    // 按修改时间排序
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    
    // 删除旧文件
    for (int i = maxBackups; i < files.length; i++) {
      await files[i].delete();
    }
  }
  
  /// 📅 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// 💬 显示消息
  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            height: 1.5,
          ),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
  
  /// 🔧 确认对话框
  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    if (!context.mounted) return false;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('确定'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
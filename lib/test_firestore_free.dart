import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/utils/image_base64_helper.dart';
import 'core/utils/image_compression_helper.dart';
import 'features/recipe/domain/models/recipe.dart';
import 'core/firestore/repositories/recipe_repository.dart';

/// 🧪 Firestore免费版测试
/// 专门为免费版用户设计，不使用Storage
class TestFirestoreFree extends StatefulWidget {
  const TestFirestoreFree({super.key});

  @override
  State<TestFirestoreFree> createState() => _TestFirestoreFreeState();
}

class _TestFirestoreFreeState extends State<TestFirestoreFree> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RecipeRepository _recipeRepository = RecipeRepository();
  
  String _status = '🆓 免费版测试 - 无需Storage会员';
  bool _isLoading = false;
  List<String> _logs = [];
  User? _currentUser;
  String? _selectedImageBase64;
  String? _compressedImageBase64;
  String? _createdRecipeId;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _addLog('🆓 免费版模式启动');
    if (_currentUser != null) {
      _addLog('👤 当前用户: ${_currentUser!.uid.substring(0, 8)}...');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    print(message);
  }

  /// 🔐 匿名登录
  Future<void> _anonymousLogin() async {
    try {
      _addLog('🔐 匿名登录中...');
      final userCredential = await _auth.signInAnonymously();
      setState(() {
        _currentUser = userCredential.user;
      });
      _addLog('✅ 登录成功: ${_currentUser!.uid.substring(0, 8)}...');
    } catch (e) {
      _addLog('❌ 登录失败: $e');
    }
  }

  /// 📷 选择并压缩图片
  Future<void> _selectAndCompressImage() async {
    try {
      _addLog('📷 选择图片...');
      final imageBase64 = await ImageBase64Helper.pickImageFromGallery();
      
      if (imageBase64 != null) {
        setState(() {
          _selectedImageBase64 = imageBase64;
        });
        
        final originalSize = ImageBase64Helper.getBase64Size(imageBase64);
        _addLog('✅ 图片选择成功: ${originalSize.toStringAsFixed(1)}KB');
        
        // 检查是否需要压缩
        if (originalSize > 100) {
          _addLog('🔄 图片超过100KB，开始压缩...');
          final compressedImage = await ImageCompressionHelper.compressImage(imageBase64);
          
          if (compressedImage != null) {
            setState(() {
              _compressedImageBase64 = compressedImage;
            });
            
            final stats = ImageCompressionHelper.getCompressionStats(imageBase64, compressedImage);
            _addLog('✅ 压缩完成: ${stats['originalSizeKB'].toStringAsFixed(1)}KB → ${stats['compressedSizeKB'].toStringAsFixed(1)}KB');
            _addLog('💾 节省空间: ${stats['savingsPercent'].toStringAsFixed(1)}%');
            
            if (stats['firestoreCompatible']) {
              _addLog('✅ 图片符合Firestore免费版要求');
            } else {
              _addLog('⚠️ 图片仍然较大，可能需要进一步压缩');
            }
          } else {
            _addLog('❌ 压缩失败，使用原图');
            setState(() {
              _compressedImageBase64 = imageBase64;
            });
          }
        } else {
          _addLog('✅ 图片大小合适，无需压缩');
          setState(() {
            _compressedImageBase64 = imageBase64;
          });
        }
      } else {
        _addLog('ℹ️ 用户取消选择');
      }
    } catch (e) {
      _addLog('❌ 图片处理失败: $e');
    }
  }

  /// 📝 创建菜谱（免费版方式）
  Future<void> _createRecipeFree() async {
    if (_currentUser == null) {
      _addLog('❌ 请先登录');
      return;
    }
    
    if (_compressedImageBase64 == null) {
      _addLog('❌ 请先选择并压缩图片');
      return;
    }

    try {
      _addLog('📝 创建免费版菜谱...');
      final userId = _currentUser!.uid;
      
      // 检查图片大小
      final imageSize = ImageBase64Helper.getBase64Size(_compressedImageBase64!);
      _addLog('📏 使用图片大小: ${imageSize.toStringAsFixed(1)}KB');
      
      if (imageSize > 150) {
        _addLog('⚠️ 图片较大，可能影响性能');
      }
      
      // 创建菜谱（使用base64，不用Storage）
      final testRecipe = Recipe(
        id: '',
        name: '🆓 免费版菜谱 - ${DateTime.now().toString().substring(11, 19)}',
        description: '使用Firestore免费版存储的菜谱，图片已压缩优化',
        iconType: 'food',
        totalTime: 25,
        difficulty: '简单',
        servings: 2,
        steps: [
          RecipeStep(
            title: '准备食材',
            description: '准备新鲜的食材',
            duration: 5,
            tips: '食材要新鲜',
            ingredients: ['主料1', '主料2'],
          ),
          RecipeStep(
            title: '开始制作',
            description: '按照步骤制作美食',
            duration: 20,
            tips: '注意火候',
            ingredients: [],
          ),
        ],
        imageUrl: null, // 不使用Storage URL
        imageBase64: _compressedImageBase64, // 使用压缩后的base64
        createdBy: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublic: true,
        rating: 4.0,
        cookCount: 0,
      );
      
      // 保存到Firestore
      final recipeId = await _recipeRepository.saveRecipe(testRecipe, userId);
      setState(() {
        _createdRecipeId = recipeId;
      });
      
      _addLog('✅ 免费版菜谱创建成功!');
      _addLog('🆔 菜谱ID: $recipeId');
      
    } catch (e) {
      if (e.toString().contains('1048487')) {
        _addLog('❌ 图片仍然太大！请选择更小的图片或进一步压缩');
        _addLog('💡 建议：选择截图或简单图片，避免高清照片');
      } else {
        _addLog('❌ 菜谱创建失败: $e');
      }
    }
  }

  /// 📖 读取菜谱验证
  Future<void> _readRecipe() async {
    if (_createdRecipeId == null) {
      _addLog('❌ 请先创建菜谱');
      return;
    }

    try {
      _addLog('📖 读取菜谱验证...');
      final recipe = await _recipeRepository.getRecipe(_createdRecipeId!);
      
      if (recipe != null) {
        _addLog('✅ 菜谱读取成功');
        _addLog('📋 名称: ${recipe.name}');
        _addLog('🖼️ 图片: ${recipe.imageBase64 != null ? "有(${ImageBase64Helper.getBase64Size(recipe.imageBase64!).toStringAsFixed(1)}KB)" : "无"}');
        _addLog('📝 步骤: ${recipe.steps.length}个');
      } else {
        _addLog('❌ 菜谱读取失败');
      }
    } catch (e) {
      _addLog('❌ 读取异常: $e');
    }
  }

  /// 🧹 清理测试数据
  Future<void> _cleanup() async {
    if (_createdRecipeId != null && _currentUser != null) {
      try {
        _addLog('🧹 清理测试数据...');
        await _recipeRepository.deleteRecipe(_createdRecipeId!, _currentUser!.uid);
        _addLog('✅ 测试数据清理完成');
        
        setState(() {
          _createdRecipeId = null;
          _selectedImageBase64 = null;
          _compressedImageBase64 = null;
        });
      } catch (e) {
        _addLog('❌ 清理失败: $e');
      }
    }
  }

  /// 🚀 完整测试
  Future<void> _runFullTest() async {
    setState(() {
      _isLoading = true;
      _status = '正在运行免费版完整测试...';
      _logs.clear();
    });

    try {
      await _anonymousLogin();
      await Future.delayed(const Duration(seconds: 1));
      
      _addLog('💡 请选择一张图片进行测试...');
      
    } catch (e) {
      _addLog('❌ 测试失败: $e');
      setState(() {
        _status = '❌ 测试失败';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🆓 Firestore免费版测试'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 免费版说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🆓 免费版模式',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text('• 不需要Firebase Storage会员'),
                  Text('• 图片自动压缩到100KB以下'),
                  Text('• 直接存储在Firestore中'),
                  Text('• 完全免费，无需绑定信用卡'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 用户状态
            if (_currentUser != null) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('👤 已登录: ${_currentUser!.uid.substring(0, 8)}...'),
              ),
            
            const SizedBox(height: 16),
            
            // 测试按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _anonymousLogin,
                  child: const Text('🔐 匿名登录'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _selectAndCompressImage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100),
                  child: const Text('📷 选择+压缩图片'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createRecipeFree,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
                  child: const Text('📝 创建免费版菜谱'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _readRecipe,
                  child: const Text('📖 验证读取'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _cleanup,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
                  child: const Text('🧹 清理'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 完整测试
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _runFullTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('🚀 开始免费版测试'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 图片对比
            if (_selectedImageBase64 != null && _compressedImageBase64 != null) ...[
              const Text('🖼️ 图片对比:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  // 原图
                  Expanded(
                    child: Column(
                      children: [
                        const Text('原图', style: TextStyle(fontSize: 12)),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              ImageBase64Helper.decodeBase64ToBytes(_selectedImageBase64!)!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(
                          '${ImageBase64Helper.getBase64Size(_selectedImageBase64!).toStringAsFixed(1)}KB',
                          style: const TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 压缩图
                  Expanded(
                    child: Column(
                      children: [
                        const Text('压缩图', style: TextStyle(fontSize: 12)),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              ImageBase64Helper.decodeBase64ToBytes(_compressedImageBase64!)!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(
                          '${ImageBase64Helper.getBase64Size(_compressedImageBase64!).toStringAsFixed(1)}KB',
                          style: const TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // 状态显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _status.contains('成功') ? Colors.green.shade50 : Colors.blue.shade50,
                border: Border.all(
                  color: _status.contains('成功') ? Colors.green : Colors.blue,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 16),
            
            // 日志
            const Text('📋 测试日志:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Text(
                        '点击测试按钮开始...',
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: log.contains('❌') 
                                    ? Colors.red 
                                    : log.contains('✅') 
                                        ? Colors.green 
                                        : log.contains('⚠️')
                                            ? Colors.orange
                                            : log.contains('💡')
                                                ? Colors.blue
                                                : Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
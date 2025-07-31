import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/storage/services/storage_service.dart';
import 'core/firestore/repositories/recipe_repository.dart';
import 'features/recipe/domain/models/recipe.dart';
import 'core/utils/image_base64_helper.dart';

/// 🧪 完整流程测试页面
/// 包含用户认证、图片上传、菜谱创建的完整测试
class TestCompleteFlowPage extends StatefulWidget {
  const TestCompleteFlowPage({super.key});

  @override
  State<TestCompleteFlowPage> createState() => _TestCompleteFlowPageState();
}

class _TestCompleteFlowPageState extends State<TestCompleteFlowPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();
  final RecipeRepository _recipeRepository = RecipeRepository();
  
  String _status = '准备测试完整流程...';
  bool _isLoading = false;
  List<String> _logs = [];
  User? _currentUser;
  String? _selectedImageBase64;
  String? _uploadedImageUrl;
  String? _createdRecipeId;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _addLog('📱 页面初始化完成');
    if (_currentUser != null) {
      _addLog('👤 当前用户: ${_currentUser!.email ?? _currentUser!.uid}');
    } else {
      _addLog('👤 未登录状态');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    print(message);
  }

  /// 🔐 匿名登录测试
  Future<void> _testAnonymousLogin() async {
    try {
      _addLog('🔐 开始匿名登录...');
      final userCredential = await _auth.signInAnonymously();
      setState(() {
        _currentUser = userCredential.user;
      });
      _addLog('✅ 匿名登录成功: ${_currentUser!.uid}');
    } catch (e) {
      _addLog('❌ 匿名登录失败: $e');
    }
  }

  /// 📷 选择图片测试
  Future<void> _testImagePicker() async {
    try {
      _addLog('📷 开始选择图片...');
      final imageBase64 = await ImageBase64Helper.pickImageFromGallery();
      if (imageBase64 != null) {
        setState(() {
          _selectedImageBase64 = imageBase64;
        });
        final size = ImageBase64Helper.getBase64Size(imageBase64);
        _addLog('✅ 图片选择成功: ${size.toStringAsFixed(1)} KB');
      } else {
        _addLog('ℹ️ 用户取消了图片选择');
      }
    } catch (e) {
      _addLog('❌ 图片选择失败: $e');
    }
  }

  /// 📤 上传图片到Storage测试
  Future<void> _testImageUpload() async {
    if (_selectedImageBase64 == null) {
      _addLog('❌ 请先选择图片');
      return;
    }
    
    if (_currentUser == null) {
      _addLog('❌ 请先登录');
      return;
    }

    try {
      _addLog('📤 开始上传图片到Firebase Storage...');
      final userId = _currentUser!.uid;
      final recipeId = 'test_recipe_${DateTime.now().millisecondsSinceEpoch}';
      
      // 显示图片信息
      final imageSize = ImageBase64Helper.getBase64Size(_selectedImageBase64!);
      _addLog('📏 图片大小: ${imageSize.toStringAsFixed(1)} KB');
      
      // 添加超时处理
      final imageUrl = await _storageService.uploadRecipeImage(
        userId: userId,
        recipeId: recipeId,
        imageData: _selectedImageBase64!,
      ).timeout(
        const Duration(seconds: 30), // 30秒超时
        onTimeout: () {
          _addLog('⏰ 上传超时（30秒）');
          return null;
        },
      );
      
      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
        _addLog('✅ 图片上传成功');
        _addLog('🔗 图片URL: ${imageUrl.substring(0, 50)}...');
      } else {
        _addLog('❌ 图片上传失败或超时');
      }
    } catch (e) {
      _addLog('❌ 图片上传异常: $e');
    }
  }

  /// 📝 创建菜谱测试
  Future<void> _testCreateRecipe() async {
    if (_currentUser == null) {
      _addLog('❌ 请先登录');
      return;
    }

    if (_uploadedImageUrl == null) {
      _addLog('❌ 请先上传图片到Storage');
      return;
    }

    try {
      _addLog('📝 开始创建测试菜谱...');
      final userId = _currentUser!.uid;
      
      // 创建测试菜谱
      final testRecipe = Recipe(
        id: '', // 会由Repository生成
        name: '测试菜谱 - ${DateTime.now().toString().substring(11, 19)}',
        description: '这是一个完整流程测试创建的菜谱',
        iconType: 'food',
        totalTime: 30,
        difficulty: '简单',
        servings: 2,
        steps: [
          RecipeStep(
            title: '准备食材',
            description: '准备所需的食材',
            duration: 10,
            tips: '确保食材新鲜',
            ingredients: ['测试食材1', '测试食材2'],
          ),
          RecipeStep(
            title: '开始烹饪',
            description: '按照步骤进行烹饪',
            duration: 20,
            tips: '注意火候',
            ingredients: [],
          ),
        ],
        imageUrl: _uploadedImageUrl, // ✅ 只使用Storage URL
        imageBase64: null, // 🚫 不保存base64，避免Firestore大小限制
        createdBy: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublic: true,
        rating: 4.5,
        cookCount: 0,
      );
      
      // 保存到Firestore
      final recipeId = await _recipeRepository.saveRecipe(testRecipe, userId);
      setState(() {
        _createdRecipeId = recipeId;
      });
      
      _addLog('✅ 菜谱创建成功');
      _addLog('🆔 菜谱ID: $recipeId');
      
    } catch (e) {
      _addLog('❌ 菜谱创建失败: $e');
    }
  }

  /// 📖 读取菜谱测试
  Future<void> _testReadRecipe() async {
    if (_createdRecipeId == null) {
      _addLog('❌ 请先创建菜谱');
      return;
    }

    try {
      _addLog('📖 开始读取菜谱...');
      final recipe = await _recipeRepository.getRecipe(_createdRecipeId!);
      
      if (recipe != null) {
        _addLog('✅ 菜谱读取成功');
        _addLog('📋 菜谱名称: ${recipe.name}');
        _addLog('👤 创建者: ${recipe.createdBy}');
        _addLog('🖼️ 图片URL: ${recipe.imageUrl != null ? "有" : "无"}');
        _addLog('📝 步骤数量: ${recipe.steps.length}');
      } else {
        _addLog('❌ 菜谱不存在');
      }
    } catch (e) {
      _addLog('❌ 菜谱读取失败: $e');
    }
  }

  /// 🧹 清理测试数据
  Future<void> _testCleanup() async {
    try {
      _addLog('🧹 开始清理测试数据...');
      
      // 删除菜谱
      if (_createdRecipeId != null && _currentUser != null) {
        await _recipeRepository.deleteRecipe(_createdRecipeId!, _currentUser!.uid);
        _addLog('✅ 菜谱删除成功');
      }
      
      // 删除图片
      if (_uploadedImageUrl != null) {
        await _storageService.deleteImage(_uploadedImageUrl!);
        _addLog('✅ 图片删除成功');
      }
      
      // 重置状态
      setState(() {
        _selectedImageBase64 = null;
        _uploadedImageUrl = null;
        _createdRecipeId = null;
      });
      
      _addLog('✅ 测试数据清理完成');
      
    } catch (e) {
      _addLog('❌ 清理失败: $e');
    }
  }

  /// 🚀 运行完整流程测试
  Future<void> _runCompleteTest() async {
    setState(() {
      _isLoading = true;
      _status = '正在运行完整流程测试...';
      _logs.clear();
    });

    try {
      // 步骤1: 匿名登录
      _addLog('🚀 开始完整流程测试...');
      await _testAnonymousLogin();
      await Future.delayed(const Duration(seconds: 1));
      
      // 步骤2: 选择图片
      _addLog('📷 正在选择测试图片...');
      await _testImagePicker();
      
      if (_selectedImageBase64 == null) {
        _addLog('❌ 图片选择失败，测试终止');
        setState(() {
          _status = '❌ 需要选择图片才能继续测试';
        });
        return;
      }
      
      await Future.delayed(const Duration(seconds: 1));
      
      // 步骤3: 上传图片到Storage
      await _testImageUpload();
      
      if (_uploadedImageUrl == null) {
        _addLog('❌ 图片上传失败，测试终止');
        setState(() {
          _status = '❌ 图片上传失败';
        });
        return;
      }
      
      await Future.delayed(const Duration(seconds: 1));
      
      // 步骤4: 创建菜谱
      await _testCreateRecipe();
      
      if (_createdRecipeId == null) {
        _addLog('❌ 菜谱创建失败，测试终止');
        setState(() {
          _status = '❌ 菜谱创建失败';
        });
        return;
      }
      
      await Future.delayed(const Duration(seconds: 1));
      
      // 步骤5: 读取菜谱验证
      await _testReadRecipe();
      
      await Future.delayed(const Duration(seconds: 1));
      
      // 步骤6: 清理测试数据
      await _testCleanup();
      
      setState(() {
        _status = '🎉 完整流程测试成功！所有功能正常工作';
      });
      _addLog('🎉 完整流程测试成功完成！');
      
    } catch (e) {
      _addLog('❌ 完整测试失败: $e');
      setState(() {
        _status = '❌ 测试失败: $e';
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
        title: const Text('🧪 完整流程测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户状态显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentUser != null ? Colors.green.shade50 : Colors.orange.shade50,
                border: Border.all(
                  color: _currentUser != null ? Colors.green : Colors.orange,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👤 用户状态: ${_currentUser != null ? "已登录" : "未登录"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_currentUser != null) ...[
                    Text('🆔 用户ID: ${_currentUser!.uid}'),
                    if (_currentUser!.email != null)
                      Text('📧 邮箱: ${_currentUser!.email}'),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 测试状态
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status.contains('成功') || _status.contains('通过') 
                    ? Colors.green.shade50 
                    : _status.contains('失败') 
                        ? Colors.red.shade50 
                        : Colors.blue.shade50,
                border: Border.all(
                  color: _status.contains('成功') || _status.contains('通过')
                      ? Colors.green
                      : _status.contains('失败')
                          ? Colors.red
                          : Colors.blue,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 测试按钮组
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testAnonymousLogin,
                  child: const Text('🔐 匿名登录'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testImagePicker,
                  child: const Text('📷 选择图片'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testImageUpload,
                  child: const Text('📤 上传图片'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testCreateRecipe,
                  child: const Text('📝 创建菜谱'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testReadRecipe,
                  child: const Text('📖 读取菜谱'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testCleanup,
                  child: const Text('🧹 清理数据'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 完整测试按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _runCompleteTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('测试中...'),
                        ],
                      )
                    : const Text('🚀 运行完整流程测试'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 图片预览
            if (_selectedImageBase64 != null) ...[
              const Text(
                '🖼️ 选中的图片:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
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
              const SizedBox(height: 16),
            ],
            
            // 日志显示
            const Text(
              '📋 测试日志:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: log.contains('❌') 
                                    ? Colors.red 
                                    : log.contains('✅') 
                                        ? Colors.green 
                                        : log.contains('💡') || log.contains('ℹ️')
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
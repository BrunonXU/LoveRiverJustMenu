import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/storage/services/storage_service.dart';
import 'core/utils/image_base64_helper.dart';

/// 🧪 简化的图片上传测试
class TestSimpleUploadPage extends StatefulWidget {
  const TestSimpleUploadPage({super.key});

  @override
  State<TestSimpleUploadPage> createState() => _TestSimpleUploadPageState();
}

class _TestSimpleUploadPageState extends State<TestSimpleUploadPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();
  
  String _status = '点击开始测试';
  bool _isLoading = false;
  List<String> _logs = [];
  User? _currentUser;
  String? _selectedImageBase64;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _addLog('🚀 应用启动');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    print(message);
  }

  /// 🧪 简化的上传测试
  Future<void> _testSimpleUpload() async {
    setState(() {
      _isLoading = true;
      _status = '正在测试...';
      _logs.clear();
    });

    try {
      // 步骤1: 匿名登录
      _addLog('🔐 开始匿名登录...');
      final userCredential = await _auth.signInAnonymously();
      _currentUser = userCredential.user;
      _addLog('✅ 匿名登录成功: ${_currentUser!.uid.substring(0, 8)}...');

      // 步骤2: 创建测试图片（小图片）
      _addLog('🎨 创建测试图片...');
      _selectedImageBase64 = _createTestImage();
      final size = ImageBase64Helper.getBase64Size(_selectedImageBase64!);
      _addLog('✅ 测试图片创建成功: ${size.toStringAsFixed(1)} KB');

      // 步骤3: 上传测试
      _addLog('📤 开始上传测试...');
      final userId = _currentUser!.uid;
      final path = 'test/${userId}/simple_test_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final startTime = DateTime.now();
      final imageUrl = await _storageService.uploadImage(
        imageData: _selectedImageBase64!,
        path: path,
      );
      final duration = DateTime.now().difference(startTime);
      
      if (imageUrl != null) {
        _uploadedImageUrl = imageUrl;
        _addLog('✅ 上传成功！耗时: ${duration.inMilliseconds}ms');
        _addLog('🔗 URL: ${imageUrl.substring(0, 50)}...');
        
        setState(() {
          _status = '🎉 测试成功！';
        });
      } else {
        _addLog('❌ 上传失败');
        setState(() {
          _status = '❌ 上传失败';
        });
      }

    } catch (e) {
      _addLog('❌ 测试异常: $e');
      setState(() {
        _status = '❌ 测试失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 🎨 创建一个小的测试图片（1x1像素PNG）
  String _createTestImage() {
    // 1x1像素的透明PNG图片的base64
    return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';
  }

  /// 📷 选择真实图片
  Future<void> _selectRealImage() async {
    try {
      _addLog('📷 选择图片...');
      final imageBase64 = await ImageBase64Helper.pickImageFromGallery();
      if (imageBase64 != null) {
        setState(() {
          _selectedImageBase64 = imageBase64;
        });
        final size = ImageBase64Helper.getBase64Size(imageBase64);
        _addLog('✅ 图片选择成功: ${size.toStringAsFixed(1)} KB');
      } else {
        _addLog('ℹ️ 用户取消选择');
      }
    } catch (e) {
      _addLog('❌ 图片选择失败: $e');
    }
  }

  /// 📤 上传选中的图片
  Future<void> _uploadSelectedImage() async {
    if (_selectedImageBase64 == null) {
      _addLog('❌ 请先选择图片');
      return;
    }

    if (_currentUser == null) {
      _addLog('❌ 请先登录');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('📤 开始上传选中的图片...');
      final userId = _currentUser!.uid;
      final path = 'test/${userId}/real_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final size = ImageBase64Helper.getBase64Size(_selectedImageBase64!);
      _addLog('📏 图片大小: ${size.toStringAsFixed(1)} KB');
      
      final startTime = DateTime.now();
      final imageUrl = await _storageService.uploadImage(
        imageData: _selectedImageBase64!,
        path: path,
      ).timeout(const Duration(seconds: 60)); // 60秒超时
      final duration = DateTime.now().difference(startTime);
      
      if (imageUrl != null) {
        _uploadedImageUrl = imageUrl;
        _addLog('✅ 真实图片上传成功！耗时: ${duration.inSeconds}秒');
        _addLog('🔗 URL: ${imageUrl.substring(0, 50)}...');
      } else {
        _addLog('❌ 真实图片上传失败');
      }

    } catch (e) {
      _addLog('❌ 真实图片上传异常: $e');
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
        title: const Text('🧪 简化上传测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status.contains('成功') || _status.contains('🎉') 
                    ? Colors.green.shade50 
                    : _status.contains('失败') || _status.contains('❌') 
                        ? Colors.red.shade50 
                        : Colors.blue.shade50,
                border: Border.all(
                  color: _status.contains('成功') || _status.contains('🎉')
                      ? Colors.green
                      : _status.contains('失败') || _status.contains('❌')
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
            
            // 用户状态
            if (_currentUser != null) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
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
                  onPressed: _isLoading ? null : _testSimpleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🧪 快速测试（小图片）'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _selectRealImage,
                  child: const Text('📷 选择真实图片'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _uploadSelectedImage,
                  child: const Text('📤 上传真实图片'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 图片预览
            if (_selectedImageBase64 != null && _selectedImageBase64 != _createTestImage()) ...[
              const Text('🖼️ 选中的图片:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            
            // 上传结果
            if (_uploadedImageUrl != null) ...[
              const Text('🔗 上传成功:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _uploadedImageUrl!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
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
                                        : log.contains('ℹ️')
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
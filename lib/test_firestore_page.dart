import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/storage/services/storage_service.dart';
import 'core/firestore/repositories/recipe_repository.dart';
import 'features/recipe/domain/models/recipe.dart';
import 'core/utils/image_base64_helper.dart';

/// 🧪 Firestore连接测试页面
class TestFirestorePage extends StatefulWidget {
  const TestFirestorePage({super.key});

  @override
  State<TestFirestorePage> createState() => _TestFirestorePageState();
}

class _TestFirestorePageState extends State<TestFirestorePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  String _status = '准备测试...';
  bool _isLoading = false;
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    print(message);
  }

  Future<void> _testFirestoreConnection() async {
    setState(() {
      _isLoading = true;
      _status = '正在测试...';
      _logs.clear();
    });

    try {
      _addLog('🔥 开始测试Firebase连接');
      
      // 测试1: Firestore写入
      _addLog('📝 测试Firestore写入...');
      final testDoc = _firestore.collection('test').doc('connection_test');
      await testDoc.set({
        'message': 'Hello from Flutter Web!',
        'timestamp': FieldValue.serverTimestamp(),
        'testData': {
          'number': 123,
          'boolean': true,
          'array': [1, 2, 3],
        }
      });
      _addLog('✅ Firestore写入成功');
      
      // 测试2: Firestore读取
      _addLog('📖 测试Firestore读取...');
      final docSnapshot = await testDoc.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        _addLog('✅ Firestore读取成功: ${data['message']}');
      } else {
        _addLog('❌ 文档不存在');
      }
      
      // 测试3: Firebase Storage连接
      _addLog('🗂️ 测试Firebase Storage连接...');
      final storageRef = _storage.ref().child('test/connection_test.txt');
      
      // 上传测试文件
      const testContent = 'Hello Firebase Storage!';
      await storageRef.putString(testContent);
      _addLog('✅ Storage上传成功');
      
      // 获取下载URL
      final downloadUrl = await storageRef.getDownloadURL();
      _addLog('✅ 获取下载URL成功');
      _addLog('🔗 URL: ${downloadUrl.substring(0, 50)}...');
      
      // 测试4: 清理测试数据
      _addLog('🧹 清理测试数据...');
      await testDoc.delete();
      await storageRef.delete();
      _addLog('✅ 测试数据清理完成');
      
      setState(() {
        _status = '🎉 所有测试通过！Firestore和Storage都工作正常';
      });
      
    } catch (e) {
      _addLog('❌ 测试失败: $e');
      setState(() {
        _status = '❌ 测试失败，请检查配置';
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
        title: const Text('🧪 Firebase连接测试'),
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
            
            // 测试按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testFirestoreConnection,
                child: _isLoading 
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('测试中...'),
                        ],
                      )
                    : const Text('开始测试 Firebase 连接'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 日志显示
            const Text(
              '测试日志:',
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
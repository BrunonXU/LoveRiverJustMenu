import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// 🧪 测试Firestore数据库连接
void main() async {
  print('🔥 开始测试Firebase连接...\n');
  
  try {
    // 初始化Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase初始化成功');
    
    // 获取Firestore实例
    final firestore = FirebaseFirestore.instance;
    print('✅ Firestore实例获取成功');
    
    // 测试写入
    print('\n📝 测试写入数据...');
    final testDoc = firestore.collection('test').doc('connection');
    await testDoc.set({
      'message': 'Hello from Flutter!',
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('✅ 数据写入成功');
    
    // 测试读取
    print('\n📖 测试读取数据...');
    final docSnapshot = await testDoc.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      print('✅ 数据读取成功: ${data['message']}');
      print('📅 时间戳: ${data['timestamp']}');
    }
    
    // 清理测试数据
    print('\n🧹 清理测试数据...');
    await testDoc.delete();
    print('✅ 测试数据已删除');
    
    print('\n🎉 Firestore连接测试完全成功！');
    
  } catch (e) {
    print('❌ 连接测试失败: $e');
    print('\n🔧 可能的解决方案:');
    print('1. 确保已在Firebase Console创建Firestore数据库');
    print('2. 检查firebase_options.dart配置是否正确');
    print('3. 确保网络连接正常');
    print('4. 检查Firestore安全规则是否允许写入');
  }
}
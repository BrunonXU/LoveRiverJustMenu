import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 诊断Firebase认证配置问题
void main() async {
  print('🔍 开始诊断Firebase认证配置...\n');
  
  // 1. 检查当前部署域名
  print('📍 当前访问域名检查：');
  print('- 本地开发: http://localhost:5000');
  print('- GitHub Pages: https://brunonxu.github.io/LoveRiverJustMenu/');
  print('');
  
  // 2. 读取Firebase配置
  print('🔥 Firebase配置检查：');
  try {
    final firebaseConfig = File('lib/firebase_options.dart').readAsStringSync();
    if (firebaseConfig.contains('authDomain:')) {
      final authDomain = RegExp(r"authDomain:\s*'([^']+)'")
          .firstMatch(firebaseConfig)
          ?.group(1);
      print('✅ Auth Domain: $authDomain');
    }
    if (firebaseConfig.contains('apiKey:')) {
      print('✅ API Key: 已配置');
    }
    if (firebaseConfig.contains('projectId:')) {
      final projectId = RegExp(r"projectId:\s*'([^']+)'")
          .firstMatch(firebaseConfig)
          ?.group(1);
      print('✅ Project ID: $projectId');
      print('');
      
      print('⚡ 需要在以下位置添加授权域名：');
      print('1. Firebase Console:');
      print('   https://console.firebase.google.com/project/$projectId/authentication/settings');
      print('   → 添加 brunonxu.github.io 到 Authorized domains');
      print('');
      print('2. Google Cloud Console:');
      print('   https://console.cloud.google.com/apis/credentials?project=$projectId');
      print('   → 编辑OAuth 2.0客户端ID');
      print('   → 添加以下内容:');
      print('');
      print('   Authorized JavaScript origins:');
      print('   - https://brunonxu.github.io');
      print('');
      print('   Authorized redirect URIs:');
      print('   - https://brunonxu.github.io/LoveRiverJustMenu/__/auth/handler');
      print('   - https://brunonxu.github.io/LoveRiverJustMenu/');
    }
  } catch (e) {
    print('❌ 无法读取Firebase配置: $e');
  }
  
  print('\n📋 常见错误对照表：');
  print('┌─────────────────────────────┬──────────────────────────────────┐');
  print('│ 错误信息                     │ 解决方案                          │');
  print('├─────────────────────────────┼──────────────────────────────────┤');
  print('│ redirect_uri_mismatch       │ 在Google Console添加重定向URI     │');
  print('│ unauthorized domain         │ 在Firebase添加授权域名            │');
  print('│ popup_closed_by_user        │ 正常，用户取消了登录              │');
  print('│ People API has not been used│ 启用People API或减少权限范围      │');
  print('└─────────────────────────────┴──────────────────────────────────┘');
  
  print('\n💡 快速修复建议：');
  print('1. 先在Firebase Console添加域名');
  print('2. 再在Google Cloud Console配置OAuth');
  print('3. 等待5-10分钟让配置生效');
  print('4. 清除浏览器缓存后重试');
}
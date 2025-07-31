import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// 🖼️ Firebase Storage 服务
/// 
/// 处理图片上传到云端存储
/// 返回可访问的URL而不是base64
class StorageService {
  final FirebaseStorage _storage;
  
  StorageService({FirebaseStorage? storage}) 
      : _storage = storage ?? FirebaseStorage.instance;

  /// 📤 上传图片到Firebase Storage
  /// 
  /// [imageData] 图片数据（base64或bytes）
  /// [path] 存储路径（如：recipes/userId/recipeId/image.jpg）
  /// 返回图片的下载URL
  Future<String?> uploadImage({
    required dynamic imageData,
    required String path,
  }) async {
    try {
      debugPrint('🚀 开始上传图片: $path');
      
      Uint8List bytes;
      
      // 处理不同格式的图片数据
      if (imageData is String) {
        debugPrint('🔄 转换base64为字节数组...');
        bytes = _decodeBase64(imageData);
        debugPrint('📏 图片字节大小: ${bytes.length} bytes (${(bytes.length/1024).toStringAsFixed(1)} KB)');
      } else if (imageData is Uint8List) {
        bytes = imageData;
        debugPrint('📏 图片字节大小: ${bytes.length} bytes');
      } else {
        throw Exception('不支持的图片数据格式: ${imageData.runtimeType}');
      }
      
      // 创建存储引用
      debugPrint('📂 创建Storage引用: $path');
      final storageRef = _storage.ref().child(path);
      
      // 设置元数据
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalSize': bytes.length.toString(),
        },
      );
      
      debugPrint('📤 开始上传到Firebase Storage...');
      
      // 上传图片
      final uploadTask = await storageRef.putData(bytes, metadata);
      
      debugPrint('🔗 获取下载URL...');
      
      // 获取下载URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      debugPrint('✅ 图片上传成功: $path');
      debugPrint('📍 下载URL: $downloadUrl');
      
      return downloadUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ 图片上传失败: $e');
      debugPrint('📋 堆栈跟踪: $stackTrace');
      return null;
    }
  }

  /// 📤 上传菜谱图片
  /// 
  /// [userId] 用户ID
  /// [recipeId] 菜谱ID
  /// [imageData] 图片数据
  /// [imageName] 图片名称（可选）
  Future<String?> uploadRecipeImage({
    required String userId,
    required String recipeId,
    required dynamic imageData,
    String? imageName,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = imageName ?? 'main_$timestamp.jpg';
    final path = 'recipes/$userId/$recipeId/$fileName';
    
    return uploadImage(imageData: imageData, path: path);
  }

  /// 📤 上传菜谱步骤图片
  /// 
  /// [userId] 用户ID
  /// [recipeId] 菜谱ID
  /// [stepIndex] 步骤索引
  /// [imageData] 图片数据
  Future<String?> uploadRecipeStepImage({
    required String userId,
    required String recipeId,
    required int stepIndex,
    required dynamic imageData,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'recipes/$userId/$recipeId/steps/step_${stepIndex}_$timestamp.jpg';
    
    return uploadImage(imageData: imageData, path: path);
  }

  /// 📤 上传用户头像
  /// 
  /// [userId] 用户ID
  /// [imageData] 图片数据
  Future<String?> uploadUserAvatar({
    required String userId,
    required dynamic imageData,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'users/$userId/avatar_$timestamp.jpg';
    
    return uploadImage(imageData: imageData, path: path);
  }

  /// 🗑️ 删除图片
  /// 
  /// [imageUrl] 图片URL
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // 从URL中提取存储路径
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      debugPrint('✅ 图片删除成功: $imageUrl');
      return true;
    } catch (e) {
      debugPrint('❌ 图片删除失败: $e');
      return false;
    }
  }

  /// 🗑️ 删除菜谱的所有图片
  /// 
  /// [userId] 用户ID
  /// [recipeId] 菜谱ID
  Future<bool> deleteRecipeImages({
    required String userId,
    required String recipeId,
  }) async {
    try {
      final folderRef = _storage.ref().child('recipes/$userId/$recipeId');
      
      // 列出文件夹中的所有文件
      final listResult = await folderRef.listAll();
      
      // 删除所有文件
      for (final item in listResult.items) {
        await item.delete();
      }
      
      debugPrint('✅ 菜谱图片删除成功: recipes/$userId/$recipeId');
      return true;
    } catch (e) {
      debugPrint('❌ 菜谱图片删除失败: $e');
      return false;
    }
  }

  /// 🔄 将base64解码为字节数组
  Uint8List _decodeBase64(String base64String) {
    // 移除数据URL前缀（如果存在）
    String cleanBase64 = base64String;
    if (base64String.startsWith('data:image/')) {
      final commaIndex = base64String.indexOf(',');
      if (commaIndex != -1) {
        cleanBase64 = base64String.substring(commaIndex + 1);
      }
    }
    
    return Uint8List.fromList(base64Decode(cleanBase64));
  }
  
  /// 📏 获取图片大小（字节）
  Future<int?> getImageSize(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      final metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      debugPrint('❌ 获取图片大小失败: $e');
      return null;
    }
  }

  /// 🔗 生成图片的缩略图URL（Firebase自动生成）
  String getThumbnailUrl(String imageUrl, {int width = 200}) {
    // Firebase Storage支持通过URL参数生成缩略图
    // 注意：需要安装Firebase Extensions - Resize Images
    if (imageUrl.contains('firebasestorage.googleapis.com')) {
      return '$imageUrl?w=$width';
    }
    return imageUrl;
  }
}
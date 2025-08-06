/// 🔄 网络重试工具
/// 
/// 提供基础的网络请求重试机制
/// 支持指数退避和自定义重试策略
/// 
/// 作者: Claude Code
/// 创建时间: 2025-08-06

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// 🔄 重试策略配置
class RetryConfig {
  /// 最大重试次数
  final int maxAttempts;
  
  /// 初始延迟时间（毫秒）
  final int initialDelayMs;
  
  /// 最大延迟时间（毫秒）
  final int maxDelayMs;
  
  /// 延迟倍数（指数退避）
  final double backoffMultiplier;
  
  /// 是否启用随机抖动
  final bool enableJitter;
  
  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelayMs = 1000,
    this.maxDelayMs = 30000,
    this.backoffMultiplier = 2.0,
    this.enableJitter = true,
  });
  
  /// MVP基础配置 - 快速重试，避免用户等待
  static const RetryConfig mvpBasic = RetryConfig(
    maxAttempts: 2,
    initialDelayMs: 500,
    maxDelayMs: 2000,
    backoffMultiplier: 1.5,
    enableJitter: false,
  );
  
  /// 重要操作配置 - 更多重试次数
  static const RetryConfig important = RetryConfig(
    maxAttempts: 3,
    initialDelayMs: 1000,
    maxDelayMs: 5000,
    backoffMultiplier: 2.0,
    enableJitter: true,
  );
}

/// 🌐 网络重试工具类
class NetworkRetry {
  /// 执行带重试的异步操作
  /// 
  /// [operation] 要执行的操作
  /// [config] 重试配置
  /// [shouldRetry] 自定义重试条件判断函数
  /// 
  /// 返回操作结果
  static Future<T> execute<T>(
    Future<T> Function() operation,
    {
      RetryConfig config = const RetryConfig(),
      bool Function(dynamic error)? shouldRetry,
    }
  ) async {
    int attemptCount = 0;
    dynamic lastError;
    
    while (attemptCount < config.maxAttempts) {
      attemptCount++;
      
      try {
        debugPrint('🔄 网络请求尝试 $attemptCount/${config.maxAttempts}');
        final result = await operation();
        
        if (attemptCount > 1) {
          debugPrint('✅ 网络请求重试成功，尝试次数: $attemptCount');
        }
        
        return result;
        
      } catch (error) {
        lastError = error;
        
        debugPrint('❌ 网络请求失败 (尝试 $attemptCount/${config.maxAttempts}): $error');
        
        // 检查是否应该重试
        if (attemptCount >= config.maxAttempts) {
          debugPrint('🚫 达到最大重试次数，放弃重试');
          break;
        }
        
        // 使用自定义重试条件或默认条件
        if (shouldRetry != null && !shouldRetry(error)) {
          debugPrint('🚫 自定义条件判断不需要重试');
          break;
        } else if (shouldRetry == null && !_shouldRetryByDefault(error)) {
          debugPrint('🚫 默认条件判断不需要重试');
          break;
        }
        
        // 计算延迟时间并等待
        if (attemptCount < config.maxAttempts) {
          final delay = _calculateDelay(attemptCount, config);
          debugPrint('⏳ 等待 ${delay.inMilliseconds}ms 后重试...');
          await Future.delayed(delay);
        }
      }
    }
    
    debugPrint('💥 网络请求最终失败: $lastError');
    throw lastError;
  }
  
  /// 计算重试延迟时间（指数退避 + 可选抖动）
  static Duration _calculateDelay(int attemptCount, RetryConfig config) {
    // 基础延迟 = 初始延迟 * (倍数 ^ (尝试次数 - 1))
    int baseDelay = (config.initialDelayMs * pow(config.backoffMultiplier, attemptCount - 1)).round();
    
    // 限制最大延迟
    baseDelay = min(baseDelay, config.maxDelayMs);
    
    // 添加随机抖动（避免雷群效应）
    if (config.enableJitter) {
      final jitter = Random().nextDouble() * 0.5; // 0-50%的抖动
      baseDelay = (baseDelay * (1 + jitter)).round();
    }
    
    return Duration(milliseconds: baseDelay);
  }
  
  /// 默认重试条件判断
  /// 
  /// 以下情况会重试：
  /// - 网络连接错误
  /// - 超时错误
  /// - 服务器5xx错误
  /// 
  /// 以下情况不会重试：
  /// - 4xx客户端错误（如401、404等）
  /// - 业务逻辑错误
  static bool _shouldRetryByDefault(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // 网络连接相关错误 - 应该重试
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket') ||
        errorString.contains('dns') ||
        errorString.contains('host')) {
      return true;
    }
    
    // Firebase 相关的临时错误 - 应该重试
    if (errorString.contains('unavailable') ||
        errorString.contains('deadline-exceeded') ||
        errorString.contains('internal') ||
        errorString.contains('aborted')) {
      return true;
    }
    
    // HTTP状态码相关
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504')) {
      return true;
    }
    
    // 客户端错误不重试
    if (errorString.contains('400') ||
        errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('404')) {
      return false;
    }
    
    // 默认不重试未知错误（保守策略）
    return false;
  }
  
  /// 🚀 便捷方法：MVP基础重试
  /// 
  /// 适用于大部分MVP场景的快速重试
  static Future<T> mvpRetry<T>(Future<T> Function() operation) {
    return execute(
      operation,
      config: RetryConfig.mvpBasic,
    );
  }
  
  /// ⭐ 便捷方法：重要操作重试
  /// 
  /// 适用于关键操作（如登录、数据同步）的重试
  static Future<T> importantRetry<T>(Future<T> Function() operation) {
    return execute(
      operation,
      config: RetryConfig.important,
    );
  }
}

/// 🎯 重试装饰器扩展
/// 
/// 为Future添加重试能力的便捷扩展
extension FutureRetryExtension<T> on Future<T> {
  /// 添加基础重试能力
  Future<T> withRetry([RetryConfig? config]) {
    return NetworkRetry.execute(
      () => this,
      config: config ?? const RetryConfig(),
    );
  }
  
  /// 添加MVP级别重试
  Future<T> withMvpRetry() {
    return NetworkRetry.mvpRetry(() => this);
  }
  
  /// 添加重要操作重试
  Future<T> withImportantRetry() {
    return NetworkRetry.importantRetry(() => this);
  }
}
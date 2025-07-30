/// 🚨 认证异常类
/// 
/// 定义应用中所有认证相关的异常类型
/// 提供统一的错误处理和用户友好的错误消息
/// 
/// 主要异常类型：
/// - AuthException: 通用认证异常
/// - NetworkException: 网络相关异常
/// - ValidationException: 数据验证异常
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

/// 🔐 认证异常基类
/// 
/// 所有认证相关异常的基类
/// 包含错误消息和错误代码，便于错误处理和国际化
class AuthException implements Exception {
  /// 用户友好的错误消息
  final String message;
  
  /// 错误代码 (用于程序判断和国际化)
  final String code;
  
  /// 底层异常信息 (可选)
  final dynamic originalException;
  
  /// 构造函数
  /// 
  /// [message] 用户友好的错误消息
  /// [code] 错误代码
  /// [originalException] 底层异常信息
  AuthException(
    this.message,
    this.code, [
    this.originalException,
  ]);
  
  @override
  String toString() {
    return 'AuthException: $message (code: $code)';
  }
  
  /// 📱 创建无网络连接异常
  factory AuthException.noNetwork() {
    return AuthException(
      '网络连接失败，请检查网络后重试',
      'NO_NETWORK',
    );
  }
  
  /// ⏰ 创建请求超时异常
  factory AuthException.timeout() {
    return AuthException(
      '请求超时，请检查网络连接后重试',
      'TIMEOUT',
    );
  }
  
  /// 🔒 创建权限不足异常
  factory AuthException.permissionDenied() {
    return AuthException(
      '权限不足，无法执行此操作',
      'PERMISSION_DENIED',
    );
  }
  
  /// 🏠 创建服务不可用异常
  factory AuthException.serviceUnavailable() {
    return AuthException(
      '服务暂时不可用，请稍后重试',
      'SERVICE_UNAVAILABLE',
    );
  }
  
  /// 🔍 创建用户未找到异常
  factory AuthException.userNotFound() {
    return AuthException(
      '用户不存在，请检查邮箱地址',
      'USER_NOT_FOUND',
    );
  }
  
  /// 🔐 创建密码错误异常
  factory AuthException.wrongPassword() {
    return AuthException(
      '密码错误，请重新输入',
      'WRONG_PASSWORD',
    );
  }
  
  /// 📧 创建邮箱已存在异常
  factory AuthException.emailAlreadyInUse() {
    return AuthException(
      '该邮箱已被注册，请使用其他邮箱',
      'EMAIL_ALREADY_IN_USE',
    );
  }
  
  /// 🔒 创建密码过弱异常
  factory AuthException.weakPassword() {
    return AuthException(
      '密码强度不够，请使用至少6位字符',
      'WEAK_PASSWORD',
    );
  }
  
  /// 📮 创建邮箱格式错误异常
  factory AuthException.invalidEmail() {
    return AuthException(
      '邮箱格式不正确，请检查后重新输入',
      'INVALID_EMAIL',
    );
  }
  
  /// 🚫 创建账户被禁用异常
  factory AuthException.userDisabled() {
    return AuthException(
      '该账户已被禁用，请联系客服',
      'USER_DISABLED',
    );
  }
}

/// 🌐 网络异常类
/// 
/// 处理网络请求相关的异常
class NetworkException extends AuthException {
  /// HTTP 状态码 (可选)
  final int? statusCode;
  
  /// 构造函数
  /// 
  /// [message] 错误消息
  /// [code] 错误代码
  /// [statusCode] HTTP 状态码
  /// [originalException] 底层异常
  NetworkException(
    String message,
    String code, {
    this.statusCode,
    dynamic originalException,
  }) : super(message, code, originalException);
  
  @override
  String toString() {
    return 'NetworkException: $message (code: $code, status: $statusCode)';
  }
  
  /// 📡 创建连接超时异常
  factory NetworkException.connectionTimeout() {
    return NetworkException(
      '连接超时，请检查网络连接',
      'CONNECTION_TIMEOUT',
    );
  }
  
  /// 📶 创建网络不可达异常
  factory NetworkException.networkUnreachable() {
    return NetworkException(
      '网络不可达，请检查网络设置',
      'NETWORK_UNREACHABLE',
    );
  }
  
  /// 🔌 创建服务器连接失败异常
  factory NetworkException.serverConnectionFailed() {
    return NetworkException(
      '无法连接到服务器，请稍后重试',
      'SERVER_CONNECTION_FAILED',
    );
  }
  
  /// 📋 创建数据解析失败异常
  factory NetworkException.dataParsingFailed() {
    return NetworkException(
      '数据解析失败，请稍后重试',
      'DATA_PARSING_FAILED',
    );
  }
}

/// ✅ 数据验证异常类
/// 
/// 处理用户输入数据验证相关的异常
class ValidationException extends AuthException {
  /// 验证失败的字段名
  final String? fieldName;
  
  /// 构造函数
  /// 
  /// [message] 错误消息
  /// [code] 错误代码
  /// [fieldName] 验证失败的字段名
  /// [originalException] 底层异常
  ValidationException(
    String message,
    String code, {
    this.fieldName,
    dynamic originalException,
  }) : super(message, code, originalException);
  
  @override
  String toString() {
    return 'ValidationException: $message (field: $fieldName, code: $code)';
  }
  
  /// 📮 创建邮箱格式错误异常
  factory ValidationException.invalidEmailFormat() {
    return ValidationException(
      '请输入正确的邮箱格式',
      'INVALID_EMAIL_FORMAT',
      fieldName: 'email',
    );
  }
  
  /// 🔒 创建密码格式错误异常
  factory ValidationException.invalidPasswordFormat() {
    return ValidationException(
      '密码至少需要6个字符',
      'INVALID_PASSWORD_FORMAT',
      fieldName: 'password',
    );
  }
  
  /// 🔑 创建密码不匹配异常
  factory ValidationException.passwordMismatch() {
    return ValidationException(
      '两次输入的密码不一致',
      'PASSWORD_MISMATCH',
      fieldName: 'confirmPassword',
    );
  }
  
  /// 📝 创建必填字段为空异常
  factory ValidationException.requiredFieldEmpty(String fieldName) {
    return ValidationException(
      '${_getFieldDisplayName(fieldName)}不能为空',
      'REQUIRED_FIELD_EMPTY',
      fieldName: fieldName,
    );
  }
  
  /// 📏 创建字段长度错误异常
  factory ValidationException.invalidFieldLength(
    String fieldName,
    int minLength,
    int maxLength,
  ) {
    return ValidationException(
      '${_getFieldDisplayName(fieldName)}长度应在 $minLength-$maxLength 个字符之间',
      'INVALID_FIELD_LENGTH',
      fieldName: fieldName,
    );
  }
  
  /// 🏷️ 获取字段的显示名称
  /// 
  /// [fieldName] 字段名
  /// 
  /// 返回用户友好的字段显示名称
  static String _getFieldDisplayName(String fieldName) {
    switch (fieldName) {
      case 'email':
        return '邮箱地址';
      case 'password':
        return '密码';
      case 'confirmPassword':
        return '确认密码';
      case 'displayName':
        return '昵称';
      case 'phoneNumber':
        return '手机号码';
      default:
        return fieldName;
    }
  }
}

/// 🏪 存储异常类
/// 
/// 处理本地存储和云端存储相关的异常
class StorageException extends AuthException {
  /// 存储类型 (local/cloud)
  final String storageType;
  
  /// 构造函数
  /// 
  /// [message] 错误消息
  /// [code] 错误代码
  /// [storageType] 存储类型
  /// [originalException] 底层异常
  StorageException(
    String message,
    String code, {
    required this.storageType,
    dynamic originalException,
  }) : super(message, code, originalException);
  
  @override
  String toString() {
    return 'StorageException: $message (type: $storageType, code: $code)';
  }
  
  /// 💾 创建本地存储失败异常
  factory StorageException.localStorageFailed() {
    return StorageException(
      '本地数据存储失败，请检查设备存储空间',
      'LOCAL_STORAGE_FAILED',
      storageType: 'local',
    );
  }
  
  /// ☁️ 创建云端存储失败异常
  factory StorageException.cloudStorageFailed() {
    return StorageException(
      '云端数据同步失败，请检查网络连接',
      'CLOUD_STORAGE_FAILED',
      storageType: 'cloud',
    );
  }
  
  /// 📁 创建存储空间不足异常
  factory StorageException.insufficientStorage() {
    return StorageException(
      '存储空间不足，请清理设备空间后重试',
      'INSUFFICIENT_STORAGE',
      storageType: 'local',
    );
  }
  
  /// 🔒 创建存储权限不足异常
  factory StorageException.storagePermissionDenied() {
    return StorageException(
      '存储权限不足，请在设置中开启存储权限',
      'STORAGE_PERMISSION_DENIED',
      storageType: 'local',
    );
  }
}

/// 🌍 国际化异常工具类
/// 
/// 提供异常消息的国际化支持
class ExceptionLocalizer {
  /// 🌏 获取本地化错误消息
  /// 
  /// [exception] 异常对象
  /// [locale] 语言区域 (默认中文)
  /// 
  /// 返回本地化的错误消息
  static String getLocalizedMessage(
    AuthException exception, [
    String locale = 'zh_CN',
  ]) {
    // 这里可以根据 locale 返回不同语言的错误消息
    // 目前只支持中文
    return exception.message;
  }
  
  /// 📱 判断是否为用户可见错误
  /// 
  /// [exception] 异常对象
  /// 
  /// 返回该错误是否应该直接显示给用户
  static bool isUserFacingError(AuthException exception) {
    // 系统内部错误不应该直接显示给用户
    const systemErrorCodes = [
      'INIT_FAILED',
      'UNKNOWN_ERROR',
      'DATA_PARSING_FAILED',
    ];
    
    return !systemErrorCodes.contains(exception.code);
  }
  
  /// 🛠️ 获取用户友好的错误消息
  /// 
  /// [exception] 异常对象
  /// 
  /// 返回用户友好的错误消息，系统错误会被转换为通用消息
  static String getUserFriendlyMessage(AuthException exception) {
    if (isUserFacingError(exception)) {
      return exception.message;
    } else {
      return '系统繁忙，请稍后重试';
    }
  }
}
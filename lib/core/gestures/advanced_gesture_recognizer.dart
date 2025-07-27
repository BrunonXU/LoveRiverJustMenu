import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// 高级手势识别器
/// 支持多点触摸、复杂手势识别
class AdvancedGestureRecognizer extends StatefulWidget {
  final Widget child;
  final Function(GestureType type, GestureData data)? onGesture;
  
  const AdvancedGestureRecognizer({
    super.key,
    required this.child,
    this.onGesture,
  });

  @override
  State<AdvancedGestureRecognizer> createState() => _AdvancedGestureRecognizerState();
}

class _AdvancedGestureRecognizerState extends State<AdvancedGestureRecognizer> {
  final List<TouchPoint> _touches = [];
  Offset? _initialPinchDistance;
  double? _initialRotation;
  
  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        MultiTouchGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            MultiTouchGestureRecognizer>(
          () => MultiTouchGestureRecognizer(),
          (MultiTouchGestureRecognizer instance) {
            instance.onUpdate = (details) => _handleTouchUpdate(details);
            instance.onEnd = (details) => _handleTouchEnd(details);
          },
        ),
      },
      child: widget.child,
    );
  }
  
  void _handleTouchUpdate(MultiTouchGestureRecognizerUpdate details) {
    setState(() {
      _touches.clear();
      _touches.addAll(details.touches);
    });
    
    // 识别手势类型
    if (_touches.length == 2) {
      _recognizePinchOrRotate();
    } else if (_touches.length == 5) {
      _recognizeFiveFingerGesture();
    }
  }
  
  void _handleTouchEnd(MultiTouchGestureRecognizerEnd details) {
    setState(() {
      _touches.clear();
    });
    _initialPinchDistance = null;
    _initialRotation = null;
  }
  
  void _recognizePinchOrRotate() {
    if (_touches.length != 2) return;
    
    final distance = (_touches[0].position - _touches[1].position).distance;
    final angle = math.atan2(
      _touches[1].position.dy - _touches[0].position.dy,
      _touches[1].position.dx - _touches[0].position.dx,
    );
    
    if (_initialPinchDistance == null) {
      _initialPinchDistance = Offset(distance, 0);
      _initialRotation = angle;
      return;
    }
    
    // 判断是捏合还是旋转
    final distanceChange = distance - _initialPinchDistance!.dx;
    final rotationChange = angle - _initialRotation!;
    
    if (distanceChange.abs() > 20) {
      // 捏合手势
      widget.onGesture?.call(
        distanceChange > 0 ? GestureType.pinchOut : GestureType.pinchIn,
        GestureData(scale: distance / _initialPinchDistance!.dx),
      );
      HapticFeedback.lightImpact();
    } else if (rotationChange.abs() > 0.2) {
      // 旋转手势
      widget.onGesture?.call(
        GestureType.rotate,
        GestureData(rotation: rotationChange),
      );
      HapticFeedback.lightImpact();
    }
  }
  
  void _recognizeFiveFingerGesture() {
    // 五指捏合 - 特殊手势
    widget.onGesture?.call(GestureType.fiveFingerPinch, GestureData());
    HapticFeedback.heavyImpact();
  }
}

/// 手势类型枚举
enum GestureType {
  swipeUp,
  swipeDown,
  swipeLeft,
  swipeRight,
  pinchIn,
  pinchOut,
  rotate,
  longPress,
  doubleTap,
  fiveFingerPinch,
  edgeSwipe,
  shake,
}

/// 手势数据
class GestureData {
  final double? scale;
  final double? rotation;
  final Offset? translation;
  final double? velocity;
  
  GestureData({
    this.scale,
    this.rotation,
    this.translation,
    this.velocity,
  });
}

/// 触摸点数据
class TouchPoint {
  final int id;
  final Offset position;
  final double pressure;
  
  TouchPoint({
    required this.id,
    required this.position,
    this.pressure = 1.0,
  });
}

/// 多点触摸手势识别器
class MultiTouchGestureRecognizer extends OneSequenceGestureRecognizer {
  final Map<int, TouchPoint> _touches = {};
  Function(MultiTouchGestureRecognizerUpdate details)? onUpdate;
  Function(MultiTouchGestureRecognizerEnd details)? onEnd;
  
  @override
  void addPointer(PointerDownEvent event) {
    _touches[event.pointer] = TouchPoint(
      id: event.pointer,
      position: event.position,
      pressure: event.pressure,
    );
    startTrackingPointer(event.pointer);
    onUpdate?.call(MultiTouchGestureRecognizerUpdate(_touches.values.toList()));
  }
  
  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _touches[event.pointer] = TouchPoint(
        id: event.pointer,
        position: event.position,
        pressure: event.pressure,
      );
      onUpdate?.call(MultiTouchGestureRecognizerUpdate(_touches.values.toList()));
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _touches.remove(event.pointer);
      stopTrackingPointer(event.pointer);
      if (_touches.isEmpty) {
        onEnd?.call(MultiTouchGestureRecognizerEnd());
      }
    }
  }
  
  @override
  String get debugDescription => 'MultiTouchGestureRecognizer';
  
  @override
  void didStopTrackingLastPointer(int pointer) {}
}

/// 多点触摸更新事件
class MultiTouchGestureRecognizerUpdate {
  final List<TouchPoint> touches;
  MultiTouchGestureRecognizerUpdate(this.touches);
}

/// 多点触摸结束事件
class MultiTouchGestureRecognizerEnd {
  MultiTouchGestureRecognizerEnd();
}

/// 手势识别工具类
class GestureUtils {
  /// 判断是否为有效滑动
  static bool isValidSwipe(Offset delta, {double threshold = 50.0}) {
    return delta.distance > threshold;
  }
  
  /// 获取滑动方向
  static GestureType getSwipeDirection(Offset delta) {
    if (delta.dx.abs() > delta.dy.abs()) {
      return delta.dx > 0 ? GestureType.swipeRight : GestureType.swipeLeft;
    } else {
      return delta.dy > 0 ? GestureType.swipeDown : GestureType.swipeUp;
    }
  }
  
  /// 计算两点间角度
  static double calculateAngle(Offset point1, Offset point2) {
    return math.atan2(point2.dy - point1.dy, point2.dx - point1.dx);
  }
  
  /// 计算两点间距离
  static double calculateDistance(Offset point1, Offset point2) {
    return (point1 - point2).distance;
  }
}
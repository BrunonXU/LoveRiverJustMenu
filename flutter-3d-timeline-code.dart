// 3d_timeline.dart - 3D时光机组件
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  double _rotationY = 0;
  double _scale = 1.0;
  
  final List<Memory> memories = [
    Memory(
      id: '1',
      date: DateTime(2024, 2, 14),
      title: '情人节烛光晚餐',
      emoji: '🕯️',
      special: true,
      mood: '浪漫',
    ),
    Memory(
      id: '2',
      date: DateTime(2024, 1, 1),
      title: '新年第一餐',
      emoji: '🎊',
      special: false,
      mood: '温馨',
    ),
    Memory(
      id: '3',
      date: DateTime(2023, 12, 25),
      title: '圣诞大餐',
      emoji: '🎄',
      special: true,
      mood: '欢乐',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0033),
              Color(0xFF2D1B69),
              Color(0xFF0F0C29),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 标题
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  '美食时光机',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // 3D时间轴
              Expanded(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _rotationY += details.delta.dx * 0.01;
                    });
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale = details.scale.clamp(0.5, 2.0);
                    });
                  },
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_rotationY)
                      ..scale(_scale),
                    child: Stack(
                      alignment: Alignment.center,
                      children: memories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final memory = entry.value;
                        return _build3DMemoryCard(memory, index);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              // 控制按钮
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _build3DMemoryCard(Memory memory, int index) {
    final angle = (index / memories.length) * 2 * math.pi;
    final radius = 150.0;
    final x = math.sin(angle) * radius;
    final z = math.cos(angle) * radius;
    final y = index * 50.0 - 100;
    
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final floatOffset = math.sin(_floatingController.value * math.pi) * 10;
        
        return Transform(
          transform: Matrix4.identity()
            ..translate(x, y + floatOffset, z)
            ..rotateY(-angle),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => _showMemoryDetail(memory),
            child: Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(
                gradient: memory.special
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Colors.white24, Colors.white10],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: memory.special
                        ? const Color(0xFFFF6B6B).withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: memory.special ? 5 : 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    memory.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    memory.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(memory.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      memory.mood,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _rotationY -= math.pi / 3;
              });
              HapticFeedback.lightImpact();
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              if (_rotationController.isAnimating) {
                _rotationController.stop();
              } else {
                _rotationController.repeat();
              }
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              _rotationController.isAnimating ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _rotationY += math.pi / 3;
              });
              HapticFeedback.lightImpact();
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
  
  void _showMemoryDetail(Memory memory) {
    HapticFeedback.mediumImpact();
    // 显示记忆详情
  }
}

// 记忆数据模型
class Memory {
  final String id;
  final DateTime date;
  final String title;
  final String emoji;
  final bool special;
  final String mood;
  
  Memory({
    required this.id,
    required this.date,
    required this.title,
    required this.emoji,
    required this.special,
    required this.mood,
  });
}

// gesture_system.dart - 手势系统
class GestureRecognizer extends StatefulWidget {
  final Widget child;
  final Function(GestureType type, GestureData data)? onGesture;
  
  const GestureRecognizer({
    Key? key,
    required this.child,
    this.onGesture,
  }) : super(key: key);

  @override
  State<GestureRecognizer> createState() => _GestureRecognizerState();
}

class _GestureRecognizerState extends State<GestureRecognizer> {
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
    } else if (rotationChange.abs() > 0.2) {
      // 旋转手势
      widget.onGesture?.call(
        GestureType.rotate,
        GestureData(rotation: rotationChange),
      );
    }
  }
  
  void _recognizeFiveFingerGesture() {
    // 五指捏合
    widget.onGesture?.call(GestureType.fiveFingerPinch, GestureData());
    HapticFeedback.heavyImpact();
  }
}

// 手势类型枚举
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

// 手势数据
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

// 触摸点
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

// 多点触摸手势识别器
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

class MultiTouchGestureRecognizerUpdate {
  final List<TouchPoint> touches;
  MultiTouchGestureRecognizerUpdate(this.touches);
}

class MultiTouchGestureRecognizerEnd {
  MultiTouchGestureRecognizerEnd();
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/province_cuisine.dart';

/// 省份详情页面 - 临时简化版本
class ProvinceDetailScreen extends ConsumerStatefulWidget {
  final ChineseProvince province;

  const ProvinceDetailScreen({
    super.key,
    required this.province,
  });

  @override
  ConsumerState<ProvinceDetailScreen> createState() => _ProvinceDetailScreenState();
}

class _ProvinceDetailScreenState extends ConsumerState<ProvinceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.province.toString().split('.').last} 美食'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '美食地图功能开发中...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
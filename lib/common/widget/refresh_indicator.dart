import 'package:flutter/material.dart';

/// 下拉刷新指示器包装器
Widget refreshIndicator({
  required Future<void> Function() onRefresh,
  required Widget child,
}) {
  return RefreshIndicator(
    onRefresh: onRefresh,
    child: child,
  );
}
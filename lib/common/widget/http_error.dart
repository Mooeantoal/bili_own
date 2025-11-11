import 'package:flutter/material.dart';

class HttpError extends StatelessWidget {
  final String? errMsg;
  final VoidCallback onReload;

  const HttpError({super.key, this.errMsg, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            errMsg ?? '加载失败',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onReload,
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }
}
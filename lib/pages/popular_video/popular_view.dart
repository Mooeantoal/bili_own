import 'package:flutter/material.dart';

class PopularVideoPage {
  const PopularVideoPage();
}

class PopularVideoPage extends StatelessWidget {
  const PopularVideoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('热门视频'),
    );
  }
}
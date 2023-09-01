import 'package:flutter/material.dart';

class SliverListEmpty extends StatelessWidget {
  final String? text;

  const SliverListEmpty({super.key, this.text = "暂无数据"});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Text(
          text!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

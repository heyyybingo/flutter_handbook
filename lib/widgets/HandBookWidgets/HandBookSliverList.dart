import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_handbook/models/Folder.dart';
import 'package:flutter_handbook/models/HandBook.dart';
import 'package:go_router/go_router.dart';

class HandBookSliverList extends StatelessWidget {
  final List<HandBook> handbooks;

  const HandBookSliverList({super.key, required this.handbooks});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: handbooks.length * 2 - 1, // 考虑到分割线的数量
          itemBuilder: (context, index) {
            if (index.isOdd) {
              // 奇数索引，插入分割线
              return const Divider(
                thickness: 0.5,
                indent: 12,
                endIndent: 12,
              );
            }

            final handbookIndex = index ~/ 2;
            final handbook = handbooks[handbookIndex];

            return ListTile(
              onTap: () => {
                context.push(
                    "/handbookedit?id=${handbook.id}&folderId=${handbook.folderId}")
              },
              title: Text('${handbook.title}'),
              subtitle: Text(
                '${handbook.content}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
    );
  }
}

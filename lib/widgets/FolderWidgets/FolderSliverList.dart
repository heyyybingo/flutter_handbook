import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_handbook/models/Folder.dart';
import 'package:go_router/go_router.dart';

class FolderSliverList extends StatelessWidget {
  final List<Folder> folders;

  const FolderSliverList({super.key, required this.folders});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: folders.length, // 考虑到分割线的数量
          itemBuilder: (context, index) {
            final folder = folders[index];

            return ListTile(
             
              onTap: () => context.push("/folderDetail?folderId=${folder.id}"),
              leading: Icon(folder.icon),
              title: Text('${folder.name}'),
              trailing: Icon(Icons.arrow_right),
            );
          }),
    );
  }
}

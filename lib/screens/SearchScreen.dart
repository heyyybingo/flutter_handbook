import 'package:flutter/material.dart';
import 'package:flutter_handbook/models/Folder.dart';
import 'package:flutter_handbook/models/HandBook.dart';
import 'package:flutter_handbook/utils/logger.dart';
import 'package:flutter_handbook/widgets/FolderWidgets/FolderSliverList.dart';
import 'package:flutter_handbook/widgets/HandBookWidgets/HandBookSliverList.dart';
import 'package:flutter_handbook/widgets/SearchBarHero.dart';
import 'package:flutter_handbook/widgets/Sliver/SliverListHeader.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_handbook/constants.dart';

class SearchScreen extends StatefulWidget {
  final Object? tag;

  const SearchScreen({super.key, this.tag});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<HandBook> _handbooks = [];
  List<Folder> _folders = [];

  _buildBox({required Widget child}) {
    return _buildSliverItem(child: SliverToBoxAdapter(child: child));
  }

  _buildSliverItem({required Widget child}) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 12.0), sliver: child);
  }

  _search(String text) async {
    logger.i('start search $text');
    if (text.isEmpty) {
    } else {
      final folders = await FolderService.findFolderByName(text);
      final handbooks = await HandBookSerivce.findFolderByTitleOrContent(text);
      logger.i('searchresult $folders $handbooks');
      setState(() {
        _folders = folders;
        _handbooks = handbooks;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Row(children: [
            Expanded(
                child: widget.tag != null
                    ? SearchBarHero(
                        onSubmitted: _search,
                        tag: widget.tag as Object,
                        shadowColor:
                            MaterialStatePropertyAll<Color>(Colors.transparent),
                      )
                    : SearchBarHero(
                        onSubmitted: _search,
                        hintText: "文件名/内容/目录名",
                        shadowColor:
                            MaterialStatePropertyAll<Color>(Colors.transparent),
                      )),
            GestureDetector(
              onTap: () => {context.pop()},
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('取消',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18))),
            )
          ]),
        ),
        body: CustomScrollView(
          slivers: [
            if (_handbooks.isNotEmpty) ...[
              _buildSliverItem(child: const SliverListHeader(title: "文件")),
              _buildSliverItem(
                  child: HandBookSliverList(handbooks: _handbooks)),
            ],
            _buildBox(child: const SizedBox(height: mBoxDivderHeight)),
            if (_folders.isNotEmpty) ...[
              _buildSliverItem(child: const SliverListHeader(title: "目录")),
              _buildSliverItem(child: FolderSliverList(folders: _folders)),
            ]
          ],
        ));
  }
}

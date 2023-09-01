import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_handbook/constants.dart';
import 'package:flutter_handbook/models/Folder.dart';
import 'package:flutter_handbook/models/HandBook.dart';
import 'package:flutter_handbook/utils/events.dart';
import 'package:flutter_handbook/utils/logger.dart';

import 'package:flutter_handbook/widgets/FolderWidgets/FolderSliverList.dart';
import 'package:flutter_handbook/widgets/HandBookWidgets/HandBookSliverList.dart';
import 'package:flutter_handbook/widgets/Sliver/SliverListHeader.dart';
import 'package:flutter_handbook/widgets/SearchBarHero.dart';
import 'package:go_router/go_router.dart';

class FolderNav extends StatefulWidget {
  const FolderNav({super.key});

  @override
  State<FolderNav> createState() => _FolderNavState();
}

class _FolderNavState extends State<FolderNav> {
  List<Folder> _folders = [];
  List<HandBook> _handbooks = [];

  late StreamSubscription folderSubscription;
  late StreamSubscription handbookSubscription;
  @override
  void initState() {
    super.initState();
    _initFolders();
    _initRecentHandBook();
    folderSubscription = eventBus.on<FolderUpdateEvent>().listen((event) {
      _initFolders();
    });
    handbookSubscription = eventBus.on<HandBookUpdateEvent>().listen((event) {
      logger.i("handbookSubscription $event");
      _initRecentHandBook();
    });
  }

  @override
  void dispose() {
    super.dispose();
    folderSubscription.cancel();
    handbookSubscription.cancel();
  }

  _initFolders() async {
    final folders = await FolderService.findFolders();
    setState(() {
      _folders = folders;
    });
  }

  _initRecentHandBook() async {
    final handbooks =
        await HandBookSerivce.findHandBooksOrderByUpdateTime(limit: 3);

    setState(() {
      _handbooks = handbooks;
    });
  }

  _buildBox({required Widget child}) {
    return _buildSliverItem(child: SliverToBoxAdapter(child: child));
  }

  _buildSliverItem({required Widget child}) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 12.0), sliver: child);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      _buildBox(child: const SizedBox(height: mBoxDivderHeight)),
      _buildBox(
        child: SearchBarHero(
        hintText: "搜索",
        onTap: () => {
          context.push('/search'),
        },
      )),
      _buildBox(child: const SizedBox(height: mBoxDivderHeight)),
     
      _buildBox(child: const SizedBox(height: mBoxDivderHeight)),
      // _buildSliverItem(child: const SliverListHeader(title: "目录")),
      _buildSliverItem(child: FolderSliverList(folders: _folders)),
       if (_handbooks.isNotEmpty) ...[
        _buildSliverItem(child: const SliverListHeader(title: "最近使用")),
        _buildSliverItem(child: HandBookSliverList(handbooks: _handbooks)),
      ],
    ]);
  }
}

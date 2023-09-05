import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_handbook/constants.dart';
import 'package:flutter_handbook/form/folderFormModel.dart';
import 'package:flutter_handbook/models/Folder.dart';
import 'package:flutter_handbook/models/HandBook.dart';
import 'package:flutter_handbook/utils/events.dart';
import 'package:flutter_handbook/utils/logger.dart';

import 'package:flutter_handbook/widgets/HandBookWidgets/HandBookSliverList.dart';
import 'package:flutter_handbook/widgets/Sliver/SliverListEmpty.dart';
import 'package:flutter_handbook/widgets/Sliver/SliverListHeader.dart';
import 'package:flutter_handbook/widgets/SearchBarHero.dart';
import 'package:go_router/go_router.dart';

class FolderDetailScreen extends StatefulWidget {
  final int folderId;
  static const tag = "FolderDetailScreen";

  const FolderDetailScreen({Key? key, required this.folderId})
      : super(key: key);

  @override
  _FolderDetailScreenState createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  Folder? _folder;
  List<HandBook> _handbooks = [];
  late StreamSubscription handbookSubscription;

  final _folderUpdateForm = GlobalKey<FormState>();
  final _folderUpdateFormModel = FolderFormModel(name: "");
  @override
  void initState() {
    super.initState();
    _initFolder();
    _initFolderHandBooks();
    handbookSubscription = eventBus.on<HandBookUpdateEvent>().listen((event) {
      _initFolderHandBooks();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _initFolder() async {
    final folder = await FolderService.findFolderById(widget.folderId);
    setState(() {
      _folder = folder;
    });
  }

  _initFolderHandBooks() async {
    final handbooks =
        await HandBookSerivce.findHandBookByFolderIdOrderByUpdateTime(
            widget.folderId);
    setState(() {
      _handbooks = handbooks;
    });
  }

  _updateFolderName() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("请输入标题"),
          content: Form(
            key: _folderUpdateForm,
            child: TextFormField(
              initialValue: _folder?.name ?? '',
              onSaved: (newValue) {
                _folderUpdateFormModel.name = newValue ?? "";
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入内容';
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("取消")),
            TextButton(
                onPressed: () async {
                  if (_folderUpdateForm.currentState!.validate()) {
                    _folderUpdateForm.currentState!.save();

                    final newFolder = _folder!.copyWith();
                    newFolder.name = _folderUpdateFormModel.name;
                    await FolderService.updateCustomizeFolder(newFolder);

                    setState(() {
                      _folder = newFolder;
                    });
                    eventBus.fire(FolderUpdateEvent());
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text("确认")),
          ],
        );
      },
    );
  }

  // today;one month;other
  List<Widget> _buildSeperateHandBookListByUpdateTimeRange() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime oneMonthAgo = today.subtract(const Duration(days: 30));

    List<HandBook> todayHandBooks = [];
    List<HandBook> oneMonthHandBooks = [];
    List<HandBook> otherHandBooks = [];

    for (var handbook in _handbooks) {
      final time = handbook.updateTime ?? handbook.createTime;

      if (time!.isAfter(today)) {
        todayHandBooks.add(handbook); // 添加到今天列表
      } else if (time!.isAfter(oneMonthAgo)) {
        oneMonthHandBooks.add(handbook); // 添加到一个月列表
      } else {
        otherHandBooks.add(handbook); // 添加到其他列表
      }
    }

    List<Widget> slivers = [];

    if (todayHandBooks.isNotEmpty) {
      slivers.addAll(
          _buildSliverRangeItem(title: "今天", handbooks: todayHandBooks));
    }

    if (oneMonthHandBooks.isNotEmpty) {
      slivers.addAll(
          _buildSliverRangeItem(title: "一个月内", handbooks: oneMonthHandBooks));
    }

    if (otherHandBooks.isNotEmpty) {
      slivers.addAll(
          _buildSliverRangeItem(title: "历史", handbooks: otherHandBooks));
    }

    return slivers;
  }

  List<Widget> _buildSliverRangeItem(
      {required String title, required List<HandBook> handbooks}) {
    return [
      SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          sliver: SliverListHeader(title: title)),
      SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          sliver: HandBookSliverList(handbooks: handbooks)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bodySliverList = _buildSeperateHandBookListByUpdateTimeRange();

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push("/handbookedit?folderId=${widget.folderId}");
        },
        child: Icon(Icons.edit),
      ),
      appBar: AppBar(
          actions: [
            if (_folder?.id != null && _folder?.type == FolderType.CUSTOMIZE)
              MenuAnchor(
                  alignmentOffset: const Offset(-60, 0),
                  builder: (BuildContext context, MenuController controller,
                      Widget? child) {
                    return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(Icons.more_horiz));
                  },
                  menuChildren: [
                    MenuItemButton(
                        leadingIcon: const Icon(
                          Icons.delete_outlined,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("提示"),
                                  content: const Text("请确认是否要删除"),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {},
                                        child: const Text("取消")),
                                    TextButton(
                                        onPressed: () async {
                                          await FolderService.deleteFolderById(
                                              _folder!.id!);

                                          eventBus.fire(FolderUpdateEvent());
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            context.pop();
                                          }
                                        },
                                        child: const Text("确认"))
                                  ],
                                );
                              });
                        },
                        child: const Text(
                          "删除",
                          style: TextStyle(color: Colors.red),
                        ))
                  ])
          ],
          title: GestureDetector(
            onTap: () {
              if (_folder?.type == FolderType.CUSTOMIZE) {
                _updateFolderName();
              }
            },
            child: Text(_folder?.name ?? ''),
          )),
      body: CustomScrollView(
          slivers: bodySliverList.isNotEmpty
              ? bodySliverList
              : [const SliverListEmpty()]),
    );
  }
}

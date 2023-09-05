import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_handbook/models/Folder.dart';
import 'package:flutter_handbook/models/HandBook.dart';
import 'package:flutter_handbook/utils/events.dart';
import 'package:flutter_handbook/utils/logger.dart';
import 'package:flutter_handbook/utils/notification.dart';
import 'package:flutter_handbook/widgets/Sliver/SliverListHeader.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HandBookEdit extends StatefulWidget {
  final int? id;
  final int? folderId;

  const HandBookEdit({super.key, this.id, required this.folderId});

  @override
  State<HandBookEdit> createState() => _HandBookEditState();
}

class _HandBookEditState extends State<HandBookEdit> {
  final titleController = TextEditingController(); // title edit controller
  final contentController = TextEditingController(); // content edit controller
  late HandBook _handbook;

  @override
  void initState() {
    super.initState();
    setState(() {
      _handbook = HandBook(id: widget.id, folderId: widget.folderId);
    });
    _initHandBookIFExit();
  }

  @override
  void dispose() {
    super.dispose();

    // dispose text controllers
    titleController.dispose();
    contentController.dispose();
  }

  Future<void> _initHandBookIFExit() async {
    if (_handbook.id != null) {
      final handbook =
          await HandBookSerivce.findHandBookById(_handbook.id as int);
      if (handbook != null) {
        setState(() {
          _handbook = handbook;
        });
        titleController.text = handbook.title ?? '';
        contentController.text = handbook.content ?? '';
      }
      return;
    }

    if (_handbook.folderId != null) {
      final folder =
          await FolderService.findFolderById(_handbook.folderId as int);
      _handbook.folder = folder;
    }
  }

  Future<void> _saveHandBook() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("请输入标题")));
      return;
    }

    _handbook.title = titleController.text;
    _handbook.content = contentController.text;

    if (_handbook.id == null) {
      // create mode
      await HandBookSerivce.insertHandBook(_handbook);
    } else {
      // update mode
      await HandBookSerivce.updateHandBook(_handbook);
    }

    eventBus.fire(HandBookUpdateEvent());
  }

  _changeAlarmTime() async {
    final now = DateTime.now();
    final nextYear = now.add(const Duration(days: 365));
    final init = _handbook.alarmTime ?? now;
    final selectDate = await showDatePicker(
        context: context,
        initialDate: init,
        firstDate: init,
        lastDate: nextYear);

    if (selectDate != null && context.mounted) {
      final timeNow = _handbook.alarmTime ?? DateTime.now();
      final selectTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: timeNow.hour, minute: timeNow.minute));
      if (selectTime != null) {
        final selectAlarmTime = selectDate.copyWith(
            hour: selectTime.hour, minute: selectTime.minute);
        setState(() {
          _handbook.alarmTime = selectAlarmTime;
        });
      }
    }
  }

  _buildAlarm() {
    if (_handbook.alarmTime == null) {
      return IconButton(
        onPressed: () {
          _changeAlarmTime();
        },
        icon: const Icon(Icons.calendar_month),
      );
    }

    return MenuAnchor(
        builder: (context, controller, child) {
          return IconButton(
              icon: const Badge(
                  label: Text("提醒"), child: Icon(Icons.calendar_month)),
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              color: Theme.of(context).colorScheme.primary);
        },
        menuChildren: [
          MenuItemButton(
              onPressed: () {
                _changeAlarmTime();
              },
              child: const Text("修改")),
          MenuItemButton(
              onPressed: () {
                setState(() {
                  _handbook.alarmTime = null;
                });
              },
              child: const Text("取消"))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   onPressed:() {},
      //   child: Icon(Icons.save),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130.0,
            pinned: true,
            centerTitle: true,
            actions: [
              _buildAlarm(),
              if (_handbook.id != null)
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
                          child: TextButton(
                        child: Text("通知"),
                        onPressed: () {

                          HandBookSerivce.scheduleHandBookAlarmById(_handbook.id!);
                        
                        },
                      )),
                      MenuItemButton(
                          leadingIcon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext builder) {
                                  final showInfoList = [
                                    {
                                      "label": "文件夹",
                                      "value": _handbook.folder?.name ?? '--'
                                    },
                                    {
                                      "label": "创建时间",
                                      "value": DateFormat("yyyy-MM-dd HH:mm:ss")
                                          .format(_handbook.createTime!)
                                    },
                                    {
                                      "label": "更新时间",
                                      "value": _handbook.updateTime != null
                                          ? DateFormat("yyyy-MM-dd HH:mm:ss")
                                              .format(_handbook.updateTime!)
                                          : '--'
                                    }
                                  ];
                                  return SimpleDialog(
                                    title: const Text("文件信息"),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: showInfoList
                                                  .map((e) => Text(
                                                        "${e["label"]}:",
                                                      ))
                                                  .toList(),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: showInfoList
                                                  .map((e) => Text(
                                                        e["value"] ?? "",
                                                      ))
                                                  .toList(),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: const Text("文件信息")),
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
                                          onPressed: () async {
                                            await HandBookSerivce
                                                .deleteHandBookById(
                                                    _handbook.id!);
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: const Text("取消")),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
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
                    ]),
              TextButton(
                  onPressed: () async {
                    await _saveHandBook();
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                  child: const Text("完成"))
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 36.0, vertical: 0),
              title: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "请输入",
                ),
                textAlignVertical: TextAlignVertical.bottom,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverFillRemaining(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "请输入"),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )))
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_handbook/form/folderFormModel.dart';
import 'package:flutter_handbook/models/Folder.dart';
import 'package:flutter_handbook/utils/db.dart';
import 'package:flutter_handbook/screens/HomeScreen/FolderNav.dart';
import 'package:flutter_handbook/utils/events.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class BarItem {
  final Widget? leading;
  final String title;
  final List<Widget>? actions;
  BarItem({this.leading, required this.title, this.actions});
}

class SearchIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {context.push("/search")},
        child: const Icon(Icons.search_outlined));
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final _folderInsertForm = GlobalKey<FormState>();
  final _folderInsertFormModel = FolderFormModel(name: "");

  final _navs = const [
    {
      'selectedIcon': Icons.folder,
      'icon': Icons.folder_outlined,
      'label': '目录'
    },
    {
      'selectedIcon': Icons.access_alarm,
      'icon': Icons.access_alarm_outlined,
      'label': '提醒事项'
    },
  ];
  @override
  void initState() {
    super.initState();

    databaseHelper.database;
  }

  final List<BarItem> _bars = [
    BarItem(
      leading: Icon(Icons.create_new_folder_outlined),
      title: '目录',
      actions: null,
    ),
    BarItem(
      leading: SearchIcon(),
      title: '提醒事项',
    ),
  ];
  int currentPageIndex = 0;

  get currentNav {
    return _navs[currentPageIndex];
  }

  _insertNewFolder() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("请输入目录名称"),
          content: Form(
            key: _folderInsertForm,
            child: TextFormField(
              onSaved: (newValue) {
                _folderInsertFormModel.name = newValue ?? "";
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
                  if (_folderInsertForm.currentState!.validate()) {
                    _folderInsertForm.currentState!.save();
                    await FolderService.insertCustomizeFolderByName(
                        _folderInsertFormModel.name);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: IconButton(
            icon: _bars[currentPageIndex].leading!,
            onPressed: () {
              _insertNewFolder();
            },
          ),
          title: Text(_bars[currentPageIndex].title),
          // backgroundColor: Theme.of(context).colorScheme.surface,
          actions: _bars[currentPageIndex].actions),
      body: [
        FolderNav(),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Page 2'),
        ),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        selectedIndex: currentPageIndex,
        destinations: _navs.map((e) {
          return NavigationDestination(
            selectedIcon: Icon(
              e['selectedIcon'] as IconData,
            ),
            icon: Icon(e['icon'] as IconData),
            label: e['label'] as String,
          );
        }).toList(),
      ),
    );
  }
}

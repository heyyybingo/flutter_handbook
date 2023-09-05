import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_handbook/models/HandBook.dart';
import 'package:flutter_handbook/screens/FolderDetailScreen.dart';
import 'package:flutter_handbook/screens/HandBookScreen/HandBookEdit.dart';
import 'package:flutter_handbook/screens/SearchScreen.dart';
import 'package:flutter_handbook/utils/logger.dart';
import 'package:flutter_handbook/utils/notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_handbook/screens/HomeScreen/Home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/search/:searchTag',
      builder: (context, state) =>
          SearchScreen(tag: state.pathParameters['searchTag']),
    ),
    GoRoute(
      path: '/folderDetail',
      builder: (context, state) {
        final folderId = state.uri.queryParameters['folderId'];
        return FolderDetailScreen(folderId: int.parse(folderId ?? ''));
      },
    ),
    GoRoute(
      path: '/handBookEdit',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        final folderId = state.uri.queryParameters['folderId'];
        return HandBookEdit(
            id: int.tryParse(id ?? ""), folderId: int.tryParse(folderId ?? ''));
      },
    )
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en', 'US'), // 英语（美国）
        Locale('zh', 'CN'), // 中文（中国）
      ],
      locale: const Locale("zh", 'CN'),
      theme: ThemeData(
        useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );

    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     // This is the theme of your application.
    //     //
    //     // TRY THIS: Try running your application with "flutter run". You'll see
    //     // the application has a blue toolbar. Then, without quitting the app,
    //     // try changing the seedColor in the colorScheme below to Colors.green
    //     // and then invoke "hot reload" (save your changes or press the "hot
    //     // reload" button in a Flutter-supported IDE, or press "r" if you used
    //     // the command line to start the app).
    //     //
    //     // Notice that the counter didn't reset back to zero; the application
    //     // state is not lost during the reload. To reset the state, use hot
    //     // restart instead.
    //     //
    //     // This works for code too, not just values: Most code changes can be
    //     // tested with just a hot reload.
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //     useMaterial3: true,
    //   ),
    //   home: const HomeScreen(),
    // );
  }

  @override
  void initState() {
    super.initState();
    _configureNotification();
  }

  @override
  dispose() {
    super.dispose();
    _disposeNotification();
  }

  _disposeNotification() {
    didReceiveNotificationStream.close();
  }

  _configureNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await NotificationService()
            .flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp == true &&
        notificationAppLaunchDetails?.notificationResponse != null) {
      _notificationEventHandler(
          notificationAppLaunchDetails!.notificationResponse!);
    }

    didReceiveNotificationStream.stream.listen(_notificationEventHandler);
  }

  _notificationEventHandler(NotificationResponse event) {
    if (event.payload != null) {
      final NotificationPayload payload =
          NotificationPayload.fromJson(jsonDecode(event.payload!));

      logger.i("NotificationPayload ${payload.type} ${payload.value}");
      switch (payload.type) {
        case NotificationType.handbook:
          final HandBook handbook = HandBook.fromJson(payload.value);
          _router.push('/handBookEdit?id=${handbook.id}');
          break;
      }
    }
  }
}

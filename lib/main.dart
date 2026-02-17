import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_win_overlay/di/app_service_locator.dart';
import 'package:flutter_win_overlay/di/service_locator.dart';
import 'package:flutter_win_overlay/generated/assets.dart';
import 'package:flutter_win_overlay/logged_widget.dart';
import 'package:flutter_win_overlay/overlay_window.dart';
import 'package:flutter_win_overlay/settings.dart';
import 'package:flutter_win_overlay/twitch/twitch_login_widget.dart';
import 'package:system_tray/system_tray.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = Settings();
  await settings.init();

  final locator = AppServiceLocator.init(settings);

  runApp(MyApp(locator: locator));

  await _initSystemTray();

  while (true) {
    await Future.delayed(Duration(seconds: 1));
    await OverlayWindow.forceToTop();
  }
}

Future<void> _initSystemTray() async {
  final window = AppWindow();
  final tray = SystemTray();

  await tray.initSystemTray(
    title: 'Twitch Flutter Overlay',
    iconPath: Assets.assetsAppIcon,
  );

  final menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Exit', onClicked: (menuItem) => window.close()),
  ]);

  await tray.setContextMenu(menu);

  tray.registerSystemTrayEventHandler((eventName) {
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? window.show() : tray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? tray.popUpContextMenu() : window.show();
    }
  });
}

class MyApp extends StatelessWidget {
  final ServiceLocator locator;

  const MyApp({super.key, required this.locator});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.transparent,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ).copyWith(surface: Colors.transparent),
      ),
      home: MyHomePage(locator: locator),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ServiceLocator locator;

  const MyHomePage({super.key, required this.locator});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Settings _settings;

  @override
  void initState() {
    _settings = widget.locator.provide();
    super.initState();
  }

  Widget _createRoot(BuildContext context) {
    return StreamBuilder(
      stream: _settings.twitchAuthChanges,
      initialData: _settings.twitchAuth,
      builder: (cntx, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          return LoggedWidget(creds: data, locator: widget.locator);
        } else {
          return Center(child: TwitchLoginWidget(settings: _settings));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _createRoot(context),
    );
  }
}

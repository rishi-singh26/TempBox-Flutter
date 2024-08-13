import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tempbox/android_views/android_app_view.dart';
import 'package:tempbox/ios_ui/ios_view.dart';
import 'package:tempbox/macos_views/macos_view.dart';
import 'package:tempbox/win_views/win_view.dart';
import 'package:window_manager/window_manager.dart';

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

Future<void> configureWindowSize({Size minSize = const Size(1000, 550)}) async {
  await WindowManager.instance.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: minSize,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: minSize,
    windowButtonVisibility: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions).then((_) async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: await getApplicationSupportDirectory());
  if (Platform.isMacOS) {
    await configureWindowSize(minSize: const Size(1000, 550));
    await _configureMacosWindowUtils();
    runApp(const MacOSView());
  } else if (Platform.isWindows || Platform.isLinux) {
    await configureWindowSize(minSize: const Size(1200, 550));
    SystemTheme.fallbackColor = const Color(0xFFBA1F33);
    SystemTheme.accentColor.load();
    runApp(const WinApp());
  } else if (Platform.isIOS) {
    runApp(const IosView());
  } else {
    SystemTheme.fallbackColor = const Color(0xFFBA1F33);
    SystemTheme.accentColor.load();
    runApp(const AndroidAppView());
  }
}

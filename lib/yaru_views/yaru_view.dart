import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/yaru_views/theme.dart';
import 'package:tempbox/yaru_views/views/yaru_selected_address_view/yaru_selected_address_view.dart';
import 'package:yaru/yaru.dart';

class YaruView extends StatelessWidget {
  const YaruView({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      data: YaruThemeData(variant: InheritedYaruVariant.of(context)),
      builder: (context, yaru, child) {
        return MaterialApp(
          title: 'TempBox',
          debugShowCheckedModeBanner: false,
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          highContrastTheme: yaruHighContrastLight,
          highContrastDarkTheme: yaruHighContrastDark,
          home: MultiBlocProvider(providers: [
            BlocProvider<DataBloc>(create: (BuildContext context) => DataBloc()),
            BlocProvider<DataBloc>(create: (BuildContext context) => DataBloc()),
          ], child: const YaruStarter()),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
              PointerDeviceKind.trackpad,
            },
          ),
        );
      },
    );
  }
}

class YaruStarter extends StatelessWidget {
  const YaruStarter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
        return const YaruApp();
      },
    );
  }
}

class YaruApp extends StatelessWidget {
  const YaruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return YaruMasterDetailPage(
        length: dataState.addressList.length,
        tileBuilder: (context, index, selected, availableWidth) => YaruMasterTile(
          leading: const Icon(Icons.inbox_outlined),
          title: Text(UiService.getAccountName(dataState.addressList[index])),
        ),
        pageBuilder: (context, index) => YaruDetailPage(
          appBar: const YaruWindowTitleBar(
            backgroundColor: Colors.transparent,
            border: BorderSide.none,
            title: Text('TempBox'),
            actions: [
              YaruIconButton(icon: Icon(Icons.access_time_outlined)),
              YaruIconButton(icon: Icon(Icons.access_time_outlined)),
            ],
          ),
          body: const InfoPage(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Example snippet',
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            backgroundColor: PopupMenuTheme.of(context).color,
            shape: PopupMenuTheme.of(context).shape,
            child: const Icon(YaruIcons.code),
          ),
        ),
        appBar: YaruWindowTitleBar(
          title: const Text('Yaru'),
          border: BorderSide.none,
          backgroundColor: YaruMasterDetailTheme.of(context).sideBarColor,
        ),
        bottomBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: YaruMasterTile(
            leading: const Icon(YaruIcons.gear),
            title: const Text('Settings'),
            onTap: () {},
          ),
        ),
      );
    });
  }
}

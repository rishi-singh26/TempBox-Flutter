import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/bloc/messages/messages_bloc.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/win_views/window_buttons.dart';
import 'package:window_manager/window_manager.dart';

class WinApp extends StatelessWidget {
  const WinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'TempBox',
      themeMode: ThemeMode.system,
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.compact,
        focusTheme: FocusThemeData(glowFactor: is10footScreen(context) ? 2.0 : 0.0),
      ),
      theme: FluentThemeData(
        visualDensity: VisualDensity.compact,
        focusTheme: FocusThemeData(glowFactor: is10footScreen(context) ? 2.0 : 0.0),
      ),
      home: Builder(builder: (context) {
        Window.setEffect(
          effect: WindowEffect.acrylic,
          color: FluentTheme.of(context).acrylicBackgroundColor,
          dark: FluentTheme.of(context).brightness.isDark,
        );
        return Directionality(
          textDirection: TextDirection.ltr,
          child: NavigationPaneTheme(
            data: const NavigationPaneThemeData(backgroundColor: null),
            child: MultiBlocProvider(providers: [
              BlocProvider<DataBloc>(create: (BuildContext context) => DataBloc()),
              BlocProvider<MessagesBloc>(create: (BuildContext context) => MessagesBloc()),
            ], child: const WindowsView()),
          ),
        );
      }),
    );
  }
}

class WindowsView extends StatefulWidget {
  const WindowsView({super.key});

  @override
  State<WindowsView> createState() => _WindowsViewState();
}

class _WindowsViewState extends State<WindowsView> with WindowListener {
  // final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return NavigationView(
        // key: viewKey,
        appBar: const NavigationAppBar(
          title: DragToMoveArea(child: Align(alignment: AlignmentDirectional.centerStart, child: Text('TempBox'))),
          actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [WindowButtons()]),
        ),
        pane: NavigationPane(
          size: NavigationPaneSize(openWidth: MediaQuery.of(context).size.width / 5, openMinWidth: 250, openMaxWidth: 250),
          items: [PaneItem(icon: const Icon(CupertinoIcons.tray), title: const Text('Home'), body: const SizedBox.shrink())],
          // items: () {
          //   final List<NavigationPaneItem> items = dataState.addressList
          //       .map(
          //         (a) => PaneItem(
          //           key: Key(a.authenticatedUser.account.id),
          //           icon: const Icon(CupertinoIcons.tray),
          //           title: Text(UiService.getAccountName(a)),
          //           body: const SizedBox.shrink(),
          //         ),
          //       )
          //       .toList();
          //   return items;
          // }(),
          displayMode: PaneDisplayMode.open,
          toggleable: true,
        ),
        paneBodyBuilder: (item, child) {
          final name = item?.key is ValueKey ? (item!.key as ValueKey).value : null;
          return FocusTraversalGroup(
            key: ValueKey('body$name'),
            child: ScaffoldPage.scrollable(
              header: const PageHeader(title: Text('Home')),
              children: [
                FilledButton(
                  child: const Text('Filled Button'),
                  onPressed: () => Window.setEffect(
                    effect: WindowEffect.acrylic,
                    color: FluentTheme.of(context).acrylicBackgroundColor,
                    dark: FluentTheme.of(context).brightness.isDark,
                  ),
                ),
              ],
            ),
          );
        },
        onDisplayModeChanged: (value) {},
        onOpenSearch: () {},
        // content: const Center(child: Text('data')),
      );
    });
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      // windowManager.destroy();
      debugPrint('Dont let close');
    }
  }
}

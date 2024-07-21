import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/win_views/views/add_address/winui_add_address.dart';
import 'package:tempbox/win_views/views/selected_address_view/winui_selected_address_view.dart';
import 'package:tempbox/win_views/window_buttons.dart';
import 'package:window_manager/window_manager.dart';

class WinApp extends StatelessWidget {
  const WinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'TempBox',
      debugShowCheckedModeBanner: false,
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
              BlocProvider<DataBloc>(create: (BuildContext context) => DataBloc()),
            ], child: const WinuiStarter()),
          ),
        );
      }),
    );
  }
}

class WinuiStarter extends StatelessWidget {
  const WinuiStarter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
        return const WindowsView();
      },
    );
  }
}

class WindowsView extends StatefulWidget {
  const WindowsView({super.key});

  @override
  State<WindowsView> createState() => _WindowsViewState();
}

class _WindowsViewState extends State<WindowsView> with WindowListener {
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

  int? _getSelectedIndex(AddressData selected, List<AddressData> addresses) {
    final index = addresses.indexWhere((a) => a.authenticatedUser.account.id == selected.authenticatedUser.account.id);
    return index >= 0 ? index : null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      int? selectedIndex = dataState.selectedAddress == null ? null : _getSelectedIndex(dataState.selectedAddress!, dataState.addressList);
      return NavigationView(
        appBar: const NavigationAppBar(
          leading: FlutterLogo(),
          title: DragToMoveArea(child: Align(alignment: AlignmentDirectional.centerStart, child: Text('TempBox'))),
          actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [WindowButtons()]),
        ),
        pane: NavigationPane(
          onItemPressed: (index) {
            BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(dataState.addressList[index]));
          },
          size: NavigationPaneSize(openWidth: MediaQuery.of(context).size.width / 5, openMinWidth: 250, openMaxWidth: 250),
          items: dataState.addressList
              .map((a) => PaneItem(
                    key: Key(a.authenticatedUser.account.id),
                    icon: const Icon(CupertinoIcons.tray),
                    title: Text(UiService.getAccountName(a)),
                    body: const SizedBox.shrink(),
                  ))
              .toList()
              .cast<NavigationPaneItem>(),
          displayMode: PaneDisplayMode.open,
          toggleable: true,
          selected: selectedIndex,
          footerItems: [
            PaneItemSeparator(),
            PaneItemAction(
              icon: const Icon(FluentIcons.add_to),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<DataBloc>(dataBlocContext),
                    child: const WinuiAddAddress(),
                  ),
                );
              },
              title: const Text('New Address'),
            ),
          ],
        ),
        paneBodyBuilder: (item, child) {
          final name = item?.key is ValueKey ? (item!.key as ValueKey).value : null;
          return FocusTraversalGroup(key: ValueKey('body$name'), child: WinuiSelectedAddressView());
        },
        // onDisplayModeChanged: (value) {},
        // onOpenSearch: () {},
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

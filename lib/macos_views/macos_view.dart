import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/bloc/messages/messages_bloc.dart';
import 'package:tempbox/macos_views/platform_menus.dart';
import 'package:tempbox/macos_views/views/add_address/macui_add_address.dart';
import 'package:tempbox/macos_views/views/selected_address_view/selected_address_view.dart';
import 'package:tempbox/macos_views/views/sidebar_view/sidebar_search.dart';
import 'package:tempbox/macos_views/views/sidebar_view/sidebar_view.dart';

class MacOSView extends StatelessWidget {
  const MacOSView({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'TempBox',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DataBloc>(create: (BuildContext context) => DataBloc()),
          BlocProvider<MessagesBloc>(create: (BuildContext context) => MessagesBloc()),
        ],
        child: const MacOsHome(),
      ),
    );
  }
}

class MacOsHome extends StatefulWidget {
  const MacOsHome({super.key});

  @override
  State<MacOsHome> createState() => _MacOsHomeState();
}

class _MacOsHomeState extends State<MacOsHome> {
  late final searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return BlocBuilder<MessagesBloc, MessagesState>(builder: (messagesBlocContext, messagesState) {
        return PlatformMenuBar(
          menus: menuBarItems(),
          child: MacosWindow(
            sidebar: Sidebar(
              top: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: CupertinoListTile(
                      title: Text('New Address', style: typography.body),
                      trailing: const MacosIcon(CupertinoIcons.add_circled_solid, size: 18),
                      backgroundColor: CupertinoColors.systemGrey3.resolveFrom(context),
                      backgroundColorActivated: CupertinoColors.systemGrey4.resolveFrom(context),
                      onTap: () {
                        showMacosSheet(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<DataBloc>(dataBlocContext),
                            child: const MacUIAddAddress(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SidebarSearch(),
                ],
              ),
              minWidth: 240,
              builder: (context, scrollController) => SidebarView(scrollController: scrollController),
              bottom: const MacosListTile(
                leading: MacosIcon(CupertinoIcons.profile_circled),
                title: Text('Tim Apple'),
                subtitle: Text('tim@apple.com'),
              ),
            ),
            child: const SelectedAddressView(),
          ),
        );
      });
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/platform_menus.dart';
import 'package:tempbox/macos_views/views/add_address/macui_add_address.dart';
import 'package:tempbox/macos_views/views/selected_address_view/selected_address_view.dart';
import 'package:tempbox/macos_views/views/sidebar_view/sidebar_view.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
        ],
        child: const MacosStarter(),
      ),
    );
  }
}

class MacosStarter extends StatelessWidget {
  const MacosStarter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
        return const MacOsHome();
      },
    );
  }
}

class MacOsHome extends StatelessWidget {
  const MacOsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return PlatformMenuBar(
        menus: menuBarItems(),
        child: MacosWindow(
          sidebar: Sidebar(
            top: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
              child: CupertinoListTile(
                title: Text('New Address', style: typography.body),
                trailing: MacosIcon(
                  CupertinoIcons.add_circled_solid,
                  size: 18,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
                backgroundColor: CupertinoColors.systemGrey2.resolveFrom(context).withAlpha(44),
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
            minWidth: 240,
            maxWidth: 270,
            builder: (context, scrollController) => SidebarView(scrollController: scrollController),
            bottom: MacosListTile(
              title: RichText(
                text: TextSpan(
                  text: "Powered by ",
                  children: <TextSpan>[
                    TextSpan(
                      text: 'mail.tm',
                      style: TextStyle(color: MacosTheme.of(context).primaryColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          bool? choice = await AlertService.getConformation(
                            context: context,
                            title: 'Do you wnat to continue?',
                            content: 'This will open mail.tm website.',
                          );
                          if (choice == true) {
                            await launchUrl(Uri.parse('https://mail.tm'));
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: const SelectedAddressView(),
        ),
      );
    });
  }
}

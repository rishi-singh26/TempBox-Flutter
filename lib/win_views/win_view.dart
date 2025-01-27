import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/services/fs_service.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/app_logo.dart';
import 'package:tempbox/win_views/views/add_address/winui_add_address.dart';
import 'package:tempbox/win_views/views/selected_address_view/winui_selected_address_view.dart';
import 'package:tempbox/win_views/views/winui_address_info/winui_address_info.dart';
import 'package:tempbox/win_views/views/winui_app_info/winui_app_info.dart';
import 'package:tempbox/win_views/views/winui_import_export/winui_export.dart';
import 'package:tempbox/win_views/views/winui_import_export/winui_import.dart';
import 'package:tempbox/win_views/views/winui_removed_addresses/winui_removed_addresses.dart';
import 'package:tempbox/win_views/window_buttons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class WinApp extends StatelessWidget {
  const WinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return SystemThemeBuilder(builder: (context, accent) {
        return FluentApp(
          title: 'TempBox',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          darkTheme: FluentThemeData(
            accentColor: systemAccentColor(accent),
            brightness: Brightness.dark,
            visualDensity: VisualDensity.compact,
            focusTheme: FocusThemeData(glowFactor: is10footScreen(context) ? 2.0 : 0.0),
          ),
          theme: FluentThemeData(
            accentColor: systemAccentColor(accent),
            visualDensity: VisualDensity.compact,
            focusTheme: FocusThemeData(glowFactor: is10footScreen(context) ? 2.0 : 0.0),
          ),
          home: Builder(builder: (context) {
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
      });
    });
  }
}

class WinuiStarter extends StatelessWidget {
  const WinuiStarter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        if (!dataState.didRefreshAddressData) {
          BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
        }
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

  _importAddresses(BuildContext context, BuildContext dataBlocContext) async {
    List<AddressData>? addresses = await ExportImportAddress.importAddreses();
    if (context.mounted && addresses != null) {
      showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<DataBloc>(dataBlocContext),
          child: WinuiImport(addresses: addresses),
        ),
      );
    }
  }

  _exportAddresses(BuildContext context, BuildContext dataBlocContext) async {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: const WinuiExport(),
      ),
    );
  }

  _removedAddresses(BuildContext context, BuildContext dataBlocContext) async {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: const WinuiRemovedAddresses(),
      ),
    );
  }

  _removeAddress(BuildContext dataBlocContext, AddressData? address) async {
    if (address == null) {
      return;
    }
    final choice = await AlertService.getConformation<bool>(
      context: context,
      title: 'Alert',
      content:
          'Are you sure you want to remove this address?\nThis address will not be deleted, just removed from the list here.\nYou can bring it back from the removed addresses section.',
    );
    if (choice == true && dataBlocContext.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(RemoveAddressEvent(address));
    }
  }

  _deleteAddress(BuildContext dataBlocContext, AddressData? address) async {
    if (address == null) {
      return;
    }
    final choice = await AlertService.getConformation<bool>(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to delete this address?',
    );
    if (choice == true && dataBlocContext.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteAddressEvent(address));
    }
  }

  _showAddressInfo(BuildContext dataBlocContext, AddressData? address) {
    if (address == null) {
      return;
    }
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: WinuiAddressInfo(addressData: address),
      ),
    );
  }

  _refreshInbox(BuildContext dataBlocContext, AddressData? address) {
    if (address == null) {
      return;
    }
    BlocProvider.of<DataBloc>(dataBlocContext).add(GetMessagesEvent(addressData: address));
  }

  _toggleMessageSeenStatus(BuildContext dataBlocContext, DataState dataState) {
    if (dataState.selectedAddress == null || dataState.selectedMessage == null) {
      return;
    }
    BlocProvider.of<DataBloc>(dataBlocContext).add(ToggleMessageReadUnread(
      addressData: dataState.selectedAddress!,
      message: dataState.selectedMessage!,
    ));
  }

  _deleteMessage(BuildContext dataBlocContext, DataState dataState) async {
    if (dataState.selectedAddress == null || dataState.selectedMessage == null) {
      return;
    }
    final choice = await AlertService.getConformation<bool>(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to delete this message?',
    );
    if (choice == true && context.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteMessageEvent(
        addressData: dataState.selectedAddress!,
        message: dataState.selectedMessage!,
      ));
    }
  }

  NavigationPaneItem _buildPaneItem(AddressData a, DataState state, BuildContext dataBlocContext) {
    return PaneItem(
      key: Key(a.authenticatedUser.account.id),
      icon: const Icon(CupertinoIcons.tray),
      title: Text(UiService.getAccountName(a)),
      body: const SizedBox.shrink(),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text((state.accountIdToMessagesMap[a.authenticatedUser.account.id]?.length ?? 0).toString()),
            const SizedBox(width: 5),
            DropDownButton(
              buttonBuilder: (context, onOpen) {
                return IconButton(icon: const Icon(CupertinoIcons.ellipsis_circle), onPressed: onOpen);
              },
              closeAfterClick: true,
              title: const Icon(FluentIcons.more, size: 15),
              items: [
                MenuFlyoutItem(
                  leading: const Icon(CupertinoIcons.refresh_thick),
                  text: const Text('Refresh Inbox'),
                  onPressed: () => _refreshInbox(dataBlocContext, a),
                ),
                MenuFlyoutItem(
                  leading: const Icon(CupertinoIcons.info_circle),
                  text: const Text('Address Info'),
                  onPressed: () => _showAddressInfo(dataBlocContext, a),
                ),
                MenuFlyoutItem(
                  leading: const Icon(CupertinoIcons.clear_circled),
                  text: const Text('Remove Address'),
                  onPressed: () => _removeAddress(dataBlocContext, a),
                ),
                MenuFlyoutItem(
                  leading: const Icon(CupertinoIcons.trash),
                  text: const Text('Delete Address'),
                  onPressed: () => _deleteAddress(dataBlocContext, a),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      int? selectedIndex = dataState.selectedAddress == null || dataState.addressList.isEmpty
          ? null
          : dataState.addressList.indexWhere((a) => a == dataState.selectedAddress);
      return NavigationView(
        appBar: NavigationAppBar(
          leading: const AppLogo(size: 20, borderRadius: BorderRadius.all(Radius.circular(15))),
          title: const DragToMoveArea(child: Align(alignment: AlignmentDirectional.centerStart, child: Text('TempBox'))),
          actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Tooltip(
              message: 'Refresh inbox',
              child: IconButton(
                icon: const Icon(CupertinoIcons.refresh_thick, size: 20),
                onPressed: dataState.selectedAddress == null ? null : () => _refreshInbox(dataBlocContext, dataState.selectedAddress),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'Address information',
              child: IconButton(
                icon: const Icon(CupertinoIcons.info_circle, size: 20),
                onPressed: dataState.selectedAddress == null ? null : () => _showAddressInfo(dataBlocContext, dataState.selectedAddress),
              ),
            ),
            const SizedBox(width: 10),
            const Divider(direction: Axis.vertical),
            const SizedBox(width: 10),
            Tooltip(
              message: dataState.selectedMessage?.seen ?? false ? 'Mark message as unread' : 'Mark message as read',
              child: IconButton(
                icon: Icon(dataState.selectedMessage?.seen ?? false ? CupertinoIcons.envelope_badge : CupertinoIcons.envelope_open, size: 20),
                onPressed: dataState.selectedMessage == null ? null : () => _toggleMessageSeenStatus(dataBlocContext, dataState),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'Delete Message',
              child: IconButton(
                icon: const Icon(CupertinoIcons.trash, size: 20),
                onPressed: dataState.selectedMessage == null ? null : () => _deleteMessage(dataBlocContext, dataState),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'Download Message',
              child: IconButton(
                icon: const Icon(CupertinoIcons.download_circle, size: 20),
                onPressed: dataState.selectedMessage == null ? null : () async {
                  if (dataState.selectedAddress == null || dataState.selectedMessage == null) return;
                  MessageSource? messageSource = await HttpService.getMessageSource(
                    dataState.selectedAddress!.authenticatedUser.token,
                    dataState.selectedMessage!.id,
                  );
                  if (messageSource == null) return;
                  FSService.saveStringToFile(messageSource.data, '${dataState.selectedMessage!.subject}.eml');
                },
              ),
            ),
            const SizedBox(width: 10),
            const Divider(direction: Axis.vertical),
            const SizedBox(width: 10),
            DropDownButton(
              buttonBuilder: (context, onOpen) {
                return IconButton(icon: const Icon(CupertinoIcons.ellipsis_circle, size: 20), onPressed: onOpen);
              },
              title: const Icon(FluentIcons.more, size: 15),
              items: [
                MenuFlyoutItem(
                  text: const Text('Export Addresses'),
                  onPressed: dataState.addressList.isNotEmpty ? () => _exportAddresses(context, dataBlocContext) : null,
                ),
                MenuFlyoutItem(
                  text: const Text('Import Addresses'),
                  onPressed: () => _importAddresses(context, dataBlocContext),
                ),
                const MenuFlyoutSeparator(),
                MenuFlyoutItem(
                  text: const Text('Removed Addresses'),
                  onPressed: dataState.removedAddresses.isNotEmpty ? () => _removedAddresses(context, dataBlocContext) : null,
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Divider(direction: Axis.vertical),
            const SizedBox(width: 10),
            const WindowButtons(),
          ]),
        ),
        pane: NavigationPane(
          header: Card(
            margin: const EdgeInsets.only(right: 15, left: 8, bottom: 15),
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text('New Address', style: FluentTheme.of(context).typography.body),
              trailing: const Icon(CupertinoIcons.add_circled_solid),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<DataBloc>(dataBlocContext),
                    child: const WinuiAddAddress(),
                  ),
                );
              },
            ),
          ),
          onItemPressed: (index) {
            if (dataState.addressList.isEmpty) {
              return;
            }
            if (index < dataState.addressList.length) {
              BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(dataState.addressList[index]));
              return;
            }
          },
          size: NavigationPaneSize(openWidth: MediaQuery.of(context).size.width / 5, openMinWidth: 250, openMaxWidth: 250),
          items: dataState.addressList.map((a) => _buildPaneItem(a, dataState, dataBlocContext)).toList(),
          displayMode: PaneDisplayMode.open,
          toggleable: true,
          selected: selectedIndex,
          footerItems: [
            PaneItemHeader(
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: RichText(
                      text: TextSpan(
                        text: "Powered by ",
                        style: FluentTheme.of(context).typography.body,
                        children: <TextSpan>[
                          TextSpan(
                            text: 'mail.tm',
                            style: TextStyle(color: FluentTheme.of(context).accentColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                bool? choice = await AlertService.getConformation(
                                  context: context,
                                  title: 'Do you want to continue?',
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
                  IconButton(
                    icon: const Icon(FluentIcons.info),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<DataBloc>(dataBlocContext),
                          child: const WinUIAppInfo(),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            PaneItemSeparator(thickness: 0),
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

AccentColor systemAccentColor(SystemAccentColor accentColor) {
  if (Platform.isAndroid || Platform.isWindows) {
    return AccentColor.swatch({
      'darkest': accentColor.darkest,
      'darker': accentColor.darker,
      'dark': accentColor.dark,
      'normal': accentColor.accent,
      'light': accentColor.light,
      'lighter': accentColor.lighter,
      'lightest': accentColor.lightest,
    });
  }
  return Colors.blue;
}

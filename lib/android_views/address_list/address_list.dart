import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tempbox/android_views/android_app_info.dart';
import 'package:tempbox/android_views/import_export/export.dart';
import 'package:tempbox/android_views/import_export/import.dart';
import 'package:tempbox/android_views/removed_addresses/removed_addresses.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/android_views/add_address/add_address.dart';
import 'package:tempbox/android_views/address_list/address_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key, required this.title});
  final String title;

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  _openNewAddressSheet(BuildContext dataBlocContext) {
    OverlayService.showOverLay(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: true,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: const AddAddress(),
      ),
    );
  }

  _handleOptionTap(BuildContext context, BuildContext dataBlocContext, int value) async {
    if (value == 0) {
      OverlayService.showOverLay(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        enableDrag: true,
        builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const ExportPage()),
      );
    } else if (value == 1) {
      List<AddressData>? addresses = await ExportImportAddress.importAddreses();
      if (addresses != null && addresses.isNotEmpty && context.mounted && dataBlocContext.mounted) {
        OverlayService.showOverLay(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          clipBehavior: Clip.hardEdge,
          enableDrag: true,
          builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: ImportPage(addresses: addresses)),
        );
      }
    } else if (value == 2) {
      OverlayService.showOverLay(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        enableDrag: true,
        builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const RemovedAddressesPage()),
      );
    } else {
      OverlayService.showOverLay(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        enableDrag: true,
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<DataBloc>(dataBlocContext),
          child: const AndroidAppInfo(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return SlidableAutoCloseBehavior(
        child: Scaffold(
          body: LayoutBuilder(builder: (context, constraints) {
            bool isVertical = constraints.maxHeight > constraints.maxWidth;
            List<Widget> actions = [
              PopupMenuButton<int>(
                initialValue: null,
                onSelected: (int item) => _handleOptionTap(context, dataBlocContext, item),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    enabled: dataState.addressList.isNotEmpty,
                    value: 0,
                    child: const ListTile(leading: Icon(Icons.arrow_circle_up_rounded), title: Text('Export Addresses')),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: ListTile(leading: Icon(Icons.arrow_circle_down_rounded), title: Text('Import Addresses')),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<int>(
                    enabled: dataState.removedAddresses.isNotEmpty,
                    value: 2,
                    child: const ListTile(leading: Icon(Icons.arrow_circle_down_rounded), title: Text('Removed Addresses')),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<int>(
                    value: 3,
                    child: ListTile(leading: Icon(Icons.info_outline_rounded), title: Text('About TempBox')),
                  ),
                ],
              ),
            ];
            if (dataState.addressList.isEmpty) {
              return CustomScrollView(
                slivers: [SliverAppBar.large(title: const Text('TempBox'), actions: actions)],
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
              },
              child: CustomScrollView(
                slivers: [
                  if (isVertical) SliverAppBar.large(title: Text(widget.title), actions: actions),
                  if (!isVertical) SliverAppBar(title: Text(widget.title), actions: actions, pinned: true),
                  SliverList.builder(
                    itemCount: dataState.addressList.length,
                    itemBuilder: (context, index) => AddressTile(
                      addressData: dataState.addressList[index],
                      isFirst: index == 0,
                      isLast: index == dataState.addressList.length - 1,
                    ),
                  ),
                ],
              ),
            );
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openNewAddressSheet(dataBlocContext),
            tooltip: 'New Address',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: "Powered by ",
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'mail.tm',
                        style: TextStyle(color: theme.hintColor),
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
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

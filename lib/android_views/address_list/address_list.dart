import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tempbox/android_views/import_export/export.dart';
import 'package:tempbox/android_views/import_export/import.dart';
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
    } else {
      showAboutDialog(
        context: context,
        applicationIcon: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
          clipBehavior: Clip.hardEdge,
          child: Image.asset('assets/icon.png'),
        ),
        applicationName: 'TempBox',
        applicationVersion: '1.0.0',
        applicationLegalese: 'Powered by mail.tm',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
        return BlocBuilder<DataBloc, DataState>(
          builder: (dataBlocContext, dataState) {
            return SlidableAutoCloseBehavior(
              child: Scaffold(
                body: Builder(builder: (context) {
                  if (dataState.addressList.isEmpty) {
                    return const CustomScrollView(slivers: [SliverAppBar.large(title: Text('TempBox'))]);
                  }
                  List<AddressData> active = [];
                  List<AddressData> archived = [];
                  addToList(a) => a.isActive ? active.add(a) : archived.add(a);
                  dataState.addressList.forEach(addToList);
                  return RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar.large(
                          title: Text(widget.title),
                          actions: [
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
                                const PopupMenuItem<int>(
                                  value: 2,
                                  child: ListTile(leading: Icon(Icons.info_outline_rounded), title: Text('About TempBox')),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (active.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: Text('Active', style: theme.textTheme.bodyLarge),
                            ),
                          ),
                        SliverList.builder(
                          itemCount: active.length,
                          itemBuilder: (context, index) =>
                              AddressTile(addressData: active[index], isFirst: index == 0, isLast: index == active.length - 1),
                        ),
                        if (archived.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(22, 20, 22, 5),
                              child: Text('Archived', style: theme.textTheme.bodyLarge),
                            ),
                          ),
                        SliverList.builder(
                          itemCount: archived.length,
                          itemBuilder: (context, index) =>
                              AddressTile(addressData: archived[index], isFirst: index == 0, isLast: index == archived.length - 1),
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
          },
        );
      },
    );
  }
}

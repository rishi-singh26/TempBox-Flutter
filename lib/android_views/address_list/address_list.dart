import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tempbox/android_views/import_export/export.dart';
import 'package:tempbox/android_views/import_export/import.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/android_views/add_address/add_address.dart';
import 'package:tempbox/android_views/address_list/address_tile.dart';

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

  _openImportExportPage(BuildContext context, BuildContext dataBlocContext, int value) async {
    if (value == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const ExportPage())),
      );
    } else {
      List<AddressData>? addresses = await ExportImportAddress.importAddreses();
      if (addresses != null && addresses.isNotEmpty && context.mounted && dataBlocContext.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: ImportPage(addresses: addresses)),
          ),
        );
        // BlocProvider.of<DataBloc>(dataBlocContext).add(ImportAddresses(addresses: addresses));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
        return BlocBuilder<DataBloc, DataState>(
          builder: (dataBlocContext, dataState) {
            return SlidableAutoCloseBehavior(
              child: Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar.large(title: Text(widget.title)),
                    SliverList.builder(
                      itemCount: dataState.addressList.length,
                      itemBuilder: (context, index) => AddressTile(index: index),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _openNewAddressSheet(dataBlocContext),
                  tooltip: 'New Address',
                  child: const Icon(Icons.add),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: 'About TempBox',
                        icon: const Icon(Icons.info_outline_rounded),
                        onPressed: () {},
                      ),
                      PopupMenuButton<int>(
                        initialValue: null,
                        icon: const Icon(CupertinoIcons.arrow_up_arrow_down_circle),
                        onSelected: (int item) => _openImportExportPage(context, dataBlocContext, item),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                          PopupMenuItem<int>(
                            enabled: dataState.addressList.isNotEmpty,
                            value: 0,
                            child: const ListTile(leading: Icon(CupertinoIcons.arrow_up_circle), title: Text('Export Addresses')),
                          ),
                          const PopupMenuItem<int>(
                            value: 1,
                            child: ListTile(leading: Icon(CupertinoIcons.arrow_down_circle), title: Text('Import Addresses')),
                          ),
                        ],
                      ),
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

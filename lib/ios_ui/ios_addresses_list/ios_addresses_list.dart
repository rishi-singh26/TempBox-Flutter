import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/ios_ui/ios_search_bar.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/bottom_bar.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/ios_address_tile.dart';
import 'package:tempbox/ios_ui/app_info/ios_app_info.dart';
import 'package:tempbox/ios_ui/ios_import_export/ios_export.dart';
import 'package:tempbox/ios_ui/ios_import_export/ios_import.dart';
import 'package:tempbox/ios_ui/ios_removed_addresses/ios_removed_addresses.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/export_import_address.dart';

class IosAddressesList extends StatefulWidget {
  final List<AddressData> addressList;
  const IosAddressesList({super.key, required this.addressList});

  @override
  IosAddressesListState createState() => IosAddressesListState();
}

class IosAddressesListState extends State<IosAddressesList> {
  String _searchFieldText = "";

  @override
  void initState() {
    prepareAddressesForAppRewrite(widget.addressList);
    super.initState();
  }

  void prepareAddressesForAppRewrite(List<AddressData> addressList) async {
    await ExportImportAddress.prepareAddresesForMajorUpdate(addressList);
  }

  _handleOptionTap(BuildContext context, BuildContext dataBlocContext, int value) async {
    if (value == 0) {
      showCupertinoModalSheet(
        context: context,
        builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const IosExportPage()),
      );
    } else if (value == 1) {
      List<AddressData>? addresses = await ExportImportAddress.importAddreses();
      if (addresses != null && addresses.isNotEmpty && context.mounted && dataBlocContext.mounted) {
        showCupertinoModalSheet(
          context: context,
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<DataBloc>(dataBlocContext),
            child: IosImportPage(addresses: addresses),
          ),
        );
      }
    } else if (value == 2) {
      showCupertinoModalSheet(
        context: context,
        builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const IosRemovedAddressesPage()),
      );
    } else {
      showCupertinoModalSheet(
        context: context,
        builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const IosAppInfo()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              bool isVertical = constraints.maxHeight > constraints.maxWidth;
              double horizontalPadding = isVertical ? 20 : 80;
              return SlidableAutoCloseBehavior(
                child: CustomScrollView(
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
                      },
                    ),
                    CupertinoSliverNavigationBar(
                      backgroundColor: AppColors.navBarColor,
                      largeTitle: const Text('TempBox'),
                      border: null,
                      trailing: PullDownButton(
                        itemBuilder: (context) => [
                          PullDownMenuItem(
                            enabled: dataState.addressList.isNotEmpty,
                            title: 'Export Addresses',
                            icon: CupertinoIcons.arrow_up_circle,
                            onTap: () => _handleOptionTap(context, dataBlocContext, 0),
                          ),
                          PullDownMenuItem(
                            title: 'Import Addresses',
                            icon: CupertinoIcons.arrow_down_circle,
                            onTap: () => _handleOptionTap(context, dataBlocContext, 1),
                          ),
                          const PullDownMenuDivider.large(),
                          PullDownMenuItem(
                            enabled: dataState.removedAddresses.isNotEmpty,
                            title: 'Removed Addresses',
                            icon: CupertinoIcons.clear_circled,
                            onTap: () => _handleOptionTap(context, dataBlocContext, 2),
                          ),
                          const PullDownMenuDivider.large(),
                          PullDownMenuItem(
                            title: 'About TempBox',
                            icon: CupertinoIcons.info_circle,
                            onTap: () => _handleOptionTap(context, dataBlocContext, 3),
                          ),
                        ],
                        buttonBuilder: (context, showMenu) => CupertinoButton(
                          onPressed: showMenu,
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.ellipsis_circle),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: isVertical ? 22 : 82),
                        child: IosSearchBar(onChange: (val) => setState(() => _searchFieldText = val)),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(99, 251, 239, 127),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'A major update is on the way! The new version is a complete rewrite of the app and ',
                                    style: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color),
                                  ),
                                  TextSpan(
                                    text: 'may result in data loss',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '. Please ',
                                    style: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color),
                                  ),
                                  TextSpan(
                                    text: 'export your saved addresses',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' by clicking on the menu button ',
                                    style: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color),
                                  ),
                                  WidgetSpan(
                                    child: Icon(
                                      CupertinoIcons.ellipsis_circle,
                                      size: 17,
                                      color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' before updating to avoid losing your addresses.',
                                    style: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Builder(builder: (context) {
                      if (dataState.addressList.isEmpty) {
                        return const SliverToBoxAdapter(child: Center(child: Text('')));
                      }
                      List<Widget> children = [];
                      for (var i = 0; i < dataState.addressList.length; i++) {
                        final AddressData address = dataState.addressList[i];
                        if (_searchFieldText.isNotEmpty) {
                          if (address.addressName.toLowerCase().contains(_searchFieldText.toLowerCase()) ||
                              address.authenticatedUser.account.address.toLowerCase().contains(_searchFieldText.toLowerCase())) {
                            children.add(IosAddressTile(addressData: address, key: Key(address.authenticatedUser.account.id)));
                          }
                        } else {
                          children.add(IosAddressTile(addressData: address, key: Key(address.authenticatedUser.account.id)));
                        }
                      }
                      return SliverList.list(
                        children: [
                          if (children.isNotEmpty)
                            CupertinoListSection.insetGrouped(
                              margin: EdgeInsetsDirectional.fromSTEB(horizontalPadding, 0, horizontalPadding, 10),
                              key: const Key('ActiveAccounts'),
                              children: children,
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              );
            }),
            const Positioned(bottom: 0, left: 0, right: 0, child: BottomBar()),
          ],
        );
      }),
    );
  }
}

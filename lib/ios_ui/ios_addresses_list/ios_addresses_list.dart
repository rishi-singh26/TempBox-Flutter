import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/bottom_bar.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/ios_address_tile.dart';
import 'package:tempbox/ios_ui/app_info/ios_app_info.dart';
import 'package:tempbox/ios_ui/ios_import_export/ios_export.dart';
import 'package:tempbox/ios_ui/ios_import_export/ios_import.dart';
import 'package:tempbox/ios_ui/ios_removed_addresses/ios_removed_addresses.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/export_import_address.dart';

class IosAddressesList extends StatelessWidget {
  const IosAddressesList({super.key});

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
                    Builder(builder: (context) {
                      if (dataState.addressList.isEmpty) {
                        return const SliverToBoxAdapter(child: Center(child: Text('')));
                      }
                      List<Widget> children = [];
                      for (var i = 0; i < dataState.addressList.length; i++) {
                        children.add(IosAddressTile(
                          addressData: dataState.addressList[i],
                          key: Key(dataState.addressList[i].authenticatedUser.account.id),
                        ));
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
            const BottomBar(),
          ],
        );
      }),
    );
  }
}

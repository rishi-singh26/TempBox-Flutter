import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/bottom_bar.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/ios_address_tile.dart';
import 'package:tempbox/ios_ui/ios_import_export/ios_export.dart';
import 'package:tempbox/ios_ui/ios_import_export/ios_import.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/export_import_address.dart';

class IosAddressesList extends StatelessWidget {
  const IosAddressesList({super.key});

  _openImportExportPage(BuildContext context, BuildContext dataBlocContext, int value) async {
    if (value == 0) {
      showCupertinoModalSheet(
        context: context,
        builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const IosExportPage()),
      );
    } else {
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
            CustomScrollView(
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
                        title: 'Export Addresses',
                        icon: CupertinoIcons.arrow_up_circle,
                        onTap: dataState.addressList.isNotEmpty ? () => _openImportExportPage(context, dataBlocContext, 0) : null,
                      ),
                      PullDownMenuItem(
                        title: 'Import Addresses',
                        icon: CupertinoIcons.arrow_down_circle,
                        onTap: () => _openImportExportPage(context, dataBlocContext, 1),
                      ),
                      const PullDownMenuDivider.large(),
                      PullDownMenuItem(
                        title: 'About TempBox',
                        icon: CupertinoIcons.info_circle,
                        onTap: () {},
                      ),
                    ],
                    buttonBuilder: (context, showMenu) => CupertinoButton(
                      onPressed: showMenu,
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.ellipsis_circle),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 8, 20, 14),
                    child: CupertinoSearchTextField(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CupertinoListSection.insetGrouped(
                    margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 101),
                    header: dataState.addressList.isEmpty ? const Text('No addreses available') : null,
                    children: List.generate(dataState.addressList.length, (index) {
                      return IosAddressTile(index: index);
                    }),
                  ),
                ),
              ],
            ),
            const BottomBar(),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/cup_ui/colors.dart';
import 'package:tempbox/cup_ui/cup_addresses_list/bottom_bar.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';

class CupAddressesList extends StatelessWidget {
  const CupAddressesList({super.key});

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
                const CupertinoSliverNavigationBar(
                  backgroundColor: AppColors.navBarColor,
                  largeTitle: Text('TempBox'),
                  border: null,
                  stretch: true,
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
                    children: List.generate(dataState.addressList.length, (index) {
                      AddressData address = dataState.addressList[index];
                      return CupertinoListTile.notched(
                        title: Text(UiService.getAccountName(address)),
                        leading: const Icon(CupertinoIcons.tray),
                        trailing: const CupertinoListTileChevron(),
                      );
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

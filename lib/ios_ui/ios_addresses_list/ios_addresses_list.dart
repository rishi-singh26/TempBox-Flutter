import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/bottom_bar.dart';
import 'package:tempbox/ios_ui/ios_messages_list/ios_messages_list.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';

class IosAddressesList extends StatelessWidget {
  const IosAddressesList({super.key});

  _navigateToMessagesList(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(addressData));
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: const IosMessagesList(),
      ),
    ));
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
                  // builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
                  //   return Text(pulledExtent.toString());
                  // },
                  onRefresh: () async {
                    BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
                  },
                ),
                const CupertinoSliverNavigationBar(
                  backgroundColor: AppColors.navBarColor,
                  largeTitle: Text('TempBox'),
                  border: null,
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
                      AddressData address = dataState.addressList[index];
                      return CupertinoListTile.notched(
                        title: Text(UiService.getAccountName(address)),
                        leading: const Icon(CupertinoIcons.tray),
                        trailing: const CupertinoListTileChevron(),
                        additionalInfo: Text((dataState.accountIdToAddressesMap[address.authenticatedUser.account.id]?.length ?? '').toString()),
                        onTap: () => _navigateToMessagesList(context, dataBlocContext, address),
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

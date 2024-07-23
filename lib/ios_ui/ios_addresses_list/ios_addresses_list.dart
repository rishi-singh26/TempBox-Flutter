import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/bottom_bar.dart';
import 'package:tempbox/ios_ui/ios_addresses_list/ios_address_tile.dart';

class IosAddressesList extends StatelessWidget {
  const IosAddressesList({super.key});

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

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';

class IosMessagesList extends StatelessWidget {
  const IosMessagesList({super.key});

  _onRefresh(BuildContext dataBlocContext, AddressData address) async {
    BlocProvider.of<DataBloc>(dataBlocContext).add(GetMessagesEvent(addressData: address));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
        if (dataState.selectedAddress == null) {
          return const CustomScrollView(slivers: [
            CupertinoSliverNavigationBar(backgroundColor: AppColors.navBarColor, largeTitle: Text('Inbox')),
            SliverToBoxAdapter(child: Center(child: Text('Address not selected'))),
          ]);
        }
        List<Message>? messages = dataState.accountIdToAddressesMap[dataState.selectedAddress!.authenticatedUser.account.id];
        if (messages == null || messages.isEmpty) {
          return CustomScrollView(slivers: [
            CupertinoSliverRefreshControl(onRefresh: () => _onRefresh(dataBlocContext, dataState.selectedAddress!)),
            CupertinoSliverNavigationBar(
              backgroundColor: AppColors.navBarColor,
              largeTitle: Text(dataState.selectedAddress!.addressName),
            ),
            const SliverToBoxAdapter(child: Center(child: Text('No message available'))),
          ]);
        }
        return CustomScrollView(slivers: [
          CupertinoSliverRefreshControl(onRefresh: () => _onRefresh(dataBlocContext, dataState.selectedAddress!)),
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.navBarColor,
            largeTitle: Text(dataState.selectedAddress!.addressName),
            border: null,
            previousPageTitle: 'TempBox',
          ),
          SliverList.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return CupertinoListTile.notched(
                leadingSize: 10,
                title: Text(UiService.getMessageFromName(message)),
                subtitle: Text(UiService.getMessageFromName(message)),
                leading: const BlankBadge(),
                onTap: () {},
              );
            },
          ),
        ]);
      }),
    );
  }
}

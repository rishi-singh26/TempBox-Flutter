import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/ios_ui/ios_messages_list/ios_message_tile.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';

class IosMessagesList extends StatelessWidget {
  const IosMessagesList({super.key});

  _onRefresh(BuildContext dataBlocContext, AddressData address) async {
    BlocProvider.of<DataBloc>(dataBlocContext).add(GetMessagesEvent(addressData: address));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedAddress == null) {
        return const CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: CustomScrollView(slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: AppColors.navBarColor,
              largeTitle: Text('Inbox'),
              border: null,
              previousPageTitle: 'TempBox',
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 400, child: Center(child: Text('Address not selected'))),
            ),
          ]),
        );
      }
      List<Message>? messages = dataState.accountIdToMessagesMap[dataState.selectedAddress!.authenticatedUser.account.id];
      if (messages == null || messages.isEmpty) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: SafeArea(
            child: CustomScrollView(slivers: [
              CupertinoSliverRefreshControl(onRefresh: () => _onRefresh(dataBlocContext, dataState.selectedAddress!)),
              CupertinoSliverNavigationBar(
                border: null,
                backgroundColor: AppColors.navBarColor,
                largeTitle: Text(UiService.getAccountName(dataState.selectedAddress!)),
                previousPageTitle: 'TempBox',
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 400, child: Center(child: Text('No message available'))),
              ),
            ]),
          ),
        );
      }
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: SlidableAutoCloseBehavior(
          child: SafeArea(
            child: CustomScrollView(slivers: [
              CupertinoSliverRefreshControl(onRefresh: () => _onRefresh(dataBlocContext, dataState.selectedAddress!)),
              CupertinoSliverNavigationBar(
                backgroundColor: AppColors.navBarColor,
                largeTitle: Text(UiService.getAccountName(dataState.selectedAddress!)),
                border: null,
                previousPageTitle: 'TempBox',
              ),
              SliverList.separated(
                separatorBuilder: (context, index) => Container(
                  margin: const EdgeInsetsDirectional.only(start: 34),
                  color: CupertinoColors.separator.resolveFrom(context),
                  height: 1.0,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return IosMessageTile(message: messages[index], selectedAddress: dataState.selectedAddress!);
                },
              ),
            ]),
          ),
        ),
      );
    });
  }
}

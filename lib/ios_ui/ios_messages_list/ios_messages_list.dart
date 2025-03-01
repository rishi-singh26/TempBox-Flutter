import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/ios_ui/ios_address_info/ios_address_info.dart';
import 'package:tempbox/ios_ui/ios_messages_list/ios_message_tile.dart';
import 'package:tempbox/ios_ui/ios_search_bar.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/ui_service.dart';

class IosMessagesList extends StatefulWidget {
  const IosMessagesList({super.key});

  @override
  State<IosMessagesList> createState() => _IosMessagesListState();
}

class _IosMessagesListState extends State<IosMessagesList> {
  String _searchFieldText = "";

  _onRefresh(BuildContext dataBlocContext, AddressData address) async {
    BlocProvider.of<DataBloc>(dataBlocContext).add(GetMessagesEvent(addressData: address));
  }

  _openAddressInfoSheet(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    showCupertinoModalSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: IosAddressInfo(addressData: addressData),
      ),
    );
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
      List<MessageData>? messages = dataState.accountIdToMessagesMap[dataState.selectedAddress!.authenticatedUser.account.id];
      if (messages == null || messages.isEmpty) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: CustomScrollView(slivers: [
            CupertinoSliverRefreshControl(onRefresh: () => _onRefresh(dataBlocContext, dataState.selectedAddress!)),
            CupertinoSliverNavigationBar(
              border: null,
              backgroundColor: AppColors.navBarColor,
              largeTitle: Text(UiService.getAccountName(dataState.selectedAddress!)),
              previousPageTitle: 'TempBox',
              trailing: CupertinoButton(
                onPressed: () => _openAddressInfoSheet(context, dataBlocContext, dataState.selectedAddress!),
                child: const Icon(CupertinoIcons.info_circle),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 400, child: Center(child: Text('No message available'))),
            ),
          ]),
        );
      }
      List<MessageData>? filteredMessages = _searchFieldText.isNotEmpty ? [] : messages;
      if (_searchFieldText.isNotEmpty) {
        for (var i = 0; i < messages.length; i++) {
          final MessageData message = messages[i];
          if (message.subject.toLowerCase().contains(_searchFieldText.toLowerCase()) ||
              (message.from['name'] ?? '').toLowerCase().contains(_searchFieldText.toLowerCase()) ||
              (message.from['address'] ?? '').toLowerCase().contains(_searchFieldText.toLowerCase())) {
            filteredMessages.add(message);
          }
        }
      }
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: SlidableAutoCloseBehavior(
          child: LayoutBuilder(builder: (context, constraints) {
            bool isVertical = constraints.maxHeight > constraints.maxWidth;
            double horizontalPadding = isVertical ? 0 : 50;
            return CustomScrollView(slivers: [
              CupertinoSliverRefreshControl(onRefresh: () => _onRefresh(dataBlocContext, dataState.selectedAddress!)),
              CupertinoSliverNavigationBar(
                backgroundColor: AppColors.navBarColor,
                largeTitle: Text(UiService.getAccountName(dataState.selectedAddress!)),
                border: null,
                previousPageTitle: 'TempBox',
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _openAddressInfoSheet(context, dataBlocContext, dataState.selectedAddress!),
                  child: const Icon(CupertinoIcons.info_circle),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: isVertical ? 22 : 82),
                  child: IosSearchBar(onChange: (val) => setState(() => _searchFieldText = val)),
                ),
              ),
              SliverList.separated(
                separatorBuilder: (context, index) => Container(
                  margin: const EdgeInsetsDirectional.only(start: 34),
                  color: CupertinoColors.separator.resolveFrom(context),
                  height: 1.0,
                ),
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: IosMessageTile(message: filteredMessages[index], selectedAddress: dataState.selectedAddress!),
                  );
                },
              ),
            ]);
          }),
        ),
      );
    });
  }
}

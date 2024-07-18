import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/views/messages_list/message_tile.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

  // _openAddressInfoSheet(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
  //   OverlayService.showOverLay(
  //     context: context,
  //     useSafeArea: true,
  //     isScrollControlled: true,
  //     clipBehavior: Clip.hardEdge,
  //     enableDrag: true,
  //     builder: (context) => BlocProvider.value(
  //       value: BlocProvider.of<DataBloc>(dataBlocContext),
  //       child: AddressInfo(addressData: addressData),
  //     ),
  //   );
  // }mctomcagaq@belgianairways.com

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedAddress == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('No Address Selected!')),
        );
      }
      Stream<List<Message>> messagesStream = dataState.selectedAddress!.authenticatedUser.allMessages();
      return Scaffold(
        body: SlidableAutoCloseBehavior(
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(UiService.getAccountName(dataState.selectedAddress!)),
                // actions: [
                //   IconButton(
                //     onPressed: () => _openAddressInfoSheet(context, dataBlocContext, dataState.selectedAddress!),
                //     icon: const Icon(CupertinoIcons.info_circle_fill),
                //   )
                // ],
              ),
              StreamBuilder<List<Message>>(
                stream: messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text("Something went wrong ${snapshot.error.toString()}")),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: CircularProgressIndicator.adaptive());
                  }
                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                    return const SliverToBoxAdapter(child: Center(child: Text("No items in inbox")));
                  }
                  return SliverList.separated(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Message message = snapshot.data![index];
                      return MessageTile(message: message, selectedAddress: dataState.selectedAddress!);
                    },
                    separatorBuilder: (context, index) => const Divider(indent: 20, height: 1),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

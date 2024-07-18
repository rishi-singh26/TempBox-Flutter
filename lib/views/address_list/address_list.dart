import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';
import 'package:tempbox/views/add_address/add_address.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key, required this.title});
  final String title;

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  _openNewAddressSheet(BuildContext dataBlocContext) {
    OverlayService.showOverLay(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: true,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: const AddAddress(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(title: Text(widget.title)),
            SliverList.builder(
              itemCount: dataState.addressList.length,
              itemBuilder: (context, index) {
                return CardListTile(
                  isFirst: index == 0,
                  isLast: index == dataState.addressList.length - 1,
                  child: ListTile(title: Text(dataState.addressList[index].addressName)),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openNewAddressSheet(dataBlocContext),
          tooltip: 'New Address',
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_rounded),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Search',
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
              )
            ],
          ),
        ),
      );
    });
  }
}

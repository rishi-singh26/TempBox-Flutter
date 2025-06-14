import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';

class ImportPage extends StatefulWidget {
  final List<AddressData> addresses;
  const ImportPage({super.key, required this.addresses});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  List<int> selectedAddressIndices = [];

  void _onItemTapped(int item) {
    setState(() {
      if (selectedAddressIndices.contains(item)) {
        selectedAddressIndices.remove(item);
      } else {
        selectedAddressIndices.add(item);
      }
    });
  }

  Future<void> importAddresses(List<AddressData> allAddresses, BuildContext context, BuildContext dataBlocContext) async {
    if (selectedAddressIndices.isEmpty) {
      return;
    }
    List<AddressData> selectedAddresses = [];
    addToList(i) => selectedAddresses.add(allAddresses[i]);
    selectedAddressIndices.forEach(addToList);
    selectedAddressIndices = [];
    BlocProvider.of<DataBloc>(dataBlocContext).add(ImportAddresses(addresses: selectedAddresses));
  }

  List<int> _getAlredyAvailableAddressesIndices(List<AddressData> addressList) {
    List<int> alredyAvailableAddressesIndices = [];
    for (var i = 0; i < widget.addresses.length; i++) {
      AddressData address = widget.addresses[i];
      AddressData? alredyAvailableAddress = addressList
          .where((a) => a.authenticatedUser.account.address == address.authenticatedUser.account.address && a.password == address.password)
          .firstOrNull;
      if (alredyAvailableAddress != null) {
        alredyAvailableAddressesIndices.add(i);
      }
    }
    return alredyAvailableAddressesIndices;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      List<int> alredyAvailableAddressesIndices = _getAlredyAvailableAddressesIndices(dataState.addressList);
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Import Addresses'),
              actions: [
                TextButton(
                  onPressed: selectedAddressIndices.isEmpty ? null : () => importAddresses(widget.addresses, context, dataBlocContext),
                  child: const Text('Import'),
                ),
              ],
            ),
            SliverList.builder(
              itemCount: widget.addresses.length,
              itemBuilder: (context, index) {
                AddressData address = widget.addresses[index];
                bool isSelected = alredyAvailableAddressesIndices.contains(index) ? true : selectedAddressIndices.contains(index);
                return CardListTile(
                  isFirst: index == 0,
                  isLast: index == widget.addresses.length - 1,
                  child: ListTile(
                    leading: Icon(isSelected ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.square),
                    selected: isSelected,
                    title: Text(UiService.getAccountName(address)),
                    subtitle: Text(address.authenticatedUser.account.address),
                    onTap: alredyAvailableAddressesIndices.contains(index) ? null : () => _onItemTapped(index),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

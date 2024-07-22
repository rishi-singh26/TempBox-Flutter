import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';

class WinuiImport extends StatefulWidget {
  final List<AddressData> addresses;
  const WinuiImport({super.key, required this.addresses});

  @override
  State<WinuiImport> createState() => _WinuiImportState();
}

class _WinuiImportState extends State<WinuiImport> {
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
    for (var i = 0; i < addressList.length; i++) {
      AddressData address = addressList[i];
      AddressData? alredyAvailableAddress =
          addressList.where((a) => a.addressName == address.addressName && a.password == address.password).firstOrNull;
      if (alredyAvailableAddress != null) {
        alredyAvailableAddressesIndices.add(i);
      }
    }
    return alredyAvailableAddressesIndices;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Import Addresses'),
        content: Builder(builder: (context) {
          if (widget.addresses.isEmpty) {
            return const SingleChildScrollView(child: ListBody(children: [Text('No address available to import')]));
          }
          List<int> alredyAvailableAddressesIndices = _getAlredyAvailableAddressesIndices(dataState.addressList);
          return ListView.builder(
            shrinkWrap: true,
            itemCount: widget.addresses.length,
            itemBuilder: (context, index) {
              AddressData addressData = widget.addresses[index];
              return ListTile.selectable(
                selected: alredyAvailableAddressesIndices.contains(index) ? true : selectedAddressIndices.contains(index),
                selectionMode: ListTileSelectionMode.multiple,
                title: Text(addressData.addressName.isNotEmpty ? addressData.addressName : addressData.authenticatedUser.account.address),
                subtitle: Text(addressData.authenticatedUser.account.address),
                onSelectionChange: alredyAvailableAddressesIndices.contains(index) ? null : (value) => _onItemTapped(index),
              );
            },
          );
        }),
        actions: [
          Button(onPressed: Navigator.of(context).pop, child: const Text('Close')),
          // const Spacer(),
          FilledButton(
            onPressed: selectedAddressIndices.isEmpty ? null : () => importAddresses(widget.addresses, context, dataBlocContext),
            child: const Text('Import'),
          )
        ],
      );
    });
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';

class WinuiRemovedAddresses extends StatefulWidget {
  const WinuiRemovedAddresses({super.key});

  @override
  State<WinuiRemovedAddresses> createState() => _WinuiRemovedAddressesState();
}

class _WinuiRemovedAddressesState extends State<WinuiRemovedAddresses> {
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

  Future<void> _restoreAddresses(List<AddressData> allAddresses, BuildContext context, BuildContext dataBlocContext) async {
    if (selectedAddressIndices.isEmpty) {
      return;
    }
    List<AddressData> selectedAddresses = [];
    addToList(i) => selectedAddresses.add(allAddresses[i]);
    selectedAddressIndices.forEach(addToList);
    selectedAddressIndices = [];
    BlocProvider.of<DataBloc>(dataBlocContext).add(RestoreAddressesEvent(selectedAddresses));
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Removed Addresses')],
        ),
        content: Builder(builder: (context) {
          if (dataState.removedAddresses.isEmpty) {
            return const SingleChildScrollView(child: ListBody(children: [Text('No address available to restore')]));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: dataState.removedAddresses.length,
            itemBuilder: (context, index) {
              AddressData addressData = dataState.removedAddresses[index];
              return ListTile.selectable(
                selected: selectedAddressIndices.contains(index),
                selectionMode: ListTileSelectionMode.multiple,
                title: Text(addressData.addressName.isNotEmpty ? addressData.addressName : addressData.authenticatedUser.account.address),
                subtitle: Text(addressData.authenticatedUser.account.address),
                onSelectionChange: (val) => _onItemTapped(index),
              );
            },
          );
        }),
        actions: [
          Button(onPressed: Navigator.of(context).pop, child: const Text('Close')),
          // const Spacer(),
          FilledButton(
            onPressed: selectedAddressIndices.isEmpty ? null : () => _restoreAddresses(dataState.removedAddresses, context, dataBlocContext),
            child: const Text('Restore'),
          )
        ],
      );
    });
  }
}

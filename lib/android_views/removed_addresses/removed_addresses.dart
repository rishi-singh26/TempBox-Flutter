import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';

class RemovedAddressesPage extends StatefulWidget {
  const RemovedAddressesPage({super.key});

  @override
  State<RemovedAddressesPage> createState() => _RemovedAddressesPageState();
}

class _RemovedAddressesPageState extends State<RemovedAddressesPage> {
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
      AlertService.showAlert(context: context, title: 'Alert', content: 'Selected addresses were restored');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Export Addresses'),
              actions: [
                TextButton(
                  onPressed: selectedAddressIndices.isEmpty ? null : () => _restoreAddresses(dataState.removedAddresses, context, dataBlocContext),
                  child: const Text('Restore'),
                )
              ],
            ),
            SliverList.builder(
              itemCount: dataState.removedAddresses.length,
              itemBuilder: (context, index) {
                AddressData address = dataState.removedAddresses[index];
                bool isSelected = selectedAddressIndices.contains(index);
                return CardListTile(
                  isFirst: index == 0,
                  isLast: index == dataState.removedAddresses.length - 1,
                  child: ListTile(
                    leading: Icon(isSelected ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.square),
                    selected: isSelected,
                    title: Text(UiService.getAccountName(address)),
                    subtitle: Text(address.authenticatedUser.account.address),
                    onTap: () => _onItemTapped(index),
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
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

  Future<void> _exportAddresses(List<AddressData> allAddresses, BuildContext context) async {
    if (selectedAddressIndices.isEmpty) {
      return;
    }
    List<AddressData> selectedAddresses = [];
    addToList(i) => selectedAddresses.add(allAddresses[i]);
    selectedAddressIndices.forEach(addToList);
    selectedAddressIndices = [];
    bool? result = await ExportImportAddress.exportAddreses(selectedAddresses);
    if (context.mounted) {
      AlertService.showAlert(
        context: context,
        title: 'Alert',
        content: result == true ? 'Selected addresses exported successfully.' : 'Something went wrong, addresses not exported',
      );
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
                  onPressed: selectedAddressIndices.isEmpty ? null : () => _exportAddresses(dataState.addressList, context),
                  child: const Text('Export'),
                )
              ],
            ),
            SliverList.builder(
              itemCount: dataState.addressList.length,
              itemBuilder: (context, index) {
                AddressData address = dataState.addressList[index];
                bool isSelected = selectedAddressIndices.contains(index);
                return CardListTile(
                  isFirst: index == 0,
                  isLast: index == dataState.addressList.length - 1,
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

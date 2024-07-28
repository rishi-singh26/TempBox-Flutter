import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';

class IosImportPage extends StatefulWidget {
  final List<AddressData> addresses;
  const IosImportPage({super.key, required this.addresses});

  @override
  State<IosImportPage> createState() => _IosImportPageState();
}

class _IosImportPageState extends State<IosImportPage> {
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
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: MediaQuery.of(context).platformBrightness != Brightness.dark ? AppColors.navBarColor : null,
              border: null,
              largeTitle: const Text('Import Addresses'),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: selectedAddressIndices.isEmpty ? null : () => importAddresses(widget.addresses, context, dataBlocContext),
                child: const Text('Import', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList.list(children: [
              CupertinoListSection.insetGrouped(
                children: List.generate(widget.addresses.length, (index) {
                  AddressData address = widget.addresses[index];
                  bool isSelected = alredyAvailableAddressesIndices.contains(index) ? true : selectedAddressIndices.contains(index);
                  return CupertinoListTile.notched(
                    leading: Icon(isSelected ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.square),
                    title: Text(UiService.getAccountName(address)),
                    subtitle: Text(address.authenticatedUser.account.address),
                    onTap: alredyAvailableAddressesIndices.contains(index) ? null : () => _onItemTapped(index),
                  );
                }),
              )
            ]),
          ],
        ),
      );
    });
  }
}

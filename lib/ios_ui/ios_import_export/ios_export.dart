import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/services/ui_service.dart';

class IosExportPage extends StatefulWidget {
  const IosExportPage({super.key});

  @override
  State<IosExportPage> createState() => _IosExportPageState();
}

class _IosExportPageState extends State<IosExportPage> {
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
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: MediaQuery.of(context).platformBrightness != Brightness.dark ? AppColors.navBarColor : null,
              largeTitle: const Text('Export Addresses'),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: selectedAddressIndices.isEmpty ? null : () => _exportAddresses(dataState.addressList, context),
                child: const Text('Export', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList.list(children: [
              CupertinoListSection.insetGrouped(
                children: List.generate(dataState.addressList.length, (index) {
                  AddressData address = dataState.addressList[index];
                  bool isSelected = selectedAddressIndices.contains(index);
                  return CupertinoListTile.notched(
                    leading: Icon(isSelected ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.square),
                    title: Text(UiService.getAccountName(address)),
                    subtitle: Text(address.authenticatedUser.account.address),
                    onTap: () => _onItemTapped(index),
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

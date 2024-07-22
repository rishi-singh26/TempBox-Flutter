import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';

class WinuiExport extends StatefulWidget {
  const WinuiExport({super.key});

  @override
  State<WinuiExport> createState() => _WinuiExportState();
}

class _WinuiExportState extends State<WinuiExport> {
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

  Future<void> exportAddresses(List<AddressData> allAddresses, BuildContext context) async {
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
    final theme = FluentTheme.of(context);
    SizedBox vGap(double size) => SizedBox(height: size);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export Addresses'),
            vGap(3),
            Text('Exported file can be used to view your emails, keep them safe.', style: theme.typography.caption),
          ],
        ),
        content: Builder(builder: (context) {
          if (dataState.addressList.isEmpty) {
            return const SingleChildScrollView(child: ListBody(children: [Text('No address available to export')]));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: dataState.addressList.length,
            itemBuilder: (context, index) {
              AddressData addressData = dataState.addressList[index];
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
            onPressed: selectedAddressIndices.isEmpty ? null : () => exportAddresses(dataState.addressList, context),
            child: const Text('Export'),
          )
        ],
      );
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macos_card.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';

class MacuiExport extends StatefulWidget {
  const MacuiExport({super.key});

  @override
  State<MacuiExport> createState() => _MacuiExportState();
}

class _MacuiExportState extends State<MacuiExport> {
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
    final theme = MacosTheme.of(context);
    SizedBox vGap(double size) => SizedBox(height: size);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return LayoutBuilder(builder: (context, constraints) {
        return MacosSheet(
          insetPadding: EdgeInsets.symmetric(
            horizontal: (constraints.maxWidth - 600) / 2,
            vertical: (constraints.maxHeight - 400) / 2,
          ),
          child: Builder(builder: (context) {
            if (dataState.addressList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(children: [
                  Text('Export Addresses', style: theme.typography.title1),
                  vGap(24),
                  const Text('No address available to export'),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PushButton(
                      controlSize: ControlSize.regular,
                      child: const Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ]),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  vGap(24),
                  Text('Export Addresses', style: theme.typography.title1),
                  const Text('Exported file can be used to view your emails, keep them safe.'),
                  vGap(15),
                  SizedBox(
                    height: 250,
                    child: MacosCard(
                      isFirst: true,
                      isLast: true,
                      padding: EdgeInsets.zero,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: dataState.addressList.length,
                        itemBuilder: (context, index) {
                          AddressData addressData = dataState.addressList[index];
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: MacosListTile(
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 8.0, right: 10, left: 8),
                                child: MacosCheckbox(
                                  value: selectedAddressIndices.contains(index),
                                  onChanged: (value) => _onItemTapped(index),
                                ),
                              ),
                              title:
                                  Text(addressData.addressName.isNotEmpty ? addressData.addressName : addressData.authenticatedUser.account.address),
                              subtitle: Text(addressData.authenticatedUser.account.address),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PushButton(controlSize: ControlSize.regular, onPressed: Navigator.of(context).pop, secondary: true, child: const Text('Close')),
                      PushButton(
                          controlSize: ControlSize.regular,
                          onPressed: selectedAddressIndices.isEmpty
                              ? null
                              : () async {
                                  await exportAddresses(dataState.addressList, context);
                                  context.mounted ? Navigator.of(context).pop() : null;
                                },
                          child: const Text('Export')),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        );
      });
    });
  }
}

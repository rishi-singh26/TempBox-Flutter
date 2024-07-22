import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macos_card.dart';
import 'package:tempbox/models/address_data.dart';

class MacuiImport extends StatefulWidget {
  final List<AddressData> addresses;
  const MacuiImport({super.key, required this.addresses});

  @override
  State<MacuiImport> createState() => _MacuiImportState();
}

class _MacuiImportState extends State<MacuiImport> {
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
            if (widget.addresses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(children: [
                  Text('Import Addresses', style: theme.typography.title1),
                  vGap(24),
                  const Text('No address available to import'),
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
            List<int> alredyAvailableAddressesIndices = _getAlredyAvailableAddressesIndices(dataState.addressList);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  vGap(24),
                  Text('Import Addresses', style: theme.typography.title1),
                  vGap(15),
                  SizedBox(
                    height: 250,
                    child: MacosCard(
                      isFirst: true,
                      isLast: true,
                      padding: EdgeInsets.zero,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.addresses.length,
                        itemBuilder: (context, index) {
                          AddressData addressData = widget.addresses[index];
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: MacosListTile(
                              leading: Padding(
                                padding: const EdgeInsets.only(top: 8.0, right: 10, left: 8),
                                child: MacosCheckbox(
                                  value: alredyAvailableAddressesIndices.contains(index) ? true : selectedAddressIndices.contains(index),
                                  onChanged: alredyAvailableAddressesIndices.contains(index) ? null : (value) => _onItemTapped(index),
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
                        onPressed: alredyAvailableAddressesIndices.length == widget.addresses.length
                            ? null
                            : () async {
                                await importAddresses(widget.addresses, context, dataBlocContext);
                              },
                        child: const Text('Import'),
                      ),
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

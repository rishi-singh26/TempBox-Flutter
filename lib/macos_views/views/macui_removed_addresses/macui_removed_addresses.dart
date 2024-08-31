import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macos_card.dart';
import 'package:tempbox/models/address_data.dart';

class MacUiRemovedAddresses extends StatefulWidget {
  const MacUiRemovedAddresses({super.key});

  @override
  State<MacUiRemovedAddresses> createState() => _MacUiRemovedAddressesState();
}

class _MacUiRemovedAddressesState extends State<MacUiRemovedAddresses> {
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
            if (dataState.removedAddresses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(children: [
                  Text('Removed Addresses', style: theme.typography.title1),
                  vGap(24),
                  const Text('No address available to restore'),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PushButton(
                      controlSize: ControlSize.regular,
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Done'),
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
                  Text('Removed Addresses', style: theme.typography.title1),
                  vGap(15),
                  SizedBox(
                    height: 250,
                    child: MacosCard(
                      isFirst: true,
                      isLast: true,
                      padding: EdgeInsets.zero,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: dataState.removedAddresses.length,
                        itemBuilder: (context, index) {
                          AddressData addressData = dataState.removedAddresses[index];
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
                        onPressed:
                            selectedAddressIndices.isEmpty ? null : () => _restoreAddresses(dataState.removedAddresses, context, dataBlocContext),
                        child: const Text('Restore'),
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

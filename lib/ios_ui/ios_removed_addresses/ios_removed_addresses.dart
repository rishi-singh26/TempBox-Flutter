import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';

class IosRemovedAddressesPage extends StatefulWidget {
  const IosRemovedAddressesPage({super.key});

  @override
  State<IosRemovedAddressesPage> createState() => _IosRemovedAddressesPageState();
}

class _IosRemovedAddressesPageState extends State<IosRemovedAddressesPage> {
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
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: MediaQuery.of(context).platformBrightness != Brightness.dark ? AppColors.navBarColor : null,
              largeTitle: const Text('Removed Addresses'),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: selectedAddressIndices.isEmpty ? null : () => _restoreAddresses(dataState.removedAddresses, context, dataBlocContext),
                child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              border: null,
            ),
            if (dataState.removedAddresses.isNotEmpty)
              SliverList.list(children: [
                CupertinoListSection.insetGrouped(
                  children: List.generate(dataState.removedAddresses.length, (index) {
                    AddressData address = dataState.removedAddresses[index];
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

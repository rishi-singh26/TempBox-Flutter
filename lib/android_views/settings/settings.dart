import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/android_views/removed_addresses/removed_addresses.dart';
import 'package:tempbox/android_views/settings/android_app_info.dart';
import 'package:tempbox/android_views/settings/export.dart';
import 'package:tempbox/android_views/settings/import.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/shared/components/padded_card.dart';
import 'package:tempbox/shared/constants.dart';

class AdnroidSettings extends StatelessWidget {
  const AdnroidSettings({super.key});

  _resetAppData(BuildContext context, BuildContext dataBlocContext) async {
    bool? choice = await AlertService.getConformation(context: context, title: 'Alert', content: AppConstatns.resetAppData);
    if (choice == true && context.mounted && dataBlocContext.mounted) {
      bool? rechoice = await AlertService.getConformation(context: context, title: 'Alert', content: 'Reset app data?');
      if (rechoice == true && dataBlocContext.mounted) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(const ResetStateEvent());
      }
    }
  }

  _openAppInfo(BuildContext context, BuildContext dataBlocContext) {
    OverlayService.showOverLay(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: true,
      builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const AndroidAppInfo()),
    );
  }

  _openRemovedAddresses(BuildContext context, BuildContext dataBlocContext) {
    OverlayService.showOverLay(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: true,
      builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const RemovedAddressesPage()),
    );
  }

  _openExportPage(BuildContext context, BuildContext dataBlocContext) {
    OverlayService.showOverLay(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: true,
      builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const ExportPage()),
    );
  }

  _openImportPage(BuildContext context, BuildContext dataBlocContext) async {
    List<AddressData>? addresses = await ExportImportAddress.importAddreses();
    if (addresses != null && addresses.isNotEmpty && context.mounted && dataBlocContext.mounted) {
      OverlayService.showOverLay(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        enableDrag: true,
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<DataBloc>(dataBlocContext),
          child: ImportPage(addresses: addresses),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = CupertinoTheme.of(context);
    // vGap(double size) => SizedBox(height: size);
    return BlocBuilder<DataBloc, DataState>(
      builder: (dataBlocContext, dataState) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Settings')),
              SliverList.list(
                children: [
                  PaddedCard(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Import Addresses'),
                          leading: const Icon(CupertinoIcons.square_arrow_down, size: 22),
                          onTap: () => _openImportPage(context, dataBlocContext),
                          trailing: const CupertinoListTileChevron(),
                        ),
                        ListTile(
                          title: const Text('Export Addresses'),
                          leading: const Icon(CupertinoIcons.square_arrow_up, size: 20),
                          onTap: () => _openExportPage(context, dataBlocContext),
                          trailing: const CupertinoListTileChevron(),
                        ),
                      ],
                    ),
                  ),
                  PaddedCard(
                    child: ListTile(
                      title: const Text('Archived Addresses'),
                      leading: const Icon(CupertinoIcons.archivebox, size: 20),
                      onTap: () => _openRemovedAddresses(context, dataBlocContext),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  ),
                  PaddedCard(
                    child: ListTile(
                      title: const Text('Reset App Data'),
                      leading: const Icon(FluentIcons.reset_device, size: 20),
                      onTap: () => _resetAppData(context, dataBlocContext),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  ),
                  PaddedCard(
                    child: ListTile(
                      title: const Text('About TempBox'),
                      leading: const Icon(CupertinoIcons.info_circle, size: 20),
                      onTap: () => _openAppInfo(context, dataBlocContext),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

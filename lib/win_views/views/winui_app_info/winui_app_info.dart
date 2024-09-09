import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoListTileChevron;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/shared/components/app_logo.dart';
import 'package:tempbox/shared/constants.dart';
import 'package:tempbox/win_views/views/winui_app_info/winui_license_page.dart';
import 'package:url_launcher/url_launcher.dart';

class WinUIAppInfo extends StatelessWidget {
  const WinUIAppInfo({super.key});

  _resetAppData(BuildContext context, BuildContext dataBlocContext) async {
    bool? choice = await AlertService.getConformation(
      context: context,
      title: 'Alert',
      content: AppConstatns.resetAppData,
    );
    if (choice == true && context.mounted && dataBlocContext.mounted) {
      bool? rechoice = await AlertService.getConformation(
        context: context,
        title: 'Alert',
        content: 'Reset app data?',
      );
      if (rechoice == true && dataBlocContext.mounted) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(const ResetStateEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // const Widget vGap = SizedBox(height: 20);
    hGap(double width) => SizedBox(width: width);
    // final theme = FluentTheme.of(context);

    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 600),
        title: Row(
          children: [
            const AppLogo(size: 50, borderRadius: BorderRadius.all(Radius.circular(5))),
            hGap(15),
            const Text('TempBox'),
          ],
        ),
        content: ListView(children: [
          const ListTile(leading: Icon(FluentIcons.verified_brand), title: Text('Version 1.2.2')),
          const ListTile(leading: Icon(FluentIcons.power_button), title: Text('Powered by Mail.tm')),
          ListTile(
            leading: const Icon(FluentIcons.assign_policy),
            title: const Text('Privacy Policy'),
            onPressed: () => launchUrl(Uri.parse('https://tempbox.rishisingh.in/privacy-policy.html')),
            trailing: const CupertinoListTileChevron(),
          ),
          ListTile(
            leading: const Icon(FluentIcons.service_activity),
            title: const Text('Terms of Service'),
            onPressed: () => launchUrl(Uri.parse('https://tempbox.rishisingh.in/terms-of-service.html')),
            trailing: const CupertinoListTileChevron(),
          ),
          ListTile(
            leading: const Icon(FluentIcons.open_source),
            title: const Text('Open Source Code'),
            onPressed: () => launchUrl(Uri.parse('https://github.com/rishi-singh26/TempBox-Flutter')),
            trailing: const CupertinoListTileChevron(),
          ),
          ListTile(
            leading: const Icon(FluentIcons.certificate),
            title: const Text('MIT License'),
            onPressed: () => launchUrl(Uri.parse('https://raw.githubusercontent.com/rishi-singh26/TempBox-Flutter/main/LICENSE')),
            trailing: const CupertinoListTileChevron(),
          ),
          ListTile(
            leading: const Icon(FluentIcons.library),
            title: const Text('Open Source Libraries'),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const WinUILibraryLicense()),
            ),
            trailing: const CupertinoListTileChevron(),
          ),
          ListTile(
            leading: const Icon(FluentIcons.reset_device),
            title: const Text('Reset App Data'),
            onPressed: () => _resetAppData(context, dataBlocContext),
            trailing: const CupertinoListTileChevron(),
          ),
        ]),
        actions: [FilledButton(onPressed: Navigator.of(context).pop, child: const Text('Done'))],
      );
    });
  }
}

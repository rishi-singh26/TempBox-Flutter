import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import 'package:flutter/cupertino.dart' show CupertinoListTileChevron;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/overlay_service.dart';
import 'package:tempbox/shared/components/app_logo.dart';
import 'package:tempbox/shared/components/padded_card.dart';
import 'package:tempbox/shared/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AndroidAppInfo extends StatelessWidget {
  const AndroidAppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = CupertinoTheme.of(context);
    vGap(double size) => SizedBox(height: size);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar.large(title: Text('TempBox')),
            SliverList.list(children: [
              const AppLogo(size: 70, borderRadius: BorderRadius.all(Radius.circular(5))),
              vGap(10),
              const PaddedCard(
                child: Column(
                  children: [
                    ListTile(title: Text('Version 1.2.2'), leading: Icon(FluentIcons.verified_brand)),
                    ListTile(title: Text('Powered by Mail.tm'), leading: Icon(FluentIcons.power_button)),
                  ],
                ),
              ),
              PaddedCard(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Privacy Policy'),
                      leading: const Icon(FluentIcons.assign_policy, size: 22),
                      onTap: () => launchUrl(Uri.parse('https://tempbox.rishisingh.in/privacy-policy.html')),
                      trailing: const CupertinoListTileChevron(),
                    ),
                    ListTile(
                      title: const Text('Terms of Service'),
                      leading: const Icon(FluentIcons.service_activity, size: 20),
                      onTap: () => launchUrl(Uri.parse('https://tempbox.rishisingh.in/terms-of-service.html')),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  ],
                ),
              ),
              PaddedCard(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Open Source Code'),
                      leading: const Icon(FluentIcons.open_source, size: 22),
                      onTap: () => launchUrl(Uri.parse('https://github.com/rishi-singh26/TempBox-Flutter')),
                      trailing: const CupertinoListTileChevron(),
                    ),
                    ListTile(
                      title: const Text('MIT License'),
                      leading: const Icon(FluentIcons.certificate, size: 20),
                      onTap: () => launchUrl(Uri.parse('https://raw.githubusercontent.com/rishi-singh26/TempBox-Flutter/main/LICENSE')),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  ],
                ),
              ),
              PaddedCard(
                child: ListTile(
                  title: const Text('Open Source Libraries'),
                  leading: const Icon(FluentIcons.library, size: 20),
                  onTap: () {
                    OverlayService.showOverLay(
                      context: context,
                      useSafeArea: true,
                      isScrollControlled: true,
                      clipBehavior: Clip.hardEdge,
                      enableDrag: true,
                      builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<DataBloc>(dataBlocContext),
                        child: const LicensePage(),
                      ),
                    );
                  },
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
            ]),
          ],
        ),
      );
    });
  }

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
}

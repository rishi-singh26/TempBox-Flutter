import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/app_info/library_license.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/shared/components/app_logo.dart';
import 'package:tempbox/shared/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class IosAppInfo extends StatelessWidget {
  const IosAppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = CupertinoTheme.of(context);
    vGap(double size) => SizedBox(height: size);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('TempBox'),
              backgroundColor: MediaQuery.of(context).platformBrightness != Brightness.dark ? AppColors.navBarColor : null,
              leading: const SizedBox.shrink(),
              border: null,
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: Navigator.of(context).pop,
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList.list(children: [
              vGap(10),
              const AppLogo(size: 70, borderRadius: BorderRadius.all(Radius.circular(5))),
              CupertinoListSection.insetGrouped(
                children: const [
                  CupertinoListTile(
                    title: Text('Version 1.2.2'),
                    leading: Icon(FluentIcons.verified_brand),
                  ),
                  CupertinoListTile(
                    title: Text('Powered by Mail.tm'),
                    leading: Icon(FluentIcons.power_button),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: const Text('Privacy Policy'),
                    leading: const Icon(FluentIcons.assign_policy, size: 22),
                    onTap: () => launchUrl(Uri.parse('https://tempbox.rishisingh.in/privacy-policy.html')),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: const Text('Terms of Service'),
                    leading: const Icon(FluentIcons.service_activity, size: 20),
                    onTap: () => launchUrl(Uri.parse('https://tempbox.rishisingh.in/terms-of-service.html')),
                    trailing: const CupertinoListTileChevron(),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: const Text('Open Source Code'),
                    leading: const Icon(FluentIcons.open_source, size: 22),
                    onTap: () => launchUrl(Uri.parse('https://github.com/rishi-singh26/TempBox-Flutter')),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: const Text('MIT License'),
                    leading: const Icon(FluentIcons.certificate, size: 20),
                    onTap: () => launchUrl(Uri.parse('https://raw.githubusercontent.com/rishi-singh26/TempBox-Flutter/main/LICENSE')),
                    trailing: const CupertinoListTileChevron(),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: const Text('Open Source Libraries'),
                    leading: const Icon(FluentIcons.library, size: 20),
                    onTap: () {
                      final nav = Navigator(
                        observers: [HeroController()],
                        onGenerateRoute: (settings) => CupertinoPageRoute(builder: ((_) => const LibraryLicense())),
                      );
                      showCupertinoModalSheet(context: context, builder: (context) => nav);
                    },
                    trailing: const CupertinoListTileChevron(),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: const Text('Reset App Data'),
                    leading: const Icon(FluentIcons.reset_device, size: 20),
                    onTap: () => _resetAppData(context, dataBlocContext),
                    trailing: const CupertinoListTileChevron(),
                  ),
                ],
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

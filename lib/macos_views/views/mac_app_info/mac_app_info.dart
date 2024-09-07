import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/views/mac_app_info/mac_license_page.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macos_card.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/shared/components/app_logo.dart';
import 'package:url_launcher/url_launcher.dart';

class MacAppInfo extends StatelessWidget {
  const MacAppInfo({super.key});

  _resetAppData(BuildContext context, BuildContext dataBlocContext) async {
    bool? choice = await AlertService.getConformation(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to reset app data, this will delete all addresses and you will loose access to all your emails!',
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
    vGap(double height) => SizedBox(height: height);
    hGap(double width) => SizedBox(width: width);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return LayoutBuilder(builder: (context, constraints) {
        return MacosSheet(
          insetPadding: EdgeInsets.symmetric(
            horizontal: (constraints.maxWidth - 600) / 2,
            vertical: (constraints.maxHeight - 430) / 2,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                vGap(24),
                Row(
                  children: [
                    const AppLogo(size: 50, borderRadius: BorderRadius.all(Radius.circular(5))),
                    hGap(15),
                    Text('TempBox', style: MacosTheme.of(context).typography.largeTitle),
                  ],
                ),
                vGap(20),
                SizedBox(
                  height: 270,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const CustomTile(isFirst: true, icon: FluentIcons.verified_brand, title: 'Version 1.2.2', showTrailing: false),
                      const CustomTile(isLast: true, icon: FluentIcons.power_button, title: 'Powered by Mail.tm', showTrailing: false),
                      vGap(20),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('https://tempbox.rishisingh.in/privacy-policy.html')),
                        child: const CustomTile(isFirst: true, icon: FluentIcons.assign_policy, title: 'Privacy Policy'),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('https://tempbox.rishisingh.in/terms-of-service.html')),
                        child: const CustomTile(isLast: true, icon: FluentIcons.service_activity, title: 'Terms of Service'),
                      ),
                      vGap(20),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('https://github.com/rishi-singh26/TempBox-Flutter')),
                        child: const CustomTile(isFirst: true, icon: FluentIcons.open_source, title: 'Open Source Code'),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('https://raw.githubusercontent.com/rishi-singh26/TempBox-Flutter/main/LICENSE')),
                        child: const CustomTile(isLast: true, icon: FluentIcons.certificate, title: 'MIT License'),
                      ),
                      vGap(20),
                      GestureDetector(
                        onTap: () => showMacosSheet(context: context, builder: (_) => const MacLibraryLicense()),
                        child: const CustomTile(isFirst: true, isLast: true, icon: FluentIcons.library, title: 'Open Source Libraries'),
                      ),
                      vGap(20),
                      GestureDetector(
                        onTap: () => _resetAppData(context, dataBlocContext),
                        child: const CustomTile(isFirst: true, isLast: true, icon: FluentIcons.reset_device, title: 'Reset App Data'),
                      ),
                    ],
                  ),
                ),
                vGap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PushButton(
                      controlSize: ControlSize.regular,
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Done'),
                    ),
                  ],
                ),
                vGap(20),
              ],
            ),
          ),
        );
      });
    });
  }
}

class CustomTile extends StatelessWidget {
  final bool showTrailing;
  final bool isFirst;
  final bool isLast;
  final String title;
  final IconData icon;
  const CustomTile({
    super.key,
    this.showTrailing = true,
    this.isFirst = false,
    this.isLast = false,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MacosCard(
      isFirst: isFirst,
      isLast: isLast,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 5),
              MacosIcon(icon),
              const SizedBox(width: 15),
              Text(title),
            ],
          ),
          if (showTrailing) const CupertinoListTileChevron(),
        ],
      ),
    );
  }
}

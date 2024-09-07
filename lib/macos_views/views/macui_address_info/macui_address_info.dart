import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macos_card.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';
import 'package:url_launcher/url_launcher.dart';

class MacuiAddressInfo extends StatefulWidget {
  final AddressData addressData;
  const MacuiAddressInfo({super.key, required this.addressData});

  @override
  State<MacuiAddressInfo> createState() => _MacuiAddressInfoState();
}

class _MacuiAddressInfoState extends State<MacuiAddressInfo> {
  bool showPassword = false;
  AddressData? verifiedAddressData;

  @override
  void initState() {
    verifiedAddressData = widget.addressData;
    try {
      final user = MailTm.getUser(widget.addressData.authenticatedUser.account.id);
      if (user != null) {
        verifiedAddressData = widget.addressData.copyWith(authenticatedUser: user);
      }
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    SizedBox hGap(double size) => SizedBox(width: size);
    SizedBox vGap(double size) => SizedBox(height: size);
    return LayoutBuilder(builder: (context, constraints) {
      return MacosSheet(
        insetPadding: EdgeInsets.symmetric(horizontal: (constraints.maxWidth - 600) / 2, vertical: (constraints.maxHeight - 400) / 2),
        child: Builder(builder: (context) {
          if (verifiedAddressData == null) {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(children: [
                Text('Address Detail', style: theme.typography.title1),
                vGap(24),
                const Text('No Address Selected'),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: PushButton(controlSize: ControlSize.regular, child: const Text('Done'), onPressed: () => Navigator.of(context).pop()),
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
                Text(UiService.getAccountName(verifiedAddressData!), style: theme.typography.title1),
                vGap(24),
                MacosCard(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 10),
                  isFirst: true,
                  child: Row(children: [
                    const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                    hGap(10),
                    BlankBadge(color: UiService.getStatusColor(verifiedAddressData!)),
                    hGap(10),
                    Text(UiService.getStatusText(verifiedAddressData!)),
                  ]),
                ),
                MacosCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                        hGap(10),
                        Text(verifiedAddressData!.authenticatedUser.account.address),
                      ]),
                      MacosIconButton(
                        onPressed: () => UiService.copyToClipboard(widget.addressData.authenticatedUser.account.address),
                        icon: const MacosIcon(CupertinoIcons.doc_on_doc),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => showPassword = !showPassword),
                  child: MacosCard(
                    isLast: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Text('Password:', style: TextStyle(fontWeight: FontWeight.bold)),
                          hGap(10),
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: showPassword ? 0 : 5, sigmaY: showPassword ? 0 : 5),
                            child: Text(widget.addressData.password.trim()),
                          ),
                        ]),
                        MacosIconButton(
                          onPressed: () => UiService.copyToClipboard(widget.addressData.password),
                          icon: const MacosIcon(CupertinoIcons.doc_on_doc),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: RichText(
                    text: TextSpan(
                      text: "If you wish to use this account on Web browser, You can copy the credentials to use on ",
                      style: theme.typography.callout,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'mail.tm',
                          style: theme.typography.callout.copyWith(color: theme.primaryColor),
                          recognizer: TapGestureRecognizer()..onTap = () async => await launchUrl(Uri.parse('https://mail.tm')),
                        ),
                        TextSpan(
                          style: theme.typography.callout,
                          text: ' official website. Please note, the password cannot be reset or changed.',
                        ),
                      ],
                    ),
                  ),
                ),
                vGap(24),
                MacosCard(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  isFirst: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quota Usage', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${UiService.getQuotaString(verifiedAddressData!.authenticatedUser.account.used, SizeUnit.mb)} / ${UiService.getQuotaString(verifiedAddressData!.authenticatedUser.account.quota, SizeUnit.mb)}',
                      )
                    ],
                  ),
                ),
                MacosCard(
                  padding: const EdgeInsets.only(left: 15, right: 15, bottom: 12),
                  isLast: true,
                  child: CapacityIndicator(
                      value: (verifiedAddressData!.authenticatedUser.account.used / verifiedAddressData!.authenticatedUser.account.quota) * 100),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    'Ones you reach your Quota limit, you can not receive any more messages. Deleting your previous messages will free up your used Quota.',
                    style: theme.typography.callout,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: PushButton(controlSize: ControlSize.regular, onPressed: Navigator.of(context).pop, child: const Text('Done')),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      );
    });
  }
}

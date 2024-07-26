import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';
import 'package:url_launcher/url_launcher.dart';

class IosAddressInfo extends StatefulWidget {
  final AddressData addressData;
  const IosAddressInfo({super.key, required this.addressData});

  @override
  State<IosAddressInfo> createState() => _IosAddressInfoState();
}

class _IosAddressInfoState extends State<IosAddressInfo> {
  bool showPassword = false;
  AddressData? verifiedAddressData;
  @override
  void initState() {
    verifiedAddressData = widget.addressData;
    if (!widget.addressData.archived) {
      try {
        final user = MailTm.getUser(widget.addressData.authenticatedUser.account.id);
        if (user != null) {
          verifiedAddressData = widget.addressData.copyWith(authenticatedUser: user);
        }
        setState(() {});
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    SizedBox hGap(double size) => SizedBox(width: size);
    Size screenSize = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(UiService.getAccountName(widget.addressData)),
            backgroundColor: MediaQuery.of(context).platformBrightness != Brightness.dark ? AppColors.navBarColor : null,
            leading: const SizedBox.shrink(),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: Navigator.of(context).pop,
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          if (verifiedAddressData != null)
            SliverList.list(children: [
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 3),
                dividerMargin: 2,
                hasLeading: false,
                children: [
                  CupertinoListTile.notched(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                        hGap(10),
                        BlankBadge(color: UiService.getStatusColor(verifiedAddressData!)),
                        hGap(10),
                        Text(UiService.getStatusText(verifiedAddressData!)),
                      ],
                    ),
                  ),
                  CupertinoListTile.notched(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                        hGap(10),
                        SizedBox(
                          width: screenSize.width - 205,
                          child: Text(verifiedAddressData!.authenticatedUser.account.address, maxLines: 2),
                        ),
                      ],
                    ),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => UiService.copyToClipboard(verifiedAddressData!.authenticatedUser.account.address),
                      child: const Icon(CupertinoIcons.doc_on_doc, size: 22),
                    ),
                  ),
                  CupertinoListTile.notched(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 5, 6, 5),
                    title: GestureDetector(
                      onTap: () => setState(() => showPassword = !showPassword),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Password:', style: TextStyle(fontWeight: FontWeight.bold)),
                          hGap(10),
                          SizedBox(
                            width: screenSize.width - 220,
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: showPassword ? 0 : 5, sigmaY: showPassword ? 0 : 5),
                              child: Text(widget.addressData.password.trim(), maxLines: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => UiService.copyToClipboard(widget.addressData.password),
                      child: const Icon(CupertinoIcons.doc_on_doc, size: 22),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: RichText(
                  text: TextSpan(
                    text: "If you wish to use this account on Web browser, You can copy the credentials to use on ",
                    style: theme.textTheme.tabLabelTextStyle.copyWith(fontSize: 13),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'mail.tm',
                        style: theme.textTheme.tabLabelTextStyle.copyWith(color: theme.primaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async => await launchUrl(
                                Uri.parse('https://mail.tm'),
                              ),
                      ),
                      TextSpan(
                        style: theme.textTheme.tabLabelTextStyle.copyWith(fontSize: 13),
                        text: ' official website. Please note, the password cannot be reset or changed.',
                      ),
                    ],
                  ),
                ),
              ),
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 3),
                dividerMargin: 2,
                hasLeading: false,
                children: [
                  CupertinoListTile.notched(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 7),
                    title: const Text('Quota usage', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '${UiService.getQuotaString(verifiedAddressData!.authenticatedUser.account.used, SizeUnit.kb)} / ${UiService.getQuotaString(verifiedAddressData!.authenticatedUser.account.quota, SizeUnit.mb)}',
                      style: theme.textTheme.tabLabelTextStyle.copyWith(fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 15),
                    child: LinearProgressIndicator(
                      value: verifiedAddressData!.authenticatedUser.account.used / verifiedAddressData!.authenticatedUser.account.quota,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: Text(
                  'Ones you reach your Quota limit, you can not receive any more messages. Deleting your previous messages will free up your used Quota.',
                  style: theme.textTheme.tabLabelTextStyle.copyWith(fontSize: 13),
                ),
              ),
            ]),
        ],
      ),
    );
  }
}

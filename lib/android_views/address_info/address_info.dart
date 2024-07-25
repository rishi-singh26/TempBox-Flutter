import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';
import 'package:tempbox/shared/components/padded_card.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressInfo extends StatefulWidget {
  final AddressData addressData;
  const AddressInfo({super.key, required this.addressData});

  @override
  State<AddressInfo> createState() => _AddressInfoState();
}

class _AddressInfoState extends State<AddressInfo> {
  bool showPassword = false;
  AddressData? verifiedAddressData;
  @override
  void initState() {
    verifiedAddressData = widget.addressData;
    if (widget.addressData.isActive) {
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
    final theme = Theme.of(context);
    SizedBox hGap(double size) => SizedBox(width: size);
    SizedBox vGap(double size) => SizedBox(height: size);
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(UiService.getAccountName(widget.addressData))),
          if (verifiedAddressData != null)
            SliverList.list(children: [
              PaddedCard(
                child: Column(children: [
                  ListTile(
                    // dense: true,
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                        hGap(10),
                        BlankBadge(color: UiService.getStatusColor(verifiedAddressData!, false)),
                        hGap(10),
                        Text(UiService.getStatusText(verifiedAddressData!)),
                      ],
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 15, right: 5),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                        hGap(10),
                        SizedBox(width: screenSize.width - 205, child: Text(verifiedAddressData!.authenticatedUser.account.address)),
                      ],
                    ),
                    // dense: true,
                    trailing: IconButton(
                      onPressed: () => UiService.copyToClipboard(verifiedAddressData!.authenticatedUser.account.address),
                      icon: Icon(Icons.copy_rounded, color: theme.buttonTheme.colorScheme?.primary ?? Colors.red),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 15, right: 5),
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
                              child: Text(widget.addressData.password.trim()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // dense: true,
                    visualDensity: VisualDensity.compact,
                    trailing: IconButton(
                      onPressed: () => UiService.copyToClipboard(widget.addressData.password),
                      icon: Icon(Icons.copy_rounded, color: theme.buttonTheme.colorScheme?.primary ?? Colors.red),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: RichText(
                  text: TextSpan(
                    text: "If you wish to use this account on Web browser, You can copy the credentials to use on ",
                    style: theme.textTheme.labelMedium,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'mail.tm',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.buttonTheme.colorScheme?.primary ?? Colors.red,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async => await launchUrl(
                                Uri.parse('https://mail.tm'),
                              ),
                      ),
                      TextSpan(
                        style: theme.textTheme.labelMedium,
                        text: ' official website. Please note, the password cannot be reset or changed.',
                      ),
                    ],
                  ),
                ),
              ),
              vGap(30),
              PaddedCard(
                child: Column(children: [
                  ListTile(
                    title: const Text('Quota usage', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '${UiService.getQuotaString(verifiedAddressData!.authenticatedUser.account.used, SizeUnit.kb)} / ${UiService.getQuotaString(verifiedAddressData!.authenticatedUser.account.quota, SizeUnit.mb)}',
                    ),
                    // dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: LinearProgressIndicator(
                        value: verifiedAddressData!.authenticatedUser.account.used / verifiedAddressData!.authenticatedUser.account.quota),
                  ),
                  vGap(10),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: Text(
                  'Ones you reach your Quota limit, you can not receive any more messages. Deleting your previous messages will free up your used Quota.',
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ]),
        ],
      ),
    );
  }
}

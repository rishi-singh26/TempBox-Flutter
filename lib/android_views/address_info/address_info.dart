import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';
import 'package:tempbox/shared/components/padded_card.dart';

class AddressInfo extends StatefulWidget {
  final AddressData addressData;
  const AddressInfo({super.key, required this.addressData});

  @override
  State<AddressInfo> createState() => _AddressInfoState();
}

class _AddressInfoState extends State<AddressInfo> {
  bool showPassword = false;
  AuthenticatedUser? authenticatedUser;
  @override
  void initState() {
    authenticatedUser = MailTm.getUser(widget.addressData.authenticatedUser.account.id);
    super.initState();
  }

  String _getStatusText(AuthenticatedUser authenticatedUser) {
    return authenticatedUser.account.isDeleted
        ? 'Deleted'
        : authenticatedUser.account.isDisabled
            ? 'Disabled'
            : 'Active';
  }

  Color _getStatusColor(AuthenticatedUser authenticatedUser) {
    return authenticatedUser.account.isDeleted
        ? Colors.red
        : authenticatedUser.account.isDisabled
            ? Colors.amber
            : Colors.green;
  }

  String _getQuotaStering(int bytes, SizeUnit unit) {
    return ByteConverterService.fromBytes(bytes.toDouble()).toHumanReadable(unit);
  }

  @override
  Widget build(BuildContext context) {
    SizedBox hGap(double size) => SizedBox(width: size);
    SizedBox vGap(double size) => SizedBox(height: size);
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(UiService.getAccountName(widget.addressData))),
          if (authenticatedUser != null)
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
                        BlankBadge(color: _getStatusColor(authenticatedUser!)),
                        hGap(10),
                        Text(_getStatusText(authenticatedUser!)),
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
                        SizedBox(width: screenSize.width - 205, child: Text(authenticatedUser!.account.address)),
                      ],
                    ),
                    // dense: true,
                    trailing: IconButton(
                      onPressed: () => UiService.copyToClipboard(authenticatedUser!.account.address),
                      icon: Icon(CupertinoIcons.doc_on_doc, color: Theme.of(context).buttonTheme.colorScheme?.primary ?? Colors.red),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 15, right: 5),
                    title: Row(
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
                    // dense: true,
                    visualDensity: VisualDensity.compact,
                    trailing: IconButton(
                      onPressed: () => UiService.copyToClipboard(widget.addressData.password),
                      icon: Icon(CupertinoIcons.doc_on_doc, color: Theme.of(context).buttonTheme.colorScheme?.primary ?? Colors.red),
                    ),
                    onTap: () => setState(() => showPassword = !showPassword),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: RichText(
                  text: TextSpan(
                    text: "If you wish to use this account on Web browser, You can copy the credentials to use on ",
                    style: Theme.of(context).textTheme.labelMedium,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'mail.tm',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).buttonTheme.colorScheme?.primary ?? Colors.red,
                            ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      TextSpan(
                        style: Theme.of(context).textTheme.labelMedium,
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
                        '${_getQuotaStering(authenticatedUser!.account.used, SizeUnit.kb)} / ${_getQuotaStering(authenticatedUser!.account.quota, SizeUnit.mb)}'),
                    // dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: LinearProgressIndicator(value: authenticatedUser!.account.used / authenticatedUser!.account.quota),
                  ),
                  vGap(10),
                ]),
              ),
            ]),
        ],
      ),
    );
  }
}

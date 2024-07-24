import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/byte_converter_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';
import 'package:tempbox/win_views/views/winui_address_info/fluent_card.dart';
import 'package:url_launcher/url_launcher.dart';

class WinuiAddressInfo extends StatefulWidget {
  final AddressData addressData;
  const WinuiAddressInfo({super.key, required this.addressData});

  @override
  State<WinuiAddressInfo> createState() => _WinuiAddressInfoState();
}

class _WinuiAddressInfoState extends State<WinuiAddressInfo> {
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

  String _getStatusText(AddressData addressData) {
    if (!addressData.isActive) {
      return 'Deleted';
    } else if (addressData.authenticatedUser.account.isDisabled) {
      return 'Disabled';
    } else {
      return 'Active';
    }
  }

  Color _getStatusColor(AddressData addressData) {
    if (!addressData.isActive) {
      return CupertinoColors.systemRed;
    } else if (addressData.authenticatedUser.account.isDisabled) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.systemGreen;
    }
  }

  String _getQuotaString(int bytes, SizeUnit unit) {
    return ByteConverterService.fromBytes(bytes.toDouble()).toHumanReadable(unit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    SizedBox hGap(double size) => SizedBox(width: size);
    SizedBox vGap(double size) => SizedBox(height: size);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      if (dataState.selectedAddress == null || verifiedAddressData == null) {
        return ContentDialog(
          constraints: const BoxConstraints(maxWidth: 600),
          title: const Text('Address Details'),
          content: const SingleChildScrollView(child: ListBody(children: [Text('No Address Selected')])),
          actions: [FilledButton(onPressed: Navigator.of(context).pop, child: const Text('Done'))],
        );
      }
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 600),
        title: Text(UiService.getAccountName(dataState.selectedAddress!)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              FluentCard(
                child: Column(
                  children: [
                    Row(children: [
                      const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                      hGap(10),
                      BlankBadge(color: _getStatusColor(verifiedAddressData!)),
                      hGap(10),
                      Text(_getStatusText(verifiedAddressData!)),
                    ]),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                            hGap(10),
                            Text(verifiedAddressData!.authenticatedUser.account.address),
                          ]),
                          IconButton(
                            icon: const Icon(CupertinoIcons.doc_on_doc),
                            onPressed: () => UiService.copyToClipboard(widget.addressData.authenticatedUser.account.address),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => showPassword = !showPassword),
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
                          IconButton(
                            icon: const Icon(CupertinoIcons.doc_on_doc),
                            onPressed: () => UiService.copyToClipboard(widget.addressData.password),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RichText(
                  text: TextSpan(
                    text: "If you wish to use this account on Web browser, You can copy the credentials to use on ",
                    style: theme.typography.caption,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'mail.tm',
                        style: theme.typography.caption?.copyWith(color: theme.selectionColor),
                        recognizer: TapGestureRecognizer()..onTap = () async => await launchUrl(Uri.parse('https://mail.tm')),
                      ),
                      TextSpan(
                        style: theme.typography.caption,
                        text: ' official website. Please note, the password cannot be reset or changed.',
                      ),
                    ],
                  ),
                ),
              ),
              vGap(20),
              FluentCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quota Usage', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${_getQuotaString(verifiedAddressData!.authenticatedUser.account.used, SizeUnit.mb)} / ${_getQuotaString(verifiedAddressData!.authenticatedUser.account.quota, SizeUnit.mb)}',
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ProgressBar(
                            value:
                                (verifiedAddressData!.authenticatedUser.account.used / verifiedAddressData!.authenticatedUser.account.quota) * 100),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  'Ones you reach your Quota limit, you can not receive any more messages. Deleting your previous messages will free up your used Quota.',
                  style: theme.typography.caption,
                ),
              ),
            ],
          ),
        ),
        actions: [FilledButton(onPressed: Navigator.of(context).pop, child: const Text('Done'))],
      );
    });
  }
}

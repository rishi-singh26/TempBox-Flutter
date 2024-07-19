import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/card_list_tile.dart';
import 'package:tempbox/shared/components/padded_card.dart';
import 'package:tempbox/shared/styles/textfield.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddAddress extends StatefulWidget {
  const AddAddress({super.key});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  bool showSpinner = false;
  Domain? selectedDomain;
  List<Domain> domainsList = [];
  double passwordBoxHeight = 60.0;

  late TextEditingController addressNameController;
  late TextEditingController addressController;
  late TextEditingController passwordController;

  @override
  void initState() {
    addressNameController = TextEditingController();
    addressController = TextEditingController();
    passwordController = TextEditingController();
    _getDomains();
    super.initState();
  }

  _updateRandomAddress() {
    addressController.text = UiService.generateRandomString(10);
  }

  _getDomains() async {
    domainsList = await MailTm.domains();
    selectedDomain = domainsList.firstOrNull;
    setState(() {});
  }

  _createAddress(BuildContext dataBlocContext) async {
    setState(() => showSpinner = true);
    try {
      final String password = passwordController.text.isNotEmpty && passwordBoxHeight != 0
          ? passwordController.text
          : UiService.generateRandomString(12, useNumbers: true, useSpecialCharacters: true, useUpperCase: true);
      AuthenticatedUser authenticatedUser = await MailTm.register(
        username: addressController.text.isNotEmpty ? addressController.text : UiService.generateRandomString(10),
        password: password,
        domain: selectedDomain,
      );

      if (dataBlocContext.mounted) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(
          AddAddressDataEvent(AddressData(
            addressName: addressNameController.text,
            authenticatedUser: authenticatedUser,
            isActive: true,
            password: password,
          )),
        );
        Navigator.canPop(dataBlocContext) ? Navigator.pop(dataBlocContext) : null;
      }
    } catch (e) {
      setState(() => showSpinner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizedBox vGap(double size) => SizedBox(height: size);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Add Address'),
              actions: [
                TextButton(
                  onPressed: () => _createAddress(dataBlocContext),
                  child: showSpinner
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(strokeWidth: 3),
                        )
                      : const Text('Done'),
                ),
              ],
            ),
            SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    readOnly: showSpinner,
                    controller: addressNameController,
                    decoration: TextFieldStyles.inputDecoration(context, 'Address name (Optional)'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text('Address name appears on the address list screen', style: Theme.of(context).textTheme.labelMedium),
                ),
                vGap(30),
                CardListTile(
                  isFirst: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                          child: TextField(
                            controller: addressController,
                            decoration: TextFieldStyles.inputDecoration(context, 'Address'),
                          ),
                        ),
                      ),
                      DropdownButton<Domain>(
                        value: selectedDomain,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        underline: Container(height: 0),
                        enableFeedback: true,
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        padding: const EdgeInsets.only(right: 10),
                        onChanged: (Domain? value) {
                          value != null ? setState(() => selectedDomain = value) : null;
                        },
                        items: domainsList.map<DropdownMenuItem<Domain>>((Domain value) {
                          return DropdownMenuItem<Domain>(
                            value: value,
                            child: Text(value.domain),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                CardListTile(
                  isLast: true,
                  child: ListTile(
                    title: RichText(
                      text: TextSpan(
                        text: 'Random address',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Theme.of(context).buttonTheme.colorScheme?.primary ?? Colors.green),
                        recognizer: TapGestureRecognizer()..onTap = showSpinner ? null : _updateRandomAddress,
                      ),
                    ),
                  ),
                ),
                vGap(30),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: passwordBoxHeight,
                  child: CardListTile(
                    isFirst: true,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                      child: TextField(
                        controller: passwordController,
                        decoration: TextFieldStyles.inputDecoration(context, 'Password'),
                      ),
                    ),
                  ),
                ),
                CardListTile(
                  isFirst: passwordBoxHeight == 0,
                  isLast: true,
                  child: SwitchListTile.adaptive(
                    value: passwordBoxHeight == 0,
                    onChanged: (v) {
                      v ? passwordBoxHeight = 0 : passwordBoxHeight = 60;
                      setState(() {});
                    },
                    title: const Text('Use random password'),
                  ),
                ),
                vGap(30),
                const PaddedCard(
                  color: Color(0x3CFFEE58),
                  child: ListTile(
                    leading: Icon(CupertinoIcons.info_circle_fill, color: Colors.yellow),
                    title: Text('The password ones set can not be reset or changed'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/regex.dart';
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
  bool useRandomAddress = false;
  bool useRandomPassword = true;
  int _selectedSegment = 0;

  late TextEditingController addressNameController;
  late TextEditingController addressController;
  late TextEditingController passwordController;

  late TextEditingController loginAddressController;
  late TextEditingController loginPasswordController;

  _updateState() => setState(() {});

  @override
  void initState() {
    addressNameController = TextEditingController();
    addressController = TextEditingController();
    passwordController = TextEditingController.fromValue(TextEditingValue(
      text: UiService.generateRandomString(12, useNumbers: true, useSpecialCharacters: true, useUpperCase: true),
    ));

    loginAddressController = TextEditingController();
    loginPasswordController = TextEditingController();

    addressController.addListener(_updateState);
    loginAddressController.addListener(_updateState);
    loginPasswordController.addListener(_updateState);

    _getDomains();
    super.initState();
  }

  @override
  void dispose() {
    addressController.removeListener(_updateState);
    loginAddressController.removeListener(_updateState);
    loginPasswordController.removeListener(_updateState);

    addressNameController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  _getDomains() async {
    try {
      domainsList = await MailTm.domains();
      selectedDomain = domainsList.firstOrNull;
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  bool _enableActionButton() {
    if (_selectedSegment == 0) {
      return addressController.text.isNotEmpty && passwordController.text.isNotEmpty && selectedDomain != null;
    } else {
      return loginAddressController.text.isNotEmpty &&
          RegxService.validateEmail(loginAddressController.text) &&
          loginPasswordController.text.isNotEmpty;
    }
  }

  _newAddress(BuildContext dataBlocContext) async {
    setState(() => showSpinner = true);
    try {
      String password = '';
      AuthenticatedUser? authenticatedUser;
      if (_selectedSegment == 0) {
        password = passwordController.text.isNotEmpty && !useRandomPassword
            ? passwordController.text
            : UiService.generateRandomString(12, useNumbers: true, useSpecialCharacters: true, useUpperCase: true);
        CreateAddressResponse addressResponse = await HttpService.createAddress(
          addressController.text.isNotEmpty ? addressController.text : UiService.generateRandomString(10),
          password,
          selectedDomain,
        );
        authenticatedUser = addressResponse.authenticatedUser;
        if (addressResponse.message != null && dataBlocContext.mounted) {
          AlertService.showSnackBar(dataBlocContext, 'Alert', addressResponse.message!);
          setState(() => showSpinner = false);
          return;
        }
      } else {
        password = loginPasswordController.text;
        authenticatedUser = await HttpService.login(loginAddressController.text, password);
      }

      if (authenticatedUser != null && dataBlocContext.mounted) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(
          AddAddressDataEvent(AddressData(
            addressName: addressNameController.text,
            authenticatedUser: authenticatedUser,
            password: password,
          )),
        );
        Navigator.canPop(dataBlocContext) ? Navigator.pop(dataBlocContext) : null;
      } else if (dataBlocContext.mounted) {
        await AlertService.showSnackBar(dataBlocContext, 'Invalid Credentials :', 'Please enter valid login credentials');
        setState(() => showSpinner = false);
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() => showSpinner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizedBox vGap(double size) => SizedBox(height: size);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Address'),
          actions: [
            TextButton(
              onPressed: _enableActionButton() ? () => _newAddress(dataBlocContext) : null,
              child: showSpinner
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedSegment,
                onValueChanged: (int? value) => setState(() {
                  if (value != null) _selectedSegment = value;
                }),
                children: const <int, Widget>{
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Create')),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Login')),
                },
              ),
            ),
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
            if (_selectedSegment == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            return DropdownMenuItem<Domain>(value: value, child: Text(value.domain));
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  CardListTile(
                    isLast: true,
                    child: SwitchListTile(
                      value: useRandomAddress,
                      onChanged: (v) => setState(() {
                        useRandomAddress = v;
                        addressController.text = v == false ? '' : UiService.generateRandomString(10);
                      }),
                      title: const Text('Use random address'),
                    ),
                  ),
                  vGap(30),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: useRandomPassword ? 0 : 60,
                    onEnd: () {
                      if (useRandomPassword == true) {
                        setState(() {
                          passwordController.text = UiService.generateRandomString(
                            12,
                            useNumbers: false,
                            useSpecialCharacters: true,
                            useUpperCase: true,
                          );
                        });
                      }
                    },
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
                    isFirst: useRandomPassword,
                    isLast: true,
                    child: SwitchListTile(
                      value: useRandomPassword,
                      onChanged: (v) => setState(() {
                        useRandomPassword = v;
                        if (v == false) {
                          passwordController.text = '';
                        }
                      }),
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
            if (_selectedSegment == 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      readOnly: showSpinner,
                      controller: loginAddressController,
                      decoration: TextFieldStyles.inputDecoration(context, 'Email'),
                    ),
                  ),
                  vGap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      readOnly: showSpinner,
                      controller: loginPasswordController,
                      decoration: TextFieldStyles.inputDecoration(context, 'Password'),
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

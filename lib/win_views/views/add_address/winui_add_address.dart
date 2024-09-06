import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/regex.dart';
import 'package:tempbox/services/ui_service.dart';

class WinuiAddAddress extends StatefulWidget {
  const WinuiAddAddress({super.key});

  @override
  State<WinuiAddAddress> createState() => _WinuiAddAddressState();
}

class _WinuiAddAddressState extends State<WinuiAddAddress> {
  bool showSpinner = false;
  Domain? selectedDomain;
  List<Domain> domainsList = [];
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

    addressController.addListener(_updateState);
    passwordController.addListener(_updateState);

    loginAddressController = TextEditingController();
    loginPasswordController = TextEditingController();

    loginAddressController.addListener(_updateState);
    loginPasswordController.addListener(_updateState);

    _getDomains();
    super.initState();
  }

  @override
  void dispose() {
    addressController.removeListener(_updateState);
    passwordController.removeListener(_updateState);
    loginAddressController.removeListener(_updateState);
    loginPasswordController.removeListener(_updateState);

    addressNameController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  _updateRandomAddress() {
    addressController.text = UiService.generateRandomString(10);
    setState(() {});
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
        authenticatedUser = await MailTm.register(
          username: addressController.text.isNotEmpty ? addressController.text : UiService.generateRandomString(10),
          password: password,
          domain: selectedDomain,
        );
      } else {
        password = loginPasswordController.text;
        authenticatedUser = await HttpService.login(loginAddressController.text, password);
      }

      if (authenticatedUser != null && dataBlocContext.mounted) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(
          AddAddressDataEvent(AddressData(
            addressName: addressNameController.text,
            authenticatedUser: authenticatedUser,
            archived: false,
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

  void onCancel(BuildContext context) async {
    Navigator.of(context).canPop() ? Navigator.of(context).pop() : null;
  }

  @override
  Widget build(BuildContext context) {
    const Widget vGap = SizedBox(height: 20);
    final theme = FluentTheme.of(context);

    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 600),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('New Address'),
            SizedBox(
              width: 200,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedSegment,
                onValueChanged: (int? value) => setState(() {
                  if (value != null) _selectedSegment = value;
                }),
                children: <int, Widget>{
                  0: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('Create', style: theme.typography.body)),
                  1: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('Login', style: theme.typography.body)),
                },
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: _selectedSegment == 0
              ? ListBody(
                  children: <Widget>[
                    const SizedBox(height: 25),
                    TextBox(
                      placeholder: 'Address name (Optional)',
                      expands: false,
                      controller: addressNameController,
                    ),
                    vGap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: TextBox(controller: addressController, placeholder: 'Address')),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('@')),
                        Expanded(
                          flex: 1,
                          child: ComboBox<Domain>(
                            value: selectedDomain,
                            items: domainsList.map<ComboBoxItem<Domain>>((d) {
                              return ComboBoxItem<Domain>(value: d, child: Text(d.domain));
                            }).toList(),
                            onChanged: (d) {
                              if (d != null) {
                                setState(() => selectedDomain = d);
                              }
                            },
                            placeholder: const Text('Domain'),
                          ),
                        ),
                      ],
                    ),
                    if (!useRandomPassword) vGap,
                    if (!useRandomPassword) TextBox(placeholder: 'Password', expands: false, controller: passwordController),
                    vGap,
                    Row(
                      children: [
                        Checkbox(
                          checked: useRandomPassword,
                          onChanged: (value) {
                            if (value == true) {
                              passwordController.text = UiService.generateRandomString(
                                12,
                                useNumbers: true,
                                useSpecialCharacters: true,
                                useUpperCase: true,
                              );
                            } else {
                              passwordController.text = '';
                            }
                            setState(() => useRandomPassword = value ?? false);
                          },
                        ),
                        const SizedBox(width: 5),
                        const Text('Generate random password')
                      ],
                    ),
                    vGap,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.info_solid, color: Colors.yellow),
                        const SizedBox(width: 5),
                        const Text('Password ones set can not be reset or changed.')
                      ],
                    ),
                  ],
                )
              : ListBody(
                  children: [
                    const SizedBox(height: 25),
                    TextBox(
                      placeholder: 'Address name (Optional)',
                      expands: false,
                      controller: addressNameController,
                    ),
                    vGap,
                    TextBox(controller: loginAddressController, placeholder: 'Email'),
                    vGap,
                    TextBox(placeholder: 'Password', expands: false, controller: loginPasswordController),
                  ],
                ),
        ),
        actions: [
          Button(
            onPressed: () => onCancel(context),
            child: const Text('Cancel'),
          ),
          if (_selectedSegment == 0)
            Button(
              onPressed: _updateRandomAddress,
              child: const Text('Random Address'),
            ),
          FilledButton(
            onPressed: _enableActionButton() ? () => _newAddress(dataBlocContext) : null,
            child: showSpinner
                ? const SizedBox(height: 15, width: 15, child: ProgressRing(strokeWidth: 2))
                : Text(_selectedSegment == 0 ? 'Create' : 'Login'),
          ),
        ],
      );
    });
  }
}

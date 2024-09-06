import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macos_card.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/http_service.dart';
import 'package:tempbox/services/regex.dart';
import 'package:tempbox/services/ui_service.dart';

class MacUIAddAddress extends StatefulWidget {
  const MacUIAddAddress({super.key});

  @override
  State<MacUIAddAddress> createState() => _MacUIAddAddressState();
}

class _MacUIAddAddressState extends State<MacUIAddAddress> {
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

  @override
  Widget build(BuildContext context) {
    vGap(double height) => SizedBox(height: height);
    final theme = MacosTheme.of(context);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return LayoutBuilder(builder: (context, constraints) {
        return MacosSheet(
          insetPadding: EdgeInsets.symmetric(
            horizontal: (constraints.maxWidth - 600) / 2,
            vertical: (constraints.maxHeight - 400) / 2,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                vGap(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Address', style: MacosTheme.of(context).typography.title1),
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
                vGap(20),
                if (_selectedSegment == 0)
                  MacosCard(
                    isFirst: true,
                    isLast: true,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        MacosTextField(
                          controller: addressNameController,
                          placeholder: 'Address name (Optional)',
                          autofocus: true,
                        ),
                        vGap(14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 1, child: MacosTextField(controller: addressController, placeholder: 'Address')),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('@')),
                            Expanded(
                              flex: 1,
                              child: MacosPopupButton<Domain>(
                                value: selectedDomain,
                                onChanged: (Domain? newValue) {
                                  setState(() => selectedDomain = newValue);
                                },
                                items: domainsList.map<MacosPopupMenuItem<Domain>>((Domain value) {
                                  return MacosPopupMenuItem<Domain>(
                                    value: value,
                                    child: Text(value.domain),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        vGap(useRandomPassword ? 0 : 14),
                        if (!useRandomPassword) MacosTextField(controller: passwordController, placeholder: 'Password'),
                        vGap(24),
                        Row(
                          children: [
                            const SizedBox(width: 5),
                            MacosCheckbox(
                              value: useRandomPassword,
                              onChanged: (value) {
                                if (value) {
                                  passwordController.text = UiService.generateRandomString(
                                    12,
                                    useNumbers: true,
                                    useSpecialCharacters: true,
                                    useUpperCase: true,
                                  );
                                } else {
                                  passwordController.text = '';
                                }
                                setState(() => useRandomPassword = value);
                              },
                            ),
                            const SizedBox(width: 5),
                            const Text('Generate random password')
                          ],
                        ),
                        vGap(24),
                        const Row(
                          children: [
                            SizedBox(width: 5),
                            MacosIcon(CupertinoIcons.info_circle_fill, color: MacosColors.appleYellow, size: 16),
                            SizedBox(width: 5),
                            Text('Password ones set can not be reset or changed.')
                          ],
                        ),
                      ],
                    ),
                  ),
                if (_selectedSegment == 1)
                  MacosCard(
                    isFirst: true,
                    isLast: true,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        MacosTextField(controller: addressNameController, placeholder: 'Address name (Optional)'),
                        vGap(14),
                        MacosTextField(controller: loginAddressController, placeholder: 'Email'),
                        vGap(14),
                        MacosTextField(controller: loginPasswordController, placeholder: 'Password'),
                      ],
                    ),
                  ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PushButton(
                      secondary: true,
                      controlSize: ControlSize.regular,
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_selectedSegment == 0)
                          PushButton(
                            secondary: true,
                            controlSize: ControlSize.regular,
                            onPressed: _updateRandomAddress,
                            child: const Text('Random address'),
                          ),
                        if (_selectedSegment == 0) const SizedBox(width: 10),
                        PushButton(
                          controlSize: ControlSize.regular,
                          onPressed: _enableActionButton() ? () => _newAddress(dataBlocContext) : null,
                          child: showSpinner ? const ProgressCircle(radius: 7.5) : Text(_selectedSegment == 0 ? 'Create' : 'Login'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      });
    });
  }
}

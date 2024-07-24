import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
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

  late TextEditingController addressNameController;
  late TextEditingController addressController;
  late TextEditingController passwordController;

  @override
  void initState() {
    addressNameController = TextEditingController();
    addressController = TextEditingController();
    passwordController = TextEditingController.fromValue(TextEditingValue(
      text: UiService.generateRandomString(12, useNumbers: true, useSpecialCharacters: true, useUpperCase: true),
    ));

    addressController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));

    _getDomains();
    super.initState();
  }

  @override
  void dispose() {
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

  _createAddress(BuildContext dataBlocContext) async {
    setState(() => showSpinner = true);
    try {
      final String password = passwordController.text.isNotEmpty && !useRandomPassword
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

    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 600),
        title: const Text('New Address'),
        content: SingleChildScrollView(
          child: ListBody(
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
          ),
        ),
        actions: [
          Button(
            onPressed: () => onCancel(context),
            child: const Text('Cancel'),
          ),
          Button(
            onPressed: _updateRandomAddress,
            child: const Text('Random Address'),
          ),
          FilledButton(
            onPressed: addressController.text.isNotEmpty && passwordController.text.isNotEmpty && selectedDomain != null
                ? () => _createAddress(dataBlocContext)
                : null,
            child: const Text('Create'),
          ),
        ],
      );
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
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
  bool useRandomPassword = false;

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

  @override
  Widget build(BuildContext context) {
    const vGap = SizedBox(height: 24);
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
                vGap,
                Text(
                  'New Address',
                  style: MacosTheme.of(context).typography.title1,
                ),
                vGap,
                MacosTextField(
                  controller: addressNameController,
                  placeholder: 'Address name (Optional)',
                  autofocus: true,
                ),
                vGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                SizedBox(height: useRandomPassword ? 0 : 15),
                if (!useRandomPassword) MacosTextField(controller: passwordController, placeholder: 'Password'),
                vGap,
                Row(
                  children: [
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
                vGap,
                const Row(
                  children: [
                    MacosIcon(CupertinoIcons.info_circle_fill, color: MacosColors.appleYellow, size: 16),
                    SizedBox(width: 5),
                    Text('Password ones set can not be reset or changed.')
                  ],
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
                        PushButton(
                          secondary: true,
                          controlSize: ControlSize.regular,
                          onPressed: _updateRandomAddress,
                          child: const Text('Random address'),
                        ),
                        const SizedBox(width: 10),
                        PushButton(
                          controlSize: ControlSize.regular,
                          onPressed:
                              addressController.text.isNotEmpty && passwordController.text.isNotEmpty ? () => _createAddress(dataBlocContext) : null,
                          child: showSpinner ? const ProgressCircle(radius: 7.5) : const Text('Create'),
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

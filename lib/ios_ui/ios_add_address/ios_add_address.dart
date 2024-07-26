import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/colors.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/ui_service.dart';

class IosAddAddress extends StatefulWidget {
  const IosAddAddress({super.key});

  @override
  State<IosAddAddress> createState() => _IosAddAddressState();
}

class _IosAddAddressState extends State<IosAddAddress> {
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
    _getDomains();
    super.initState();
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
            archived: false,
            password: password,
          )),
        );
        Navigator.canPop(dataBlocContext) ? Navigator.pop(dataBlocContext) : null;
      }
    } catch (e) {
      setState(() => showSpinner = false);
    }
  }

  _toggleRandomPass(bool value) {
    setState(() => useRandomPassword = value);
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
        return CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: MediaQuery.of(context).platformBrightness != Brightness.dark ? AppColors.navBarColor : null,
              largeTitle: const Text('Add Address'),
              stretch: true,
              border: null,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              trailing: CupertinoButton(
                onPressed: addressController.text.isNotEmpty && passwordController.text.isNotEmpty && selectedDomain != null
                    ? () => _createAddress(dataBlocContext)
                    : null,
                padding: EdgeInsets.zero,
                child: showSpinner
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CupertinoActivityIndicator(),
                      )
                    : const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList.list(
              children: [
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 5),
                  hasLeading: false,
                  children: [
                    CupertinoTextFormFieldRow(
                      controller: addressNameController,
                      placeholder: 'Account name (Optional)',
                      padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 1, 10, 6),
                  child: Text(
                    'Account name appears on the accounts list screen.',
                    style: theme.textTheme.tabLabelTextStyle.copyWith(fontSize: 13),
                  ),
                ),
                CupertinoListSection.insetGrouped(
                  hasLeading: false,
                  dividerMargin: 5,
                  children: [
                    CupertinoTextField.borderless(
                      controller: addressController,
                      padding: const EdgeInsetsDirectional.fromSTEB(17, 15, 17, 15),
                      placeholder: 'Address',
                      suffix: PullDownButton(
                        itemBuilder: (context) => List.generate(domainsList.length, (index) {
                          return PullDownMenuItem(
                            title: domainsList[index].domain,
                            onTap: () => setState(() => selectedDomain = domainsList[index]),
                          );
                        }),
                        buttonBuilder: (context, showMenu) => CupertinoButton(
                          onPressed: showMenu,
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              Text(selectedDomain?.domain ?? '', style: theme.textTheme.textStyle),
                              const SizedBox(width: 5),
                              Icon(
                                CupertinoIcons.chevron_up_chevron_down,
                                color: theme.textTheme.textStyle.color,
                                size: 16,
                              ),
                              const SizedBox(width: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(onPressed: _updateRandomAddress, child: const Text('Random address')),
                    )
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  hasLeading: false,
                  dividerMargin: 5,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: useRandomPassword ? 0 : null,
                      child: CupertinoTextFormFieldRow(
                        controller: passwordController,
                        placeholder: 'Password',
                        padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text('Use random password'),
                      child: CupertinoSwitch(value: useRandomPassword, onChanged: _toggleRandomPass),
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  children: const [
                    CupertinoListTile(
                      backgroundColor: Color.fromARGB(60, 255, 204, 0),
                      padding: EdgeInsetsDirectional.fromSTEB(14, 8, 14, 8),
                      title: Text('The password ones set can not be reset or changed', maxLines: 2),
                      leading: Icon(CupertinoIcons.info_circle_fill, color: CupertinoColors.systemYellow),
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      }),
    );
  }
}

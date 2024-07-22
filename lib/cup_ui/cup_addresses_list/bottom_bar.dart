import 'dart:ui';

import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/cup_ui/blurred_container.dart';
import 'package:tempbox/cup_ui/cup_add_address/cup_add_address.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        return BlurredContainer(
          size: const Size(double.infinity, 80),
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.add_circled_solid, size: 27),
                          SizedBox(width: 10),
                          Text('New Address', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    onPressed: () {
                      showCupertinoModalSheet(
                        context: context,
                        builder: (context) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const CupAddAddress()),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: RichText(
                      text: TextSpan(
                        text: "Powered by ",
                        style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(fontSize: 15),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'mail.tm',
                            style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                bool? choice = await AlertService.getConformation(
                                  context: context,
                                  title: 'Do you want to continue?',
                                  content: 'This will open mail.tm website.',
                                );
                                if (choice == true) {
                                  await launchUrl(Uri.parse('https://mail.tm'));
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10)
            ],
          ),
        );
      },
    );
  }
}

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
                  Navigator.of(context).push(
                    CupertinoModalPopupRoute(
                      builder: (context) => const CupAddAddress(),
                      barrierLabel: 'Dismiss add address sheet',
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: RichText(
                  text: TextSpan(
                    text: "Powered by ",
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
  }
}

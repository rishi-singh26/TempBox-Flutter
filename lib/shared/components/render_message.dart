import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RenderMessage extends StatelessWidget {
  final Message message;
  const RenderMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final html = message.html.isEmpty ? '<p>Loading...</p>' : message.html.join('');
    return HtmlWidget(
      renderMode: RenderMode.listView,
      html,
      onTapUrl: (url) async {
        bool? choice = await AlertService.getConformation<bool>(
          context: context,
          title: 'Do you want to open this URL?',
          content: url,
          secondaryBtnTxt: 'Copy',
          truncateContent: true,
        );
        if (choice == true) {
          await launchUrl(Uri.parse(url));
        } else if (choice == false) {
          UiService.copyToClipboard(url);
        }
        return true;
      },
      onTapImage: (p0) {},
      enableCaching: true,
      buildAsync: true,
    );
  }
}

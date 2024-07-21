import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RenderMessage extends StatefulWidget {
  final AuthenticatedUser user;
  final Message message;
  const RenderMessage({super.key, required this.user, required this.message});

  @override
  State<RenderMessage> createState() => _RenderMessageState();
}

class _RenderMessageState extends State<RenderMessage> {
  late Message messageData;
  String htmlData = '<p>Loading...</p>';

  @override
  void initState() {
    messageData = widget.message;
    fetchData(widget.user, widget.message);
    super.initState();
  }

  Future<void> fetchData(AuthenticatedUser user, Message message) async {
    final url = Uri.parse('https://api.mail.tm/messages/${message.id}');
    final client = HttpClient();

    try {
      final request = await client.getUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/ld+json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${user.token}');

      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final jsonData = json.decode(responseBody);
        messageData = Message.fromJson(jsonData);
        htmlData = messageData.html.join('');
        setState(() {});
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // print('Error: $e');
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      renderMode: RenderMode.listView,
      htmlData,
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

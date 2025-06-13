import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RenderMessage extends StatefulWidget {
  final MessageData message;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final VoidCallback? onPageFinished;
  final Function(String)? onPageStarted;
  final Function(WebResourceError)? onWebResourceError;

  const RenderMessage({
    super.key,
    required this.message,
    this.height,
    this.width,
    this.backgroundColor,
    this.onPageFinished,
    this.onPageStarted,
    this.onWebResourceError,
  });

  @override
  State<RenderMessage> createState() => _RenderMessageState();
}

class _RenderMessageState extends State<RenderMessage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor ?? Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            if (widget.onPageStarted != null) {
              widget.onPageStarted!(url);
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            if (widget.onPageFinished != null) {
              widget.onPageFinished!();
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            if (widget.onWebResourceError != null) {
              widget.onWebResourceError!(error);
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            // You can control navigation here
            // For HTML content, we typically want to allow all navigation
            bool? choice = await AlertService.getConformation<bool>(
              context: context,
              title: 'Do you want to open this URL?',
              content: request.url,
              secondaryBtnTxt: 'Copy',
              truncateContent: true,
              dismissable: true,
            );
            if (choice == true) {
              await launchUrl(Uri.parse(request.url));
            } else if (choice == false) {
              UiService.copyToClipboard(request.url);
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    _loadHtmlContent();
  }

  void _loadHtmlContent() {
    bool isMobile = Platform.isAndroid;
    // Create a complete HTML document with proper structure
    String headerHTML =
        "<div style='display: flex; ${isMobile ? 'margin-left: 10px;' : ''} margin-bottom: 10px;'><div style='display: flex; width: 40px; height: 40px; border-radius: 20px; background-color: #007AFF; align-items: center; justify-content: center; color: white; font-weight: bold;'>${UiService.getMessageFromName(widget.message).substring(0, 1)}</div><div style='margin-left: 10px;'><div style='font-weight: bold;'>${UiService.getMessageFromName(widget.message)}</div><a href='mailto:${widget.message.from['address'] ?? ''}'>${widget.message.from['address'] ?? ''}</a></div></div><div style='display: flex; flex-direction: row; justify-content: flex-end; align-items: center; color: #8f8f8f; font-size: 16px; padding: 5px 15px;'>${UiService.formatTimeTo12Hour(widget.message.createdAt)}</div>";
    final String completeHtml =
        '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            margin: 0;
            padding: 16px;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.5;
        }
        img {
            max-width: 100%;
            height: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
    </style>
</head>
<body>
    $headerHTML
    ${widget.message.html.isEmpty ? 'No Data Available' : widget.message.html.join('')}
</body>
</html>
    ''';

    _controller.loadHtmlString(completeHtml);
  }

  @override
  void didUpdateWidget(RenderMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id) {
      setState(() {
        _isLoading = true;
      });
      _loadHtmlContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

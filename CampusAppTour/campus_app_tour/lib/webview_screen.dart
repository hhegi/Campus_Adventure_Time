import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewScreen extends StatelessWidget {
  const WebviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    InAppWebViewController? inAppWebViewController;
    final GlobalKey webviewKey = GlobalKey();
    return InAppWebView(
      onWebViewCreated: (controller) {
        inAppWebViewController = controller;
      },
      key: webviewKey,
      initialUrlRequest:
          URLRequest(url: Uri.parse("http://172.20.10.6:3000/")),
    );
  }
}

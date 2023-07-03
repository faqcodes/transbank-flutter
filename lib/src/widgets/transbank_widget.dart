import 'package:flutter/material.dart';
import 'package:transbank/src/widgets/handler_enum.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/constants.dart' as constants;
import 'navigation.dart';

class TransbankWidgetView extends StatefulWidget {
  const TransbankWidgetView({super.key, this.handlers});

  final Map<TransbankWidgetEventHandler, Function>? handlers;

  @override
  State<TransbankWidgetView> createState() => _TransbankWidgetView();
}

class _TransbankWidgetView extends State<TransbankWidgetView> {
  late final WebViewController controller;

  @override
  void initState() {
    debugPrint('TransbankWidgetView: initState');

    final transbankWidgetUri = Uri.https(
        constants.TRANSBANK_WEBVIEW_HOST, constants.TRANSBANK_WEBVIEW_PATH);

    controller = WebViewController()
      ..loadRequest(transbankWidgetUri)
      ..setNavigationDelegate(NavigationEvent.handler(widget.handlers))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    super.initState();
  }

  @override
  void dispose() {
    debugPrint('TransbankWidgetView: dispose');

    controller.loadRequest(Uri.parse('about:blank'));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
    );
  }
}

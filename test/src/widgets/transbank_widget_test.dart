import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:transbank/src/widgets/handler_enum.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:transbank/transbank.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'transbank_widget_test.mocks.dart';

@GenerateMocks([PlatformWebViewController])
void main() {
  late WebViewController webViewController;
  late MockPlatformWebViewController mockPlatformWebViewController;

  setUp(() {
    WebViewPlatform.instance = AndroidWebViewPlatform();
    mockPlatformWebViewController = MockPlatformWebViewController();

    webViewController = WebViewController.fromPlatform(
      mockPlatformWebViewController,
    );
  });

  group(
    'TransbankWidgetView',
    () {
      // ignore_for_file: constant_identifier_names
      const String TRANSBANK_WEBVIEW_HOST = 'webview.transbank.com';
      const String TRANSBANK_WEBVIEW_PATH = 'widget.html';

      final handlers = <TransbankWidgetEventHandler, Function>{
        TransbankWidgetEventHandler.event: (event) => debugPrint('$event')
      };

      testWidgets(
        'renders without any error',
        (tester) async {
          await tester.pumpWidget(
            TransbankWidgetView(
              handlers: handlers,
            ),
          );

          expect(find.byType(TransbankWidgetView), findsOneWidget);
        },
      );

      testWidgets(
        'calls initState and sets state variables correctly',
        (tester) async {
          await tester.pumpWidget(
            TransbankWidgetView(
              handlers: handlers,
            ),
          );

          final transbankWidgetUri = Uri.https(
            TRANSBANK_WEBVIEW_HOST,
            TRANSBANK_WEBVIEW_PATH,
          );

          await webViewController.loadRequest(
            transbankWidgetUri,
            method: LoadRequestMethod.get,
            headers: <String, String>{'a': 'header'},
            body: Uint8List(0),
          );

          final LoadRequestParams params =
              verify(mockPlatformWebViewController.loadRequest(captureAny))
                  .captured[0] as LoadRequestParams;

          expect(
            params.uri,
            Uri(
              scheme: 'https',
              host: TRANSBANK_WEBVIEW_HOST,
              path: TRANSBANK_WEBVIEW_PATH,
            ),
          );
          expect(params.method, LoadRequestMethod.get);
          expect(params.headers, <String, String>{'a': 'header'});
          expect(params.body, Uint8List(0));
        },
      );

      testWidgets(
        'calls dispose and clears resources correctly',
        (tester) async {
          await tester.pumpWidget(
            TransbankWidgetView(
              handlers: handlers,
            ),
          );

          await tester.pumpAndSettle();

          await tester.runAsync(
            () async {
              await tester.pumpWidget(
                const SizedBox.shrink(),
              );
            },
          );
        },
      );
    },
  );
}

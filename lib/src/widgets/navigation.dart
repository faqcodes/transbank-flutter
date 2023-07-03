import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'handler_enum.dart';

class NavigationEvent {
  static NavigationDelegate handler(
    Map<TransbankWidgetEventHandler, Function>? eventHandlers,
  ) =>
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          assert(eventHandlers != null);

          final uri = Uri.tryParse(request.url);

          if (uri == null || uri.isScheme('intent')) {
            debugPrint('onNavigationRequest: invalid schema or null');
            return NavigationDecision.prevent;
          }

          if (uri.isScheme('widget')) {
            debugPrint('onNavigationRequest: on widget schema');

            final host = TransbankWidgetEventHandler.values.byName(uri.host);

            final event =
                uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';

            debugPrint(
                'onNavigationRequest: call widget event: ${uri.host}/$event');
            eventHandlers?[host]?.call(event);

            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
        onWebResourceError: (WebResourceError error) {
          eventHandlers?[TransbankWidgetEventHandler.error]?.call(error);
        },
      );
}

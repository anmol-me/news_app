import 'package:flutter_web_plugins/flutter_web_plugins.dart'
    show setUrlStrategy, PathUrlStrategy;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

void configureUrl() {
  setUrlStrategy(PathUrlStrategy());
  WebViewPlatform.instance = WebWebViewPlatform();
}

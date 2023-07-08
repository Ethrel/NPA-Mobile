import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'preferences.dart';

class NPAWebView {
  late final WebViewController _controller;
  late final Preferences prefs;

  WebViewController get controller => _controller;

  late final String _npaJS;
  late final String _npaCSS;

  NPAWebView() {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            debugPrint('Page finished loading: $url');
            if (url.contains("/game/")) {
              debugPrint('Injecting intel!');
              _injectCSS(_npaCSS);
              await _injectJS(_npaJS);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url.startsWith('https://np.ironhelmet.com')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
            prefs.lastVisitedURI = change.url;
          },
        ),
      );

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
    _prepareAsyncController();
  }
  Future _prepareAsyncController() async {
    prefs = await Preferences.getInstance();

    String baseURI = prefs.npaInjectURI;
    List<String> assets = await Future.wait([
      _fetchWebAsset(Uri.parse("${baseURI}intel.js")),
      rootBundle.loadString('lib/npam_inject.js'),
      _fetchWebAsset(Uri.parse("${baseURI}intel.css")),
    ]);

    _npaJS = assets[0] + assets[1];
    _npaCSS = assets[2];

    _controller.loadRequest(Uri.parse(prefs.lastVisitedURI));
  }

  Future<String> _fetchWebAsset(Uri uri) async {
    http.Response res = await http.get(uri);
    return res.body;
  }

  Future<void> _injectJS(String js) async {
    await controller.runJavaScript(js);
  }

  void _injectCSS(String css) {
    var bytes = utf8.encode(css);
    var base64Str = base64.encode(bytes);
    _controller.runJavaScript("""
      (function() {
      var parent = document.getElementsByTagName('head').item(0);
      var style = document.createElement('style');
      style.type = 'text/css';
      // Tell the browser to BASE64-decode the string into your script !!!
      style.innerHTML = window.atob('$base64Str');
      parent.appendChild(style)
      })();
    """);
  }
}

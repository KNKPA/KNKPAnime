import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:logger/logger.dart';

class Webview {
  static Future<String?> getVideoResourceUrl(String pageUrl) async {
/*
 * So, in this method, we basically get video resources in 2 ways:
 * 1. Use user script to check whether there's a video element in the html,
 * and get its src attribute. However, this method cannot obtain video resource
 * when the src is in the blob form.
 * 2. Listen to network requests. However, due to iframe cross-domain restraints,
 * we cannot intercept requests made in iframes, and that's how a lot of websites
 * do to their players. Therefore we see the whole document as a tree and traverse
 * it by setting href (directly fetch the urls may cause authentication issues, such
 * as referers or cookies).
 */
    String? videoResourceUrl;
    final completer = Completer();
    _Node currentNode = _Node(WebUri(pageUrl));
    List<String> history = [];
    Future.delayed(
        const Duration(seconds: 60), () => completer.complete(false));
    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(pageUrl)),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(source: """
                setInterval(() => {
                  if (document.querySelector('video') !== null && document.querySelector('video').attributes.src.textContent.startsWith('http')) {
                    console.log(`VIDEO:\${document.querySelector('video').attributes.src.textContent}`);
                    // window.flutter_inappwebview.callHandler('foundVideoSrc', document.querySelector('video').attributes.src.textContent);
                  }
                }, 100);
                """, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START)
      ]),
      onLoadStart: (controller, url) {
        Modular.get<Logger>().i('Loading $url');
        history.add(_removeQuery(url));
      },
      onConsoleMessage: (controller, consoleMessage) {
        // Receive message from iframes
        // We cannot use controller.addJavaScriptHandler here because
        // window.flutter_inappwebview doesn't exist in cross-domain iframes
        // Therefore we use onConsoleMessage to pass information,
        // which is based on devtools API.
        String message = jsonDecode(consoleMessage.message);
        if (message.startsWith('VIDEO:')) {
          Modular.get<Logger>().i('Received console message: $consoleMessage');
          videoResourceUrl = message.substring('VIDEO:'.length);
          completer.complete(true);
        }
      },
      onWebViewCreated: (controller) {
        controller.addDevToolsProtocolEventListener(
            eventName: 'responseReceived',
            callback: (resp) {
              Modular.get<Logger>().i('Received resp: $resp');
              return resp;
            });
      },
      onLoadResource: (controller, resource) {
        if (resource.url.toString().contains('.m3u8') ||
            //resource.url.toString().contains('.mp4') ||
            (resource.initiatorType?.contains('video') ?? false)) {
          videoResourceUrl = resource.url.toString();
          completer.complete(true);
        } else if (resource.initiatorType?.contains('iframe') ?? false) {
          // For Windows webviews (and maybe macOS as well), onLoadResource
          // can't capture requests sent within iframes. Therefore we store
          // and them for later use.
          currentNode.children.add(_Node(resource.url!, parent: currentNode));
        }
      },
      onLoadStop: (controller, url) async {
        if (completer.isCompleted) return;
        // Sometimes resource loading requests are still being made after
        // onLoadStop. Therefore we delay a little bit here to make sure
        // we won't miss any (or at least won't miss a lot) requests
        await Future.delayed(const Duration(seconds: 2));
        while (!currentNode.isRoot &&
            currentNode.children.reversed
                .where((node) => !history.contains(_removeQuery(node.url)))
                .isEmpty) {
          await controller.evaluateJavascript(
              source: "window.location.href='${currentNode.parent!.url}';");
          currentNode = currentNode.parent!;
        }
        if (currentNode.children.reversed
            .where((node) => !history.contains(_removeQuery(node.url)))
            .isNotEmpty) {
          final node = currentNode.children.reversed
              .where((node) => !history.contains(_removeQuery(node.url)))
              .first;
          currentNode = node;
          await controller.evaluateJavascript(
              source: "window.location.href='${node.url}';");
        } else {
          // Root & no other subframes to go
          completer.complete(false);
        }
      },
      shouldAllowDeprecatedTLS: (controller, challenge) async =>
          ShouldAllowDeprecatedTLSAction.ALLOW,
    );
    webview.run();
    final gotVideo = await completer.future;
    webview.dispose();
    if (gotVideo) {
      Modular.get<Logger>().i('Got video resource: $videoResourceUrl');
      return videoResourceUrl;
    }
    Modular.get<Logger>().i('Cannot find any video in $pageUrl');
    return null;
  }

  static String _removeQuery(WebUri? url) {
    return url!.origin + url.path;
  }
}

class _Node {
  final WebUri url;
  final _Node? parent;
  final List<_Node> children = [];
  bool get isRoot => parent == null;

  _Node(this.url, {this.parent});
}

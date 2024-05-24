import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:logger/logger.dart';

class Webview {
  static Future<String?> getVideoResourceUrl(String pageUrl) async {
    String? videoResourceUrl;
    final completer = Completer();
    _Node currentNode = _Node(pageUrl);
    List<String> history = [];
    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(pageUrl)),
      onLoadStart: (controller, url) {
        Modular.get<Logger>().i('Loading $url');
        history.add(url.toString());
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
          currentNode.children
              .add(_Node(resource.url.toString(), parent: currentNode));
        }
      },
      onLoadStop: (controller, url) async {
        if (completer.isCompleted) return;
        // This timer seems redundant, however I do have seen some onLoadResource
        // calls after onLoadStop. So we use a timer here to ensure maxium compatibility

        while (!currentNode.isRoot &&
            currentNode.children
                .where((node) => !history.contains(node.url))
                .isEmpty) {
          await controller.evaluateJavascript(
              source: "window.location.href='${currentNode.parent!.url}';");
          currentNode = currentNode.parent!;
        }
        if (currentNode.children
            .where((node) => !history.contains(node.url))
            .isNotEmpty) {
          final node = currentNode.children
              .where((node) => !history.contains(node.url))
              .first;
          currentNode = node;
          await controller.evaluateJavascript(
              source: "window.location.href='${node.url}';");
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
}

class _Node {
  final String url;
  final _Node? parent;
  final List<_Node> children = [];
  bool get isRoot => parent == null;

  _Node(this.url, {this.parent});
}

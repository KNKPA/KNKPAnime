import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:logger/logger.dart';

class Webview {
  static Future<String?> getVideoResourceUrl(String pageUrl) async {
    String? videoResourceUrl;
    final completer = Completer();
    List<String> iframes = [];
    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(pageUrl)),
      onLoadStart: (controller, url) => iframes.clear(),
      onLoadResource: (controller, resource) {
        if (resource.url.toString().contains('.m3u8') ||
            resource.url.toString().contains('.mp4') ||
            (resource.initiatorType?.contains('video') ?? false)) {
          videoResourceUrl = resource.url.toString();
          completer.complete(true);
        } else if (resource.initiatorType?.contains('iframe') ?? false) {
          // For Windows webviews (and maybe macOS as well), onLoadResource
          // can't capture requests sent within iframes. Therefore we store
          // and them for later use.
          iframes.add(resource.url.toString());
        }
      },
      onLoadStop: (controller, url) async {
        if (completer.isCompleted) return;
        if (iframes.isNotEmpty) {
          // I don't know why but delaying for 1 sec can solve 403 forbidden problems...
          // Maybe some cookies or other things aren't set at this moment
          // TODO: request all the iframes
          Future.delayed(
              const Duration(seconds: 1),
              () => controller.evaluateJavascript(
                  source: "window.location.href='${iframes.first}';"));
        } else {
          // No more iframes to request and didn't get video resource either
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
}

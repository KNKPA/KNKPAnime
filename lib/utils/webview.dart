import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:logger/logger.dart';

class Webview {
  static Future<String?> getVideoResourceUrl(String pageUrl) async {
    String? videoResourceUrl;
    final completer = Completer();
    List<String> iframeUrls = [];
    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(pageUrl)),
      onLoadResource: (controller, resource) {
        if (resource.url.toString().contains('.m3u8') ||
            resource.url.toString().contains('.mp4') ||
            (resource.initiatorType?.contains('video') ?? false)) {
          videoResourceUrl = resource.url.toString();
          completer.complete(true);
        } else if (resource.initiatorType?.contains('iframe') ?? false) {
          // For Windows webviews (and maybe macOS as well), onLoadResource
          // can't capture requests sent within iframes. Therefore we add them to a list
          // and load them explicitly using another webview.
          iframeUrls.add(resource.url.toString());
        }
      },
      onLoadStop: (controller, url) async {
        completer.isCompleted ? null : completer.complete(false);
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
    } else if (iframeUrls.isNotEmpty) {
      Modular.get<Logger>().i(
          'Failed to get video url in $pageUrl, recursively requesting its iframes');
      final futures = iframeUrls.map((url) => getVideoResourceUrl(url));
      final results = await Future.wait(futures);
      return results.firstWhere((url) => url?.isNotEmpty ?? false);
    }
    Modular.get<Logger>().i('Cannot find any video or iframe in $pageUrl');
    return null;
  }
}

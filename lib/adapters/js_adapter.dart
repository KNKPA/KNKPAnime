import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/source.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class JSAdapter extends AdapterBase {
  late final jsEngine = getJavascriptRuntime();
  late final jsSource;
  final completer = Completer<bool>();
  bool initialized = false;
  late final logger = Modular.get<Logger>();
  final String sourceUrl;

  @override
  Future<List<Source>> getSources(String seriesId) async {
    await initializedOrThrow();
    final promise =
        jsEngine.evaluate("$jsSource\nadapter.getSources('$seriesId');");
    jsEngine.executePendingJob();
    final result = await jsEngine.handlePromise(promise);
    final ret = (jsonDecode(result.stringResult) as List)
        .map((sourceJson) => Source.fromDynamicJson(sourceJson))
        .toList();
    return ret;
  }

  @override
  Future<void> play(String episodeId, VideoController controller) async {
    // For webview adapters, the js function `getVideoResource` should return
    // the url of the play page.
    // Otherwise, it should return the media resource's url.
    await initializedOrThrow();
    final promise =
        jsEngine.evaluate("$jsSource\nadapter.getVideoResource('$episodeId');");
    jsEngine.executePendingJob();
    final result = await jsEngine.handlePromise(promise);
    if (useWebview) {
      controller.player
          .open(Media(await _getVideoResourceWithWebview(result.stringResult)));
    } else {
      controller.player.open(Media(result.stringResult));
    }
  }

  @override
  Future<List<Series>> search(String bangumiName, String searchKeyword) async {
    await initializedOrThrow();
    status = SearchStatus.pending;
    List<Series> ret = [];
    try {
      if (bangumiName.isNotEmpty) {
        final promise =
            jsEngine.evaluate("$jsSource\nadapter.search('$bangumiName');");
        jsEngine.executePendingJob();
        final result = await jsEngine.handlePromise(promise);
        ret.addAll((jsonDecode(result.stringResult) as List)
            .map((json) => Series.fromDynamicJson(json)));
      }
      if (searchKeyword.isNotEmpty) {
        final promise =
            jsEngine.evaluate("$jsSource\nadapter.search('$searchKeyword');");
        jsEngine.executePendingJob();
        final result = await jsEngine.handlePromise(promise);
        ret.addAll((jsonDecode(result.stringResult) as List)
            .map((json) => Series.fromDynamicJson(json)));
      }
    } catch (e) {
      logger.w(e);
      rethrow;
    } finally {
      status = SearchStatus.failed;
    }
    status = SearchStatus.success;
    logger.i('$name adapter returns ${ret.length} results');

    return ret;
  }

  Future<String> _getVideoResourceWithWebview(String url) async {
    String? videoLink;
    Completer gotVideoLink = Completer<bool>();
    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      onLoadResource: (controller, resource) {
        if (resource.url.toString().contains('.m3u8') ||
            resource.url.toString().contains('.mp4') ||
            (resource.initiatorType?.contains('video') ?? false)) {
          videoLink = resource.url.toString();
          gotVideoLink.complete(true);
        }
      },
      shouldAllowDeprecatedTLS: (controller, challenge) async =>
          ShouldAllowDeprecatedTLSAction.ALLOW,
    );
    webview.run();
    Future.delayed(const Duration(seconds: 30)).then((value) =>
        gotVideoLink.isCompleted ? null : gotVideoLink.complete(false));
    await gotVideoLink.future;
    webview.dispose();
    return videoLink!;
  }

  JSAdapter(this.sourceUrl) : super('') {
    init();
  }

  void init() async {
    try {
      await Dio()
          .get(sourceUrl)
          .then((resp) => jsSource = resp.data.toString());
      jsEngine.enableHandlePromises();
      await jsEngine.enableFetch();
      final configJson = jsEngine.evaluate("$jsSource\nadapter.getConfig();");
      final config = jsonDecode(configJson.stringResult);
      name = config['name']!;
      description = config['description'];
      useWebview = config['useWebview'] ?? false;
      completer.complete(true);
      initialized = true;
    } catch (e) {
      logger.w(e);
      completer.complete(false);
    }
  }

  Future initializedOrThrow() async {
    await completer.future;
    if (!initialized) throw ('该视频源初始化失败');
  }
}

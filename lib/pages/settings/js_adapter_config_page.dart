import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/search/adapter_search_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

class JsAdapterConfigPage extends StatefulWidget {
  const JsAdapterConfigPage({super.key});

  @override
  State<JsAdapterConfigPage> createState() => _JsAdapterConfigPageState();
}

class _JsAdapterConfigPageState extends State<JsAdapterConfigPage> {
  late final adapterSearchController = Modular.get<AdapterSearchController>();
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理JavaScript适配器'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Modular.to.pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                labelText: '添加适配器URL',
              ),
              onSubmitted: (url) {
                adapterSearchController.addJsAdapter(url);
                textEditingController.clear();
              },
            ),
          ),
          Expanded(
            child: Observer(
              builder: (context) => ListView(
                children: adapterSearchController.jsAdapters
                    .map((adapter) => ListTile(
                          title: Text(adapter.name),
                          subtitle: Text('适配器地址：${adapter.sourceUrl}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              adapterSearchController.removeJsAdapter(adapter);
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    overflow: TextOverflow.clip,
                    maxLines: null,
                    '新的视频源可以通过添加自定义JavaScript适配器来添加，而不用依赖于作者更新。关于添加自定义Javascript适配器的更多信息，请在github查看。',
                  ),
                ),
                IconButton(
                    onPressed: () => launchUrlString(
                        'https://github.com/KNKPA/KNKPAnime-js-adapters'),
                    icon: const Icon(Icons.open_in_new))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

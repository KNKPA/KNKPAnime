# knkpanime

一个支持多番剧源和弹幕的看番（甚至看电视剧）软件，甚至可以自定义你想接入的网站适配器！

有问题或建议欢迎通过issue反馈。

## 下载

[下载链接](https://github.com/KNKPA/KNKPAnime/releases/latest)

另：macOS版可以在[预览版](https://github.com/KNKPA/KNKPAnime/releases/tag/latest)中下载，但不知为什么，github workflow编译的macOS版在我的mac上打开视频播放页时会崩溃（目前猜测是libmpv问题），而本地编译的则不会。如果mac用户想用但在github的release中下载的软件打不开的话，可以尝试自行编译：

```
[[ $(uname -m) == 'x86_64' ]] && wget https://storage.flutter-io.cn/flutter_infra_release/releases/stable/macos/flutter_macos_3.19.5-stable.zip -O flutter.zip || wget https://storage.flutter-io.cn/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.19.5-stable.zip -O flutter.zip
unzip flutter.zip
git clone https://github.com/KNKPA/KNKPAnime.git # 如果访问github有问题可以选择国内镜像
cd KNKPAnime
../flutter/bin/flutter build macos --release
mv build/macos/Build/Products/Release/knkpanime.app ../
cd ..
rm -rf KNKPAnime flutter flutter.zip
```

## 介绍

最重要的当然就是搜索啦。作为一个支持多番剧源的软件，你可以先在Bangumi上搜索想看的番剧，再选择可用的源观看：

![Bangumi search](.github/images/Bangumi-search.png)

![source selection](.github/images/source-selection.png)

当然，有的时候也会因为不同译名或番剧名中有特殊符号而导致使用Bangumi搜索很难匹配到番剧源中的数据，这个时候就可以用番剧源搜索来自定义用来搜索的词：

![oops, not found](.github/images/oops-not-found.png)

![hooray! found](.github/images/hooray-found.png)

需要注意的是，在”Bangumi搜索“页面搜索时，会使用Bangumi提供的番剧名以及你所输入的搜索词在各番剧源进行两次搜索；而在追番、新番日历这两个页面点击某一个番剧的时候，只会用Bangumi提供的番剧名进行一次搜索，因此可能会出现无法搜索到的情况。如果这种情况发生的话，请在两个搜索界面搜索或通过历史记录进入（如果你看过这部番的话）。

然后就是一些比较常规的功能 - 历史记录、追番、番剧更新日历等，应该不需要过多介绍。

## 桌面版快捷键

| 快捷键 | 对应操作 |
|-------|-------|
| J | 快进90秒（跳过OP/ED）|
| 左右箭头 | 快进/快退10秒 |
| 上下箭头 | 音量增加/减少5% |
| esc | 退出全屏 |
| D | 开启/关闭弹幕 |
| F | 开启/退出全屏 |
| [ | 上一集 |
| ] | 下一集 |

## 自定义适配器

所谓适配器，就是解析在线观看网站的接口从而获取搜索结果、视频资源并提供给播放器播放的代码模块。在船新的1.1.0版本中，本软件已经可以支持两种适配器的定义形式以及解析形式，分别为：

### 定义形式

#### 内置适配器

这种适配器使用dart代码编写，直接随主程序编译，运行速度和资源消耗上最有优势。当然，既然是随主程序一起编译，代价就是
- 加入新的适配器必须通过向主程序提交代码的方式，即PR，并需要我的允许。~~当然我也不会不允许就是了（~~
- 新的适配器以及修复过期链接等操作必须随新版本发布，并不灵活。

#### JavaScript适配器

通过使用[flutter_js](https://github.com/abner/flutter_js)，软件内置了一个JavaScript runtime，可以用来即时执行JS代码。利用这个JS runtime，我们可以随时获取互联网上的适配器并添加到软件中。虽然损失了一些性能，但毕竟搜索和解析视频都是相对不频繁的操作（相对于UI等等耗能大户来说），因此不会造成太大影响。

**请从您信任的来源添加适配器**

### 解析形式

#### 基于规则

基于手写规则的解析，需要编写者去检查网站代码并找出视频源的URL到底如何得到。

#### 基于WebView

通过在软件中跑一个不可见的浏览器，我们可以用他山之石来攻他山的玉，通过执行原网站的全部操作并获取视频链接。

## Acknowledgement

本项目受[oneAnime](https://github.com/Predidit/oneAnime)启发，并在Anime1的适配器中借用了其代码。

本项目使用了[Bangumi](http://bangumi.tv/)、[dandanplay](https://www.dandanplay.com/)的开放API。网站运营不易，请各位在能力范围内尽量支持这两个网站的运营。
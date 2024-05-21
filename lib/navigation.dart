import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/app_module.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';
import 'package:url_launcher/url_launcher_string.dart';

bool _checkedForUpdate = false;

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

void checkForUpdate(BuildContext context) async {
  // This function can't be written at a higher level of the widget tree since
  // some context problem...
  if (_checkedForUpdate) return;
  _checkedForUpdate = true;
  Response resp;
  try {
    resp = await Dio().get<Map<String, dynamic>>(
        'https://api.github.com/repos/KNKPA/KNKPAnime/releases/latest');
  } catch (e) {
    Modular.get<Logger>().w(e);
    if (!Modular.get<SettingsController>().disableGithubProxy) {
      try {
        // This is a cloudflare worker defined under my domain.
        // It serves as a proxy to the github API.
        // You can disable this proxy in the settings page.
        resp = await Dio()
            .get<Map<String, dynamic>>('https://api.withit.live/latest');
      } catch (e) {
        Modular.get<Logger>().w(e);
        return;
      }
    } else {
      return;
    }
  }
  Modular.get<Logger>().i(version);
  if (resp.data!['tag_name'] != version) {
    Modular.get<Logger>().i('Found new version: ${resp.data!["tag_name"]}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('发现新版本${resp.data!["tag_name"]}\n${resp.data!["body"]}'),
        action: SnackBarAction(
          label: '查看',
          onPressed: () => launchUrlString(
              'https://github.com/KNKPA/KNKPAnime/releases/latest'),
        ),
      ),
    );
  }
}

class _SideMenuState extends State<SideMenu> {
  int _selectedIndex = routes.indexOf(routes.firstWhere(
    (element) => Modular.to.path.startsWith(element['path'] as String),
    orElse: () => {},
  ));
  String path = '';
  late final listener = () {
    debugPrint(Modular.to.path);
    setState(() {
      path = Modular.to.path;
    });
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    Modular.to.addListener(listener);
    path = Modular.to.path;
    checkForUpdate(context);
  }

  @override
  void dispose() {
    Modular.to.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (path == '/play/') return Container();
    if (_selectedIndex == -1) _selectedIndex = 0;
    var listContent = <Widget>[];
    listContent
        .addAll(routes.where((e) => !(e['bottom'] as bool)).map((e) => ListTile(
              title: Text(e['name'] as String),
              leading: e['icon'] as Widget,
              onTap: () {
                _onItemTapped(routes.indexOf(e));
                Modular.to.navigate(e['path'] as String);
              },
              selected: _selectedIndex == routes.indexOf(e),
            )));
    listContent.add(const Spacer());
    listContent
        .addAll(routes.where((e) => e['bottom'] as bool).map((e) => ListTile(
              title: Text(e['name'] as String),
              leading: e['icon'] as Widget,
              onTap: () {
                _onItemTapped(routes.indexOf(e));
                Modular.to.navigate(e['path'] as String);
              },
              selected: _selectedIndex == routes.indexOf(e),
            )));
    return Expanded(
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(),
        ),
        child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sidemenu_background.jpg'),
                fit: BoxFit.cover,
              ),
              color: Color.fromRGBO(0, 0, 0, 0.3),
            ),
            child: Theme(
              data: ThemeData.dark(useMaterial3: true),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(children: listContent),
              ),
            )),
      ),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = routes.indexOf(routes.firstWhere(
    (element) => Modular.to.path.startsWith(element['path'] as String),
    orElse: () => {},
  ));
  String path = '';
  late final listener = () {
    debugPrint(Modular.to.path);
    setState(() {
      path = Modular.to.path;
    });
  };

  @override
  void initState() {
    super.initState();
    Modular.to.addListener(listener);
    path = Modular.to.path;
    checkForUpdate(context);
  }

  @override
  void dispose() {
    Modular.to.removeListener(listener);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (path == '/play/') return const SizedBox.shrink();
    if (_selectedIndex == -1) _selectedIndex = 0;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      items: routes
          .map((e) => BottomNavigationBarItem(
              icon: e['icon'] as Icon, label: e['name'] as String))
          .toList(),
      currentIndex: _selectedIndex,
      onTap: (i) {
        _onItemTapped(i);
        Modular.to.navigate(routes[i]['path'] as String);
      },
    );
  }
}

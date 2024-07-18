import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knkpanime/navigation.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    // 设置高帧率
    if (Platform.isAndroid) {
      try {
        late List modes;
        FlutterDisplayMode.supported.then((value) {
          modes = value;
          DisplayMode f = DisplayMode.auto;
          DisplayMode preferred = modes.toList().firstWhere((el) => el == f);
          FlutterDisplayMode.setPreferredMode(preferred);
        });
      } catch (_) {}
    }
    return AdaptiveTheme(
        light: ThemeData.light(useMaterial3: true).copyWith(
            textTheme: Modular.get<SettingsController>().useDefaultFont
                ? null
                : GoogleFonts.notoSerifHkTextTheme()),
        dark: ThemeData.dark(useMaterial3: true).copyWith(
            textTheme: Modular.get<SettingsController>().useDefaultFont
                ? null
                : GoogleFonts.notoSerifHkTextTheme()),
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp.router(
            title: "KNKP Anime",
            theme: theme,
            darkTheme: darkTheme,
            //routeInformationParser: Modular.routeInformationParser,
            //routerDelegate: Modular.routerDelegate,
            routerConfig: Modular.routerConfig,
            builder: (context, child) => Overlay(
                  initialEntries: [
                    OverlayEntry(
                        builder: (context) => Scaffold(
                              body: SafeArea(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!Utils.isSmallScreen(context))
                                      const SideMenu(),
                                    Expanded(
                                      flex: 5,
                                      child: child!,
                                    )
                                  ],
                                ),
                              ),
                              bottomNavigationBar: Utils.isSmallScreen(context)
                                  ? const BottomNavigation()
                                  : null,
                            ))
                  ],
                )));
  }
}

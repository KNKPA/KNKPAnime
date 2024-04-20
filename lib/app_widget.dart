import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/navigation.dart';
import 'package:knkpanime/utils/utils.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: ThemeData.light(useMaterial3: true),
        dark: ThemeData.dark(useMaterial3: true),
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

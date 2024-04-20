import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knkpanime/adapters/adapter_base.dart';

class Utils {
  Utils._();

  static bool isDesktop() =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static String dur2str(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
  }

  static Color getColorFromStatus(SearchStatus status) {
    switch (status) {
      case SearchStatus.success:
        return Colors.green;
      case SearchStatus.failed:
        return Colors.red;
      case SearchStatus.pending:
        return Colors.grey;
    }
  }
}

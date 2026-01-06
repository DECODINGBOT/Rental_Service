import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/theme/dark_theme.dart';
import 'package:sharing_items/theme/foundation/app_theme.dart';
import 'package:sharing_items/theme/light_theme.dart';

class ThemeService with ChangeNotifier {
  ThemeService({
    AppTheme? theme,
  }) : theme = theme ?? LightTheme();

  /// 현재 테마
  AppTheme theme;

  /// 테마 변경
  void toggleTheme() {
    if (theme.brightness == Brightness.light) {
      theme = DarkTheme();
    } else {
      theme = LightTheme();
    }
    notifyListeners();
  }
}

extension ThemeServiceExt on BuildContext {
  ThemeService get themeService => watch<ThemeService>();
  AppTheme get theme => themeService.theme;
  AppColor get color => theme.color;
  AppDeco get deco => theme.deco;
  AppTypo get typo => theme.typo;
}

// preferences service — manages user settings with shared preferences
// handles theme preference, user name, and first-launch detection

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyUserName = 'user_name';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyInterests = 'interests';

  // get the user's saved name
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? '';
  }

  // save the user's name
  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  // check if dark mode is enabled
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  // toggle dark mode setting
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  // check if this is the first launch (show setup screen)
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  // mark that the user has completed setup
  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  // get user's selected interests
  Future<List<String>> getInterests() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyInterests) ?? [];
  }

  // save user's selected interests
  Future<void> setInterests(List<String> interests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyInterests, interests);
  }
}

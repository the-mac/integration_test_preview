import 'package:example/platforms.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final stateKey = GlobalKey();

class Prefs {
 
  static Map preferenceResults = {};
  static late SharedPreferences _prefs;

  // call this method from iniState() function of mainApp().
  static void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    preferenceResults = {
      'preference-0': _prefs.getBool('preference-0') ?? false,
      'preference-1': _prefs.getBool('preference-1') ?? false,
      'preference-2': _prefs.getBool('preference-2') ?? false,
      'preference-3': _prefs.getBool('preference-3') ?? false,
      'preference-4': _prefs.getBool('preference-4') ?? false,
      'preference-5': _prefs.getBool('preference-5') ?? false,
      'preference-6': _prefs.getBool('preference-6') ?? false,
    };
  }

  static bool getBool(String key) {
      return preferenceResults[key];
  }

  static void setBool(String key, bool newValue) async {
      
      _prefs.setBool(key, newValue);
      preferenceResults[key] = newValue;

      final state = stateKey.currentState!;
      state.setState(() {});
      
  }

  static void clearPreferences() async  => _prefs.clear();
  
}

class PreferencesPage extends StatefulWidget {

  PreferencesPage() : super(key: stateKey);

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  Widget _buildListTile(int position, String title) {
      final prefKey = 'preference-$position';
      return ListTile(
          title: Text(title),
          trailing: Switch.adaptive(
            key: Key(prefKey),
            value: Prefs.getBool(prefKey),
            onChanged: (value) => Prefs.setBool(prefKey, value),
          ),
      );
  }

  Widget _buildList() {
    return Scaffold(
        body: ListView(
        children: [
          const Padding(padding: EdgeInsets.only(top: 24)),
          _buildListTile(0, 'Notifications for new packages'),
          _buildListTile(1, 'Github Pull Requests updates'),
          _buildListTile(2, 'Send Mobile Community updates'),
          _buildListTile(3, 'Github - Flutter Community updates'),
          _buildListTile(4, 'Github - Android Community updates'),
          _buildListTile(5, 'Github - iOS Community updates'),
          _buildListTile(6, 'Github - Django Community updates')
        ],
    ));
  }

  @override Widget build(context) => _buildList();
}
import 'package:example/platforms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_widgets_prefix/responsive_widgets_prefix.dart';
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

  Widget _baseListTile(int position, String title) {
      final prefKey = 'preference-$position';
      return ListTile(
          tileColor: Colors.white,
          title: ResponsiveText(title,
            style: const TextStyle(
              color: Colors.black,
              // backgroundColor: Colors.white 
            ),
          ),
          trailing: Switch.adaptive(
            key: Key(prefKey),
            value: Prefs.getBool(prefKey),
            onChanged: (value) => Prefs.setBool(prefKey, value),
          ),
      );
  }

  Widget _buildAndroidListTile(int position, String title) {
      return _baseListTile(position, title);
  }

  Widget _buildIOSListTile(int position, String title) {
      // return Theme(
      //   data: ThemeData.light(),
      //   child: _baseListTile(position, title)
      // );
      return Material(child: _baseListTile(position, title));
  }

  Widget _buildListTile(int position, String title) {
    if(PlatformWidget.isAndroid) {
        return _buildAndroidListTile(position, title);
    } else {
        return _buildIOSListTile(position, title);
    }
  }

  Widget _buildList() {
    const padding = 5.0;
    return ListView(
      children: [
          const Padding(padding: EdgeInsets.only(top: 24)),
          _buildListTile(0, 'Notifications for new packages'),
          ResponsivePadding(padding: const EdgeInsets.only(top: padding)),
          _buildListTile(1, 'Github Pull Requests updates'),
          ResponsivePadding(padding: const EdgeInsets.only(top: padding)),
          _buildListTile(2, 'Send Mobile Community updates'),
          ResponsivePadding(padding: const EdgeInsets.only(top: padding)),
          _buildListTile(3, 'Github - Flutter Community updates'),
          ResponsivePadding(padding: const EdgeInsets.only(top: padding)),
          _buildListTile(4, 'Github - Android Community updates'),
          ResponsivePadding(padding: const EdgeInsets.only(top: padding)),
          _buildListTile(5, 'Github - iOS Community updates'),
          ResponsivePadding(padding: const EdgeInsets.only(top: padding)),
          _buildListTile(6, 'Github - Django Community updates')
        ],
    );
  }

  // @override Widget build(context) => _buildList();

  // Widget _buildBody(BuildContext context) {
  //   return ListView(
  //       children: [...demos.map((d) => _getDemoTile(d, demos.indexOf(d)))]);
  // }

  Widget _buildAndroid(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: _buildList(),
      );
  }

  Widget _buildIOS(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(),
        child: SafeArea(child: _buildList())
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIOS,
    );
  }
}
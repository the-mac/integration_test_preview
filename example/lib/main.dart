import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:drawer_manager/drawer_manager.dart';
import 'package:responsive_widgets_prefix/responsive_widgets_prefix.dart';

import 'platforms.dart';
import 'hello.dart';
import 'counter.dart';
import 'languages.dart';
import 'the_mac.dart';
import 'preferences.dart';

// clear && printf '\e[3J' && flutter run ; flutter clean

void main() {
  runApp(setupMainWidget());
}

Widget setupMainWidget() {
  WidgetsFlutterBinding.ensureInitialized();
  return const MyApp();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(context) {
    return ChangeNotifierProvider<DrawerManagerProvider>(
        create: (_) => DrawerManagerProvider(),
        child: PlatformApp(
            // defaultPlatform: TargetPlatform.iOS,
            defaultPlatform: PlatformWidget.platform,
            defaultScreenType: PlatformWidget.screenType,
            androidApp: ResponsiveMaterialApp(home: const MyHomePage()),
            iosApp: ResponsiveCupertinoApp(
              theme: const CupertinoThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.blue,
                scaffoldBackgroundColor: Colors.white
              ),
              home: const MyHomePage(),
            )
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override void initState() { Prefs.initialize(); }

  String _getTitle(int index) {
      switch (index) {
        case 0: return 'Hello';
        case 1: return 'Languages';
        case 2: return 'Counter Sample';
        case 3: return 'Mobile Community';
        case 4: return 'Preferences';
        default: return '';
      }
  }

  String _getTabBarTitle(int index) {
      return 'Tab Bar ' + _getTitle(index);
  }

  Widget _getTitleWidget() {
    return Consumer<DrawerManagerProvider>(builder: (context, dmObj, _) {
      return Text(
        _getTitle(dmObj.selection),
        key: const Key('app-bar-text')
      );
    });
  }

  Widget _buildAndroidHomePage(BuildContext context) {

    final drawerSelections = [
      const HelloPage(),
      const LanguagesPage(),
      const CounterPage(),
      const TheMACPage(),
      PreferencesPage()
    ];
    
    final manager = Provider.of<DrawerManagerProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(title: _getTitleWidget()),
        body: manager.body,
        drawer: DrawerManager(
          context,
          drawerElements: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.blueGrey,
                  size: 96,
                ),
              ),
            ),
            DrawerTile(
              key: const Key('drawer-hello'),
              context: context,
              leading: const Icon(Icons.hail_rounded),
              title: Text(_getTitle(0)),
              onTap: () async {
                // RUN A BACKEND Hello, Flutter OPERATION
              },
            ),
            DrawerTile(
              key: const Key('drawer-languages'),
              context: context,
              leading: const Icon(Icons.hail_rounded),
              title: Text(_getTitle(1)),
              onTap: () async {
                // RUN A BACKEND Hello, Flutter OPERATION
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            DrawerTile(
              key: const Key('drawer-counter'),
              context: context,
              leading: const Icon(Icons.calculate),
              title: Text(_getTitle(2)),
              onTap: () async {
                // RUN A BACKEND Counter OPERATION
              },
            ),
            DrawerTile(
              key: const Key('drawer-community'),
              context: context,
              leading: const Icon(Icons.plus_one),
              title: Text(_getTitle(3)),
              onTap: () async {
                // RUN A BACKEND Signup OPERATION
              },
            ),
            DrawerTile(
              key: const Key('drawer-preferences'),
              context: context,
              leading: const Icon(Icons.settings),
              title: Text(_getTitle(4)),
              onTap: () async {
                // RUN A BACKEND Preferences OPERATION
              },
            ),
          ],
          tileSelections: drawerSelections,
        ));
  }

  Widget _buildIosHomePage(BuildContext context) {

    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
            items: [
                BottomNavigationBarItem(
                    label: _getTitle(0),
                    tooltip: _getTabBarTitle(0),
                    icon: const Icon(Icons.hail_rounded),
                ),
                BottomNavigationBarItem(
                    label: _getTitle(1),
                    tooltip: _getTabBarTitle(1),
                    icon: const Icon(Icons.hail_rounded),
                ),
                BottomNavigationBarItem(
                    label: _getTitle(2),
                    tooltip: _getTabBarTitle(2),
                    icon: const Icon(Icons.calculate),
                ),
                BottomNavigationBarItem(
                    label: _getTitle(3),
                    tooltip: _getTabBarTitle(3),
                    icon: const Icon(Icons.plus_one),
                ),
                BottomNavigationBarItem(
                    label: _getTitle(4),
                    tooltip: _getTabBarTitle(4),
                    icon: const Icon(Icons.settings),
                ),
            ],
        ),
        // ignore: avoid_types_on_closure_parameters
        tabBuilder: (BuildContext context, int index) {
            // final title = _getTitle(index);
            switch (index) {
            case 0:
                return CupertinoTabView(
                    // defaultTitle: title,
                    builder: (context) => const HelloPage(),
                );
            case 1:
                return CupertinoTabView(
                    // defaultTitle: title,
                    builder: (context) => const LanguagesPage(),
                );
            case 2:
                return CupertinoTabView(
                    // defaultTitle: title,
                    builder: (context) => const CounterPage(),
                );
            case 3:
                return CupertinoTabView(
                    // defaultTitle: title,
                    builder: (context) => const TheMACPage(),
                );
            case 4:
                return CupertinoTabView(
                    // defaultTitle: title,
                    builder: (context) => PreferencesPage(),
                );
            default:
                assert(false, 'Unexpected tab');
                return Container();
            }
        },
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroidHomePage,
      iosBuilder: _buildIosHomePage,
    );
  }

  @override
  void dispose() {
    Prefs.clearPreferences();
    super.dispose();
  }
  
}

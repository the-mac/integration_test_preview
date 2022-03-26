
<p align="center">
  <a href="https://pub.dartlang.org/packages/integration_test_preview"><img src="https://img.shields.io/pub/v/integration_test_preview.svg"></a>
  <a href="https://www.buymeacoffee.com/aloisdeniel">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

<p align="center">
  <img src="https://github.com/aloisdeniel/flutter_device_preview/raw/master/device_preview.gif" alt="Device Preview for Flutter" />
</p>

## Main features

* Preview any device from any device
* Change the device orientation
* Dynamic system configuration (*language, dark mode, text scaling factor, ...)*
* Freeform device with adjustable resolution and safe areas
* Keep the application state
* Plugin system (*Screenshot, File explorer, ...*)
* Customizable plugins

## Quickstart

### Add dependency to your pubspec file

Since Device Preview is a simple Dart package, you have to declare it as any other dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  device_preview: <latest version>
```

### Add DevicePreview

Wrap your app's root widget in a `DevicePreview` and make sure to :

* Set your app's `useInheritedMediaQuery` to `true`.
* Set your app's `builder` to `DevicePreview.appBuilder`.
* Set your app's `locale` to `DevicePreview.locale(context)`.

> Make sure to override the previous properties as described. If not defined, `MediaQuery` won't be simulated for the selected device.

```dart
import 'package:device_preview/device_preview.dart';

void main() => runApp(
  DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(), // Wrap your app
  ),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
```

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.
The Integration Test Helper has pre-configured methods that allow for faster test deployment for end to end (e2e) test coverage (using Android and iOS platform UIs).

<table border="0">
  <tr>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_0.png"></td>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_1.png"></td>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_2.png"></td>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_3.png"></td>
    <td><img width="140" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_preview.gif"></td>
  </tr>  
  <tr center>
    <td  align="center"><p>Open Drawer</p></td>
    <td  align="center"><p>Languages</p></td>
    <td  align="center"><p>Counter</p></td>
    <td  align="center"><p>The MAC</p></td>
    <td  align="center"><p>All Pages</p></td>
  </tr>   
</table>

## Features

The Integration Test Helper is built on top of [Flutter's Integration Tests](https://docs.flutter.dev/testing/integration-tests). Running End to End (e2e) tests can become bloated and unorganized code, and [lead to regressions](https://en.wikipedia.org/wiki/Software_regression) but with this helper, writing tests can be faster, modular and with [full test coverage](https://www.simform.com/blog/test-coverage/). This approach allows for a cleaner development experience, and [less regressions within your apps](https://www.gratasoftware.com/what-is-regression-in-software-development/).

[![Regression Testing](https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_4.png)](https://youtu.be/0wHKVXbsppw)

Integration Test Helper (or the BaseIntegrationTest class) allows for [BlackBox Testing](https://www.guru99.com/black-box-testing.html) using fixture data. The fixtures currently support JSON data, and can be loaded from anywhere within the project folder. Here is what the fixture test data (assets/fixtures/languages.json) looks like that is being blackbox tested...

```json
{
    "count": 7,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "name": "Python",
            "year": 1991,
            "person": "Guido van Rossum",
            "favorited": true,
            "category" : "Scripting, Object Oriented",
            "logo": "logos/python.png",
            "hello" : "helloworld/1_code_prism_language_python.png",
            "arguments" : "arguments/1_code_prism_language_python.png",
            "description" : "Python is an interpreted high-level general-purpose programming language. Guido van Rossum began working on Python in the late 1980s, as a successor to the ABC programming language, and first released it in 1991 as Python 0.9.0. Python’s design philosophy emphasizes code readability with its notable use of significant indentation. Its language constructs as well as its object-oriented approach aim to help programmers write clear, logical code for small and large-scale projects."
        },
        ...
    ]
}
```

This data is typically initialized in the setupInitialData implementation of the BaseIntegrationTest subclass. The following is an example of how you can BlackBox Test your ListViews, as well other types of Widgets with Integration Test Helper:

```dart

class ScreenIntegrationTestGroups extends BaseIntegrationTest {

    late Map _languagesTestData;

    @override
    Future<void> setupInitialData() async {

        _languagesTestData = await loadFixtureJSON('assets/fixtures/languages.json') as Map;

        if (_languagesTestData.isEmpty) {
            throw 'No languages test data found';
        }

    }

    Future<void> validateTestDataAt(int itemIndex, { required String widgetSuffix, required String jsonKey }) async {
        var languageData = _languagesTestData['results'][itemIndex] as Map;
        var itemText = languageData[jsonKey] as String;
        await verifyListExactText(itemIndex, widgetPrefix: 'item', widgetSuffix: widgetSuffix, expectedText: itemText);
    }
        
    Future<void> testLanguagesFeature() async {
        
        // VIEW LANGUAGES PAGE
        await showLanguagesList();
        await verifyTextForKey('app-bar-text', 'Languages');

        await validateTestDataAt(0, widgetSuffix: 'name', jsonKey: 'name');
        await validateTestDataAt(1, widgetSuffix: 'name', jsonKey: 'name');

        // VIEW LANGUAGE Python PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 0);
        await verifyExactText('Python');
        await tapBackArrow();

        // VIEW LANGUAGE Java PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 1);
        await verifyExactText('Java');
        await tapBackArrow();

    }

    Future<void> testCounterFeature() async {

        await showCounterSample();
        await verifyTextForKey('app-bar-text', 'Counter Sample');
        ...

    }

    ...
    
}

```


Integration Test Helper also supports all Major Widget Interactions. When tapping Widgets, the package supports tapForKey, tapForType, tapForTooltip, tapWidget("Containing This Text"), tapListItem and more.

With the tapListItem, we handle the waiting for the UI to load, finding the Widget, and then tapping the found Widget. In addition, we also include ListView item prefixes, and positions within the list.

```dart
    
    Future<void> tapListItem({ required String widgetPrefix, required int itemIndex }) async {
        await waitForUI();
        final itemFinder = find.byKey(ValueKey('${widgetPrefix}_$itemIndex'));
        await tester.tap(itemFinder);
    }

```
Note: Using the tapListItem implementation, we remove at the least 3 lines of code from your integration tests, and allow that functionality to be reused in your own custom implementation of the BaseIntegrationTest class.

Here is what your Widget Key implementation could look like:

```dart
    Card(
        elevation: 1.5,
        child: InkWell(
            key: Key('item_$index'),
            onTap: () {
                Navigator.push<void>(context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                            LanguagePage(index: index, language: item)));
            },
            child: LanguagePreview(index: index, language: item)),
        ),
    );
```

And here is an example of using that Key to tap the list item widget:

```dart
        
    Future<void> testLanguagesFeature() async {
        
        // VIEW LANGUAGES PAGE
        ...

        // VIEW LANGUAGE Python PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 0);
        await verifyExactText('Python');
        await tapBackArrow();

        // VIEW LANGUAGE Java PAGE
        ...

    }

```

## Getting started

Note: this package example uses another one of our packages. It's called the drawer_manager 
package, and can be found [here](https://pub.dev/packages/drawer_manager) for more details on how it works.

### Install Provider, Drawer Manager & Integration Test Helper
```bash

  flutter pub get provider
  flutter pub get drawer_manager
  flutter pub get integration_test_helper

```

### Or install Provider, Drawer Manager & Integration Test Helper (in pubspec.yaml)
```yaml

    ...
    
dependencies:
  flutter:
    sdk: flutter

    ...

  provider: 6.0.2
  drawer_manager: 0.0.4
    
dev_dependencies:

  flutter_test:
    sdk: flutter

  integration_test:
    sdk: flutter

  integration_test_helper: 0.0.1

```

### Add Integration Test Driver file (test_driver/integration_test.dart)
```dart

import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
    onScreenshot: (String screenshotPath, List<int> screenshotBytes) async {
        
        final File image = File(screenshotPath);

        final dir = image.parent;
        if(!await dir.exists()) await dir.create(recursive: true);

        image.writeAsBytesSync(screenshotBytes);
        
        return true;

    }
);

```

## Usage

### Create platforms file (lib/platforms.dart)
```dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformApp extends PlatformWidget {

  PlatformApp({
    Key? key,
    required MaterialApp androidApp,
    required CupertinoApp iosApp,
    required TargetPlatform defaultPlatform,
  }) : super(key: key,
      androidBuilder: (BuildContext context) => androidApp,
      iosBuilder:  (BuildContext context) => iosApp
    ) {
      PlatformWidget.setPlatform(defaultPlatform);
  }

}

class PlatformWidget extends StatefulWidget {
  
  static TargetPlatform? _defaultPlatform;

  static get platform {
      if(_defaultPlatform == null) {
        return TargetPlatform.android;
      }
      return _defaultPlatform;
  }

  static get isAndroid {
      return _defaultPlatform == TargetPlatform.android;
  }

  static get isIOS {
      return _defaultPlatform == TargetPlatform.iOS;
  }

  static void setPlatform(TargetPlatform platform) {
      _defaultPlatform = platform;
  }

  static void reassembleApplication() {
      WidgetsBinding.instance!.reassembleApplication();
  }

  const PlatformWidget({
    Key? key,
    required this.androidBuilder,
    required this.iosBuilder,
  }) : super(key: key);

  final WidgetBuilder androidBuilder;
  final WidgetBuilder iosBuilder;

  @override
  State<PlatformWidget> createState() => _PlatformWidgetState();
}

class _PlatformWidgetState extends State<PlatformWidget> {
  @override
  Widget build(context) {
    switch (PlatformWidget._defaultPlatform) {
      case TargetPlatform.android:
        return widget.androidBuilder(context);
      case TargetPlatform.iOS:      
        return widget.iosBuilder(context);        
      default:
        assert(false, 'Unexpected platform ${PlatformWidget._defaultPlatform}');
        return Container();
    }
  }
}

```

### Create hello file (lib/hello.dart)
```dart

import 'package:flutter/material.dart';

class HelloPage extends StatelessWidget {

  final int position;
  
  const HelloPage({Key? key, required this.position}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Hello, Flutter $position!',
        key: Key('hello-page-text-$position'),
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Color(0xff0085E0),
            fontSize: 48,
            fontWeight: FontWeight.bold
        )
      ),
    );
  }
}

```

### Create main file (lib/main.dart)

```dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drawer_manager/drawer_manager.dart';

import 'hello.dart';

void main() {
  runApp(setupMainWidget());
}

Widget setupMainWidget() {
  WidgetsFlutterBinding.ensureInitialized();
  return const MyApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DrawerManagerProvider>(
        create: (_) => DrawerManagerProvider(),
        child: PlatformApp(
            defaultPlatform: PlatformWidget.platform,
            androidApp: const MaterialApp(home: MyHomePage()),
            iosApp: const CupertinoApp(
                theme: CupertinoThemeData(brightness: Brightness.light),
                home: MyHomePage(),
            )
        )
      );
  }
}

class MyHomePage extends StatelessWidget {

  const MyHomePage({Key? key}) : super(key: key);

  String _getTitle(int index) {
      switch (index) {
        case 0: return 'Hello 1';
        case 1: return 'Hello 2';
        default: return '';
      }
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
      const HelloPage(position: 1),
      const HelloPage(position: 2),
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
              key: const Key('drawer-hello-1'),
              context: context,
              leading: const Icon(Icons.hail_rounded),
              title: Text(_getTitle(0)),
              onTap: () async {
                // RUN A BACKEND Hello, Flutter OPERATION
              },
            ),
            DrawerTile(
              key: const Key('drawer-hello-2'),
              context: context,
              leading: const Icon(Icons.hail_rounded),
              title: Text(_getTitle(1)),
              onTap: () async {
                // RUN A BACKEND Hello, Flutter OPERATION
              },
            )
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
            final title = _getTitle(index);
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

}

```

### Import Flutter Test & Integration Test Preview (in integration_test/app_test_groups.dart)
```yaml
    ...
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_preview/integration_test_preview.dart';

```

### Subclass IntegrationTestPreview (in integration_test/app_test_groups.dart)

The Integration Test Preview supports platform specific implementations, for methods like the showHelloFlutter
method. This method uses the Drawer for Android and accomodates the Android environment UI interations. And uses 
the Tab Bar for iOS and accomodates the iOS environment UI interations.

```dart

class ScreenIntegrationTestGroups extends IntegrationTestPreview {

    // ...

    @override
    Future<void> setupInitialData() async {
        // ...
    }

    @override
    Future<BuildContext> getBuildContext() async {
        if(await isPlatformAndroid()) {
          final elementType = find.byType(MaterialApp);
          return tester.element(elementType);
        } else {
          final elementType = find.byType(CupertinoApp);
          return tester.element(elementType);
        }
    }
    
    @override
    Future<void> togglePlatformUI(TargetPlatform platform) async {
        PlatformWidget.setPlatform(platform);
        PlatformWidget.reassembleApplication();
        await waitForUI(durationMultiple: 2);
    }
    
    @override
    Future<void> testDeviceEndToEnd(DeviceInfo device) async {

        await waitForUI(durationMultiple: 2);
        await testHelloFlutterFeature();

    }

    Future<void> showHelloFlutter({required int position}) async {
        print('Showing Hello, Flutter $position!');
        if(Platform.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-hello-$position');
        }
        await waitForUI();
    }

    Future<void> setupScreenshot(String fileName) async {
        String platformType = PlatformWidget.isAndroid ? 'android' : 'ios';
        String screenshotPath = 'screenshots/$platformType/$fileName.png';
        print('Setting up screenshot: $screenshotPath');
        await takeScreenshot(screenshotPath);
    }

    Future<void> testHelloFlutterFeature() async {
        await showHelloFlutter(position: 1);
        await verifyTextForKey('app-bar-text', 'Hello 1');
        await verifyTextForKey('hello-page-text-1', 'Hello, Flutter 1!');
        await setupScreenshot('hello_flutter_1');

        await showHelloFlutter(position: 2);
        await verifyTextForKey('app-bar-text', 'Hello 2');
        await verifyTextForKey('hello-page-text-2', 'Hello, Flutter 2!');
        await setupScreenshot('hello_flutter_2');
    }

    // ...

}

```

### Setup IntegrationTestPreview Subclass (in integration_test/app_test.dart)
```dart

import 'package:flutter_test/flutter_test.dart';
import 'package:device_frame/src/info/info.dart';
import 'package:device_frame/src/devices/devices.dart';
import 'package:integration_test_preview/integration_test_binding.dart';

import 'package:example/main.dart' as app;
import 'app_test_groups.dart';

void main() async {

    final binding = IntegrationTestPreviewBinding.ensureInitialized();

    testWidgets('Testing end to end multi-screen integration', (WidgetTester tester) async {
      
          final main = app.setupMainWidget();
          final List<DeviceInfo> testDevices = [
            Devices.ios.iPhone12,
            Devices.android.samsungGalaxyNote20
          ];
          
          final integrationTestGroups = ScreenIntegrationTestGroups(binding);
          await integrationTestGroups.initializeDevices(testDevices, state: ScreenshotState.PREVIEW);
          await integrationTestGroups.initializeTests(tester, main);
          await integrationTestGroups.testDevicesEndToEnd();

      }, timeout: const Timeout(Duration(minutes: 3))
    );
    
}

```

### Run Driver on BaseIntegrationTest Subclass (using integration_test/app_test.dart)
```bash

    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

```

### Review the screenshot results
The screenshots used in setupScreenshot are generated after the test completes...

![Integration Testing Screenshots](https://raw.githubusercontent.com/the-mac/integration_test_helper/main/media/integration_test_5.png)

<table border="0">
  <tr>
    <td><img width="160" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_android_hello_1.png"></td>
    <td><img width="160" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_android_hello_2.png"></td>
    <td><img width="160" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_ios_hello_1.png"></td>
    <td><img width="160" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_ios_hello_2.png"></td>
  </tr>  
  <tr center>
    <td  align="center"><p>Android Hello 1</p></td>
    <td  align="center"><p>Android Hello 2</p></td>
    <td  align="center"><p>iOS Hello 1</p></td>
    <td  align="center"><p>iOS Hello 2</p></td>
  </tr>   
</table>


## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.

<h4 align="center">Integration Test on multiple screen sizes in a single e2e test run, to see how your app looks and performs on another device.</h4>


## Documentation

<a href='https://aloisdeniel.github.io/flutter_device_preview/' target='_blank'>Open the website</a>

## Demo

<a href='https://flutter-device-preview.firebaseapp.com/' target='_blank'>Open the demo</a>

## Limitations

Think of Device Preview as a first-order approximation of how your app looks and feels on a mobile device. With Device Mode you don't actually run your code on a mobile device. You simulate the mobile user experience from your laptop, desktop or tablet.

> There are some aspects of mobile devices that Device Preview will never be able to simulate. When in doubt, your best bet is to actually run your app on a real device.
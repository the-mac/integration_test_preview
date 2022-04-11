
<p align="center">
  <a href="https://pub.dartlang.org/packages/integration_test_preview"><img src="https://img.shields.io/pub/v/integration_test_preview.svg"></a>
</p>

Integration Test Preview has pre-configured methods that allow for faster test deployment for end to end (e2e) test coverage (using Android and iOS platform UIs). This package is based upon the [Integration Test Helper](https://pub.dev/packages/integration_test_helper) and [Device Preview](https://pub.dev/packages/device_preview) packages, and does much more with the combination of the two of them. It also allows for specific device size preview screenshots for the app stores, generated locally in your project path.

<p align="center">
  <img width="460" src="https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_preview.gif" alt="Integration Test Preview" />
</p>

## Features

When running a test using a IntegrationTestPreview subclass, you can assign the devices that you want to test against (and take screenshots for). The following is an example of how you can test all your features end to end on multiple screen types:

```dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_preview/integration_test_binding.dart';
import 'package:device_frame_community/src/devices/devices.dart';
import 'package:device_frame_community/src/info/info.dart';

import 'package:example/main.dart' as app;
import 'app_feature_groups.dart';

void main() async {

    const minutesPerDevice = 3;
    final List<DeviceInfo> testDevices = [
        Devices.ios.iPhone12, Devices.android.samsungGalaxyNote20, Devices.ios.iPadPro11Inches,
    ];
    final totalExpectedDuration = Duration(minutes: testDevices.length * minutesPerDevice);
    final binding = IntegrationTestPreviewBinding.ensureInitialized();

    testWidgets('Testing end to end multi-screen integration', (WidgetTester tester) async {
      
          final main = app.setupMainWidget();
          
          final integrationTestGroups = ScreenIntegrationTestGroups(binding);
          await integrationTestGroups.initializeDevices(testDevices, state: ScreenshotState.RESPONSIVE);
          await integrationTestGroups.initializeTests(tester, main);

      }, timeout: Timeout(totalExpectedDuration)
    );
    
}

```

## Getting started

Note: This example uses another one of our packages. It's called the drawer_manager 
package, and can be found [here](https://pub.dev/packages/drawer_manager) for more details on how it works.

### Install Provider, Drawer Manager & Integration Test Preview
```bash

  flutter pub get provider
  flutter pub get drawer_manager
  flutter pub get integration_test_preview

```

### Or install Provider, Drawer Manager & Integration Test Preview (in pubspec.yaml)
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

  integration_test_preview: <latest_version>

```

### Add Integration Test Driver file (test_driver/app_features_test.dart)
```dart

import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
    onScreenshot: (String screenshotPath, List<int> screenshotBytes) async {
        
        final File image = File(screenshotPath);
        print('$image');

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
  
  static TargetPlatform? _currentPlatform;

  static get platform {
      if(_currentPlatform == null) {
        return TargetPlatform.android;
      }
      return _currentPlatform;
  }

  static get isAndroid {
      return _currentPlatform == TargetPlatform.android;
  }

  static get isIOS {
      return _currentPlatform == TargetPlatform.iOS;
  }

  static void setPlatform(TargetPlatform platform) {
      _currentPlatform = platform;
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
    switch (PlatformWidget._currentPlatform) {
      case TargetPlatform.android:
        return widget.androidBuilder(context);
      case TargetPlatform.iOS:      
        return widget.iosBuilder(context);        
      default:
        assert(false, 'Unexpected platform ${PlatformWidget._currentPlatform}');
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drawer_manager/drawer_manager.dart';

import 'platforms.dart';
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
                    icon: const Icon(Icons.hail_rounded),
                ),
                BottomNavigationBarItem(
                    label: _getTitle(1),
                    icon: const Icon(Icons.hail_rounded),
                ),
            ],
        ),
        // ignore: avoid_types_on_closure_parameters
        tabBuilder: (BuildContext context, int index) {
            switch (index) {
            case 0: return CupertinoTabView(
                    builder: (context) => const HelloPage(position: 1),
                );
            case 1: return CupertinoTabView(
                    builder: (context) => const HelloPage(position: 2),
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

### Import Flutter Test & Integration Test Preview (in integration_test/app_feature_groups.dart)
```yaml
    ...
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_frame/src/info/info.dart';
import 'package:integration_test_preview/integration_test_preview.dart';

import 'package:example/platforms.dart';

```

### Subclass IntegrationTestPreview (in integration_test/app_feature_groups.dart)

The Integration Test Preview supports platform specific implementations, for methods like the showHelloFlutter
method. This method uses the Drawer for Android and accomodates the Android environment UI interations. And uses 
the Tab Bar for iOS and accomodates the iOS environment UI interations.

```dart

class ScreenIntegrationTestGroups extends IntegrationTestPreview {

    ScreenIntegrationTestGroups(binding) : super(binding);

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
    Future<void> toggleDeviceUI(DeviceInfo device) async {
        PlatformWidget.setPlatform(device.identifier.platform);
    }
    
    @override
    Future<void> testDeviceEndToEnd(DeviceInfo device) async {

        await waitForUI(durationMultiple: 2);
        await testHelloFlutterFeature(device);

    }

    Future<void> showHelloFlutter({required int position}) async {
        print('Showing Hello, Flutter $position!');
        if(PlatformWidget.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-hello-$position');
        } else {
            await tapWidget('Hello $position');
        }
        await waitForUI();
    }

    Future<void> setupScreenshot(String fileName, DeviceInfo device) async {
        String platformType = PlatformWidget.isAndroid ? 'android' : 'ios';
        String devicePath = device.identifier.name.replaceAll('-', '_');
        String screenshotPath = 'screenshots/$platformType/$devicePath/$fileName.png';
        print('Setting up screenshot: $screenshotPath');
        await takeScreenshot(screenshotPath);
    }

    Future<void> verifyAppBarText(String text) async {

        if(PlatformWidget.isAndroid) {
            await verifyTextForKey('app-bar-text', text);
        }
      
    }

    Future<void> testHelloFlutterFeature(DeviceInfo device) async {
        await showHelloFlutter(position: 1);
        await verifyAppBarText('Hello 1');
        await verifyTextForKey('hello-page-text-1', 'Hello, Flutter 1!');
        await setupScreenshot('hello_flutter_1', device);

        await showHelloFlutter(position: 2);
        await verifyAppBarText('Hello 2');
        await verifyTextForKey('hello-page-text-2', 'Hello, Flutter 2!');
        await setupScreenshot('hello_flutter_2', device);
    }

    // ...

}

```

### Setup IntegrationTestPreview Subclass (in integration_test/app_features.dart)
```dart

import 'package:flutter_test/flutter_test.dart';
import 'package:device_frame/src/info/info.dart';
import 'package:device_frame/src/devices/devices.dart';
import 'package:integration_test_preview/integration_test_binding.dart';

import 'package:example/main.dart' as app;
import 'app_feature_groups.dart';

void main() async {

    const minutesPerDevice = 3;
    final List<DeviceInfo> testDevices = [
        Devices.ios.iPhone12, Devices.android.samsungGalaxyNote20, Devices.ios.iPadPro11Inches,
    ];
    final totalExpectedDuration = Duration(minutes: testDevices.length * minutesPerDevice);
    final binding = IntegrationTestPreviewBinding.ensureInitialized();

    testWidgets('Testing end to end multi-screen integration', (WidgetTester tester) async {
      
          final main = app.setupMainWidget();
          
          final integrationTestGroups = ScreenIntegrationTestGroups(binding);
          await integrationTestGroups.initializeDevices(testDevices, state: ScreenshotState.RESPONSIVE);
          await integrationTestGroups.initializeTests(tester, main);

      }, timeout: Timeout(totalExpectedDuration)
    );
    
}

```

### Run Driver on IntegrationTestPreview Subclass (using integration_test/app_features.dart)
```bash

    flutter drive -t integration_test/app_features.dart

```

### Reviewing the screenshot results

The screenshots named in setupScreenshot are generated after the test completes, in the screenshots directory from the test_driver/app_features_test.dart example above.

![Integration Testing Screenshots](https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_4.png)

But if you want to review all of them at once there is a helper dart file called [screenshots.dart](https://github.com/the-mac/integration_test_preview/tree/main/screenshots.dart) in the example project. For it to work, you should copy/save the screenshots.dart file to you project's root, and execute the following on a Mac / Linux Device:

```bash

    dart screenshots.dart screenshots/*/*/*

```

Alternatively, you can run the following on a Windows Device:
```bash

    Get-ChildItem screenshots\* -recurse > devices.txt
    set /p devices= < devices.txt
    dart screenshots.dart "%devices%"

```
Note: This example should be updated, because it hasn't been tested in Windows.

After the dart script executes, the path for the screenshots.html is displayed in the console where you can open it in a browser:

```bash
  
  /Users/your/project/path/screenshots.html

```

This is a preview of the screenshots gallery that is generated:

![Integration Testing Screenshots Gallery](https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_5.png)

And this is a preview of the navigation slides (shown after clicking a screenshot):

![Integration Testing Navigation Slides](https://raw.githubusercontent.com/the-mac/integration_test_preview/main/media/integration_test_6.png)

There are keyboard hotkeys for the navigation slides:
- ← Moves to previous screenshot
- → Moves to next screenshot
- ↑ Moves to previous device (screenshot row)
- → Moves to next device (screenshot row)

Note: The navigation slides circularly cycle, so on the first screenshot ← goes to the last screenshot.

## Additional information

### Alternatively, you can run the example
The [example project](https://github.com/the-mac/integration_test_preview/tree/main/example) has 5 screens that have grouped integration tests:

- [Hello, Flutter](https://github.com/the-mac/integration_test_preview/blob/3eedfecec4b43fc1c453838c1fe7591da87afac1/example/integration_test/app_feature_groups.dart#L139)
- [Hello, Languages](https://github.com/the-mac/integration_test_preview/blob/3eedfecec4b43fc1c453838c1fe7591da87afac1/example/integration_test/app_feature_groups.dart#L146)
- [Counter Sample](https://github.com/the-mac/integration_test_preview/blob/3eedfecec4b43fc1c453838c1fe7591da87afac1/example/integration_test/app_feature_groups.dart#L169)
- [Mobile Community](https://github.com/the-mac/integration_test_preview/blob/3eedfecec4b43fc1c453838c1fe7591da87afac1/example/integration_test/app_feature_groups.dart#L192)
- [Preferences](https://github.com/the-mac/integration_test_preview/blob/3eedfecec4b43fc1c453838c1fe7591da87afac1/example/integration_test/app_feature_groups.dart#L230)

### Package Support
To support this repo, take a look at the [SUPPORT.md](https://github.com/the-mac/integration_test_preview/blob/main/SUPPORT.md) file.

### Package Documentation
To view the documentation on the package, [follow this link](https://pub.dev/documentation/integration_test_preview/latest/integration_test_preview/integration_test_preview-library.html)
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_preview_community/device_preview_community.dart';
import 'package:integration_test_helper/integration_test_helper.dart';
import 'package:provider/provider.dart';

import 'integration_test_binding.dart';

/// Integration Test Preview has pre-configured methods that allow for faster test 
/// deployment for end to end (e2e) test coverage (using Android and iOS platform UIs).
///  This package is based upon the IntegrationTestHelper and sublasses [BaseIntegrationTest]
///  as well as [DevicePreview] packages, and does much more with the combination of the two of them. 
/// 
/// It also allows for specific device size preview screenshots for the app stores, generated 
/// locally in your project path; In addition to easily comparable responsive screenshots. 
/// 
/// When running a test using a IntegrationTestPreview subclass, you can assign the devices 
/// that you want to test against (and take screenshots for) using the initializeDevices method.
/// 
abstract class IntegrationTestPreview extends BaseIntegrationTest {

  late bool _shouldShowToolbar = false;

  late bool _shouldNotShowFrame = false;

  late bool _testCompleted = false;

  final List<DeviceInfo> _testOrder = [];

  final DeviceInfo _emptyDevice = Devices.android.largeTablet.copyWith(name: 'No Device');

  late ScreenshotState _screenshotState = ScreenshotState.NONE;

  final IntegrationTestPreviewBinding binding;

  IntegrationTestPreview(this.binding) : super(binding);

  Future<void> testDeviceEndToEnd(DeviceInfo device);

  Future<void> toggleDeviceUI(DeviceInfo device);

  /// Getting a Build Context involves returning the element for the MaterialApp, CupertinoApp or a child of either.
  Future<BuildContext> getBuildContext();

  @override Future<bool> isPlatformAndroid() {
    
    if (_testOrder.isNotEmpty) {
      final device = _testOrder[0];
      final platformType = device.identifier.platform;
      return Future.value(platformType == TargetPlatform.android);
    }

    return Future.value(defaultTargetPlatform == TargetPlatform.android);

  }

  Future<void> initializeDevices(Set<DeviceInfo> testDevices, {bool showToolbar = false, bool hideFrame = false, ScreenshotState state = ScreenshotState.NONE}) async {
    
    _shouldShowToolbar = showToolbar;
    _shouldNotShowFrame = hideFrame;
    _screenshotState = state;
    _testOrder.clear();
    
    final localTestDevices = testDevices.toList();
    localTestDevices.sort((leftDevice, rightDevice) {
      final leftDeviceWidth = leftDevice.screenSize.width;
      final rightDeviceWidth = rightDevice.screenSize.width;
      return leftDeviceWidth < rightDeviceWidth ? 1 : -1;
    });
    _testOrder.addAll(localTestDevices);

  }
  
  @override
  Future<void> initializeTests(WidgetTester tester, Widget main, {int waitForMilliseconds = 450}) async {
        
        assert(_testOrder.isNotEmpty, 'There needs to be at least one device to test');

        this.tester = tester;
        setWaitMilliseconds(waitForMilliseconds);
        WidgetsApp.debugAllowBannerOverride = false;

        await tester.pumpWidget(DevicePreview(
            enabled: true,
            defaultDevice: _testOrder[0],
            isToolbarVisible: _shouldShowToolbar,
            tools: const [],
            builder: (context) => main
        )).then((value) async {            
            await setupInitialData();
            await _testDevicesEndToEnd();
        });
        
  }

  Future<void> _testDevicesEndToEnd() async {

    final testOrderLocalCopy = List.from(_testOrder);
    for (int index = 0; index < testOrderLocalCopy.length; index++) {
      await _startTest();
      await testDeviceEndToEnd(testOrderLocalCopy[index]);
      await _selectNextScreenType();
      await _completedTest();
      await waitForUI();
    }
    await waitForUI(durationMultiple: 3);

  }

  @override
  Future<void> takeScreenshot(String filePath) async {  
      if(_screenshotState == ScreenshotState.PREVIEW) {
          await waitForUI();
          final context = await getBuildContext();
          binding.takePreviewScreenshot(context, filePath);
          await waitForUI(durationMultiple: 3);
      } else if(_screenshotState == ScreenshotState.RESPONSIVE) {
          await waitForUI();
          binding.takeScreenshot(filePath);
          await waitForUI();
      }
  }

  Future<DeviceInfo> _currentScreenOption() async {

    if(await _hasScreenOption()) {
      return _testOrder[0];
    }
    return _emptyDevice;
  }

  Future<bool> _hasScreenOption() async {
    return _testOrder.isNotEmpty;
  }

  Future<DeviceInfo> _nextScreenOption() async {

    if(await _hasScreenOption()) {
      _testOrder.removeAt(0);
    }

    if(await _hasScreenOption()) {
      return _testOrder[0];
    }

    return _emptyDevice;

  }

  Future<void> _validatePlatformType() async {

    if (! await _hasScreenOption()) return;

    final device = _testOrder[0];
    
    final isPlatformTypeAndroid = await isPlatformAndroid();
    final isPlatformTypeIOS = !isPlatformTypeAndroid;

    final isDevicePlatformAndroid = device.identifier.platform == TargetPlatform.android;
    final isDevicePlatformIOS = device.identifier.platform == TargetPlatform.iOS;

    final platformTypeIOS = isPlatformTypeIOS && isDevicePlatformIOS;
    final platformTypeAndroid = isPlatformTypeAndroid && isDevicePlatformAndroid;

    assert(platformTypeIOS || platformTypeAndroid, 'The platform types do not match. Set the correct app type (Material/Cupertino) for your device (${device.identifier})');

  }

  Future<void> _updateDevice() async {

    if (! await _hasScreenOption()) return;

    final device = _testOrder[0];
  
    await toggleDeviceUI(device);

    WidgetsBinding.instance!.reassembleApplication();
    await _validatePlatformType();

    await waitForUI().then((value) async {
      DevicePreview.selectDevice(await getBuildContext(), device.identifier);
    });

  }

  Future<void> _setPreviewState() async {

    final context = await getBuildContext();
    DevicePreviewStore state = Provider.of<DevicePreviewStore>(context, listen: false);
    state.settings = state.settings.copyWith(
        backgroundTheme: DevicePreviewBackgroundThemeData.dark,
    );
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    state.notifyListeners();

  }

  Future<void> _selectNextScreenType() async {

    final device = await _nextScreenOption();

    if (! await _hasScreenOption()) return;

    await _updateDevice();

  }

  Future<void> _resetTestEnvironment() async {
    if (await _hasScreenOption()) {
      if (_shouldNotShowFrame &&
          await verifyTextForKey('frame-state', 'Visible',
              shouldThrowError: false)) {
        // await tapWidget('Frame visibility');
      }

      final device = await _currentScreenOption();
      final platformType = device.identifier.platform;

      if (defaultTargetPlatform != platformType) {
        await _updateDevice();
        await _setPreviewState();
        await waitForUI();
      }

      await waitForUI();
    }
  }

  Future<void> _validateLastTestCompleted() async {
    if (!_testCompleted) {
      await _resetTestEnvironment();
    }
  }

  Future<void> _startTest() async {
    await _validateLastTestCompleted();
    _testCompleted = false;
  }

  Future<void> _completedTest() async {
    _testCompleted = true;
  }

}

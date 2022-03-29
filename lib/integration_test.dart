import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_preview_community/device_preview_community.dart';
import 'package:device_preview_community/src/views/tool_panel/sections/subsections/device_model.dart';
import 'package:integration_test_helper/integration_test_helper.dart';

import 'integration_test_binding.dart';

abstract class IntegrationTestPreview extends BaseIntegrationTest {

  late bool _shouldNotShowFrame = true;

  late bool _testCompleted = false;

  final List<DeviceInfo> _testOrder = [];

  final DeviceInfo _emptyDevice = Devices.android.bigPhone.copyWith(name: 'No Device');

  late ScreenshotState _screenshotState = ScreenshotState.NONE;

  final IntegrationTestPreviewBinding binding;

  IntegrationTestPreview(this.binding) : super(binding);

  Future<void> testDeviceEndToEnd(DeviceInfo device);

  Future<void> togglePlatformUI(TargetPlatform platform);

  Future<BuildContext> getBuildContext();

  @override Future<bool> isPlatformAndroid() {
    
    if (_testOrder.isNotEmpty) {
      final device = _testOrder[0];
      final platformType = device.identifier.platform;
      return Future.value(platformType == TargetPlatform.android);
    }

    return Future.value(defaultTargetPlatform == TargetPlatform.android);

  }
  
  @override
  Future<void> initializeTests(WidgetTester tester, Widget main) async {

        this.tester = tester;
        WidgetsApp.debugAllowBannerOverride = false;
        await tester.pumpWidget(DevicePreview(
            enabled: true,
            tools: const [
              ...DevicePreview.defaultTools,
            ],
            builder: (context) => main,
        ));

        await setupInitialData();
        await waitForUI(durationMultiple: 2);

  }

  Future<void> initializeDevices(List<DeviceInfo> testDevices, {bool hideFrame = false, ScreenshotState state = ScreenshotState.NONE}) async {
    _shouldNotShowFrame = hideFrame;
    _screenshotState = state;
    _testOrder.clear();
    _testOrder.addAll(testDevices);
  }

  Future<void> testDevicesEndToEnd() async {
    
    assert(_testOrder.isNotEmpty, 'There needs to be at least one device to test');

    final testOrderLocalCopy = List.from(_testOrder);
    for (int index = 0; index < testOrderLocalCopy.length; index++) {
      await _startTest();
      await _togglePlatform();
      await testDeviceEndToEnd(testOrderLocalCopy[index]);
      await _selectNextScreenType();
      await _completedTest();
      await waitForUI();
    }
    await waitForUI(durationMultiple: 3);
  }

  Future<void> takeScreenshot(String filePath) async {      
      await waitForUI();
      if(_screenshotState == ScreenshotState.PREVIEW) {
          final context = await getBuildContext();
          binding.takePreviewScreenshot(context, filePath);
          await waitForUI(durationMultiple: 3);
      } else if(_screenshotState == ScreenshotState.RESPONSIVE) {
          binding.takeScreenshot(filePath);
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

  Future<void> _selectNextScreenType() async {

    final device = await _nextScreenOption();

    if (! await _hasScreenOption()) return;

    final platformType = device.identifier.platform;

    await tapForKey('model');

    if (TargetPlatform.android == platformType) {
      await tapWidget('android');
    } else if (TargetPlatform.iOS == platformType) {
      await tapWidget('iOS');
    }

    var newScreenName = device.name;
    await scrollToListItemText('DeviceListView', newScreenName);

    await tapWidget(newScreenName);

    var popoverClose = find.byTooltip('Back');
    await tester.tap(popoverClose);
    await waitForUI();

  }

  Future<void> _togglePlatform() async {
    if (! await _hasScreenOption()) return;

    final device = _testOrder[0];
    final platformType = device.identifier.platform;
    await togglePlatformUI(platformType);

  }

  Future<void> _resetTestEnvironment() async {
    if (await _hasScreenOption()) {
      if (_shouldNotShowFrame &&
          await verifyTextForKey('frame-state', 'Visible',
              shouldThrowError: false)) {
        await tapWidget('Frame visibility');
      }

      final device = await _currentScreenOption();
      final platformType = device.identifier.platform;

      await tapForKey('model');

      if (platformType == TargetPlatform.iOS) {
        await tapWidget('iOS');
      } else {
        await tapWidget('android');
      }

      if (defaultTargetPlatform != platformType) {
        await _togglePlatform();
        await waitForUI();
      }

      var newScreenName = device.name;

      await scrollToListItemText('DeviceListView', newScreenName);
      await tapWidget(newScreenName);

      var popoverClose = find.byTooltip('Back');
      await tester.tap(popoverClose);
      await waitForUI();
    }
  }

  Future<void> _validateLastTestCompleted() async {
    if (!_testCompleted) {
      await _resetTestEnvironment();
      // if (driver != null) await driver.close();
      // driver = null;
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

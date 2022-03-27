import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_driver/flutter_driver.dart';

import 'dart:io';
import 'dart:ui';
import 'package:integration_test/common.dart';
import 'package:integration_test/src/channel.dart';
import 'package:flutter/services.dart';
import 'package:integration_test/_callback_io.dart';


enum ScreenshotState { NONE, PREVIEW, RESPONSIVE }


class IntegrationTestPreviewBinding extends IntegrationTestWidgetsFlutterBinding {
  
  /// Similar to [WidgetsFlutterBinding.ensureInitialized].
  ///
  /// Returns an instance of the [IntegrationTestWidgetsFlutterBinding], creating and
  /// initializing it if necessary.
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      IntegrationTestPreviewBinding();
    }
    assert(WidgetsBinding.instance is IntegrationTestPreviewBinding);
    return WidgetsBinding.instance!;
  }

  @override
  Future<void> convertFlutterSurfaceToImage() async {
    try {
      await super.convertFlutterSurfaceToImage();
    } on AssertionError catch (_) {}
  }

  /// Takes a screenshot including the Device Preview panel.
  ///
  /// On Android, you need to call `convertFlutterSurfaceToImage()`, and
  /// pump a frame before taking a screenshot.
  @override
  Future<List<int>> takeScreenshot(String screenshotName) async {
    await convertFlutterSurfaceToImage();
    return super.takeScreenshot(screenshotName);
  }

  /// Takes a preview screenshot.
  Future<List<int>> takePreviewScreenshot(BuildContext context, String screenshotName) async {

    reportData ??= <String, dynamic>{};
    reportData!['screenshots'] ??= <dynamic>[];
    final screenshot = await DevicePreview.screenshot(context);
    final Map<String, dynamic> data = {};
    data['bytes'] = screenshot.bytes;
    data['screenshotName'] = screenshotName;
    assert(data.containsKey('bytes'));

    (reportData!['screenshots']! as List<dynamic>).add(data);

    return data['bytes']! as List<int>;

  }
}

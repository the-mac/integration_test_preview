import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_preview/device_preview.dart';


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

  /// Takes a preview screenshot using DevicePreview.screenshot(context).
  Future<List<int>> takePreviewScreenshot(BuildContext context, String screenshotName) async {

    final Map<String, dynamic> data = {};
    reportData ??= <String, dynamic>{};
    reportData!['screenshots'] ??= <dynamic>[];

    final screenshot = await DevicePreview.screenshot(context);
    data['bytes'] = screenshot.bytes;
    data['screenshotName'] = screenshotName;

    assert(data.containsKey('bytes'));
    (reportData!['screenshots']! as List<dynamic>).add(data);
    return data['bytes']! as List<int>;

  }
}

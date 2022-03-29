import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_preview_community/device_preview_community.dart';
import 'package:integration_test_helper/integration_test_helper.dart';


enum ScreenshotState { NONE, PREVIEW, RESPONSIVE }


class IntegrationTestPreviewBinding extends IntegrationTestHelperBinding {
  
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

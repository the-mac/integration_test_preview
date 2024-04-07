import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_preview/device_preview.dart';
import 'package:integration_test_helper/integration_test_helper.dart';


// ignore: constant_identifier_names
enum ScreenshotState { NONE, PREVIEW, RESPONSIVE }

/// A subclass of [IntegrationTestHelperBinding] that reports tests results
/// on a channel to adapt them to native instrumentation test format.
class IntegrationTestPreviewBinding extends IntegrationTestHelperBinding {
  
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The singleton instance of this object.
  ///
  /// Provides access to the features exposed by this class. The binding must
  /// be initialized before using this getter; this is typically done by calling
  /// [IntegrationTestWidgetsFlutterBinding.ensureInitialized].
  static IntegrationTestPreviewBinding get instance => BindingBase.checkInstance(_instance);
  static IntegrationTestPreviewBinding? _instance;

  /// Returns an instance of the [IntegrationTestWidgetsFlutterBinding], creating and
  /// initializing it if necessary.
  ///
  /// See also:
  ///
  ///  * [WidgetsFlutterBinding.ensureInitialized], the equivalent in the widgets framework.
  static IntegrationTestPreviewBinding ensureInitialized() {
    if (_instance == null) {
      IntegrationTestPreviewBinding();
    }
    return _instance!;
  }

  /// Similar to [WidgetsFlutterBinding.ensureInitialized].
  ///
  /// Returns an instance of the [IntegrationTestWidgetsFlutterBinding], creating and
  /// initializing it if necessary.
  // static WidgetsBinding ensureInitialized() {
  //   if (WidgetsBinding.instance == null) {
  //     IntegrationTestPreviewBinding();
  //   }
  //   assert(WidgetsBinding.instance is IntegrationTestPreviewBinding);
  //   return WidgetsBinding.instance!;
  // }

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

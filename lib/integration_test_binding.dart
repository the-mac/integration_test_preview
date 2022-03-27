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

// class PreviewCallbackManager extends IOCallbackManager {
//   Future<Map<String, dynamic>> takePreviewScreenshot(
//       String screenshot, List<int> rawBytes) async {
//     integrationTestChannel.setMethodCallHandler(_onMethodChannelCall);
//     return <String, dynamic>{
//       'screenshotName': screenshot,
//       'bytes': rawBytes,
//     };
//   }

//   @override
//   Future<Map<String, dynamic>> callback(
//       Map<String, String> params, IntegrationTestResults testRunner) async {
//     final String command = params['command']!;
//     Map<String, String> response;
//     switch (command) {
//       case 'request_data':
//         final bool allTestsPassed = await testRunner.allTestsPassed.future;
//         response = <String, String>{
//           'message': allTestsPassed
//               ? Response.allTestsPassed(data: testRunner.reportData).toJson()
//               : Response.someTestsFailed(
//                   testRunner.failureMethodsDetails,
//                   data: testRunner.reportData,
//                 ).toJson(),
//         };
//         break;
//       case 'get_health':
//         response = <String, String>{'status': 'ok'};
//         break;
//       default:
//         throw UnimplementedError('$command is not implemented');
//     }
//     return <String, dynamic>{
//       'isError': false,
//       'response': response,
//     };
//   }

//   @override
//   void cleanup() {
//     // no-op.
//     // Add any IO platform specific Completer/Future cleanups to here if any
//     // comes up in the future. For example: `WebCallbackManager.cleanup`.
//   }

//   // [convertFlutterSurfaceToImage] has been called and [takeScreenshot] is ready to capture the surface (Android only).
//   bool _isSurfaceRendered = false;

//   @override
//   Future<void> convertFlutterSurfaceToImage() async {
//     if (!Platform.isAndroid) {
//       // No-op on other platforms.
//       return;
//     }
//     assert(!_isSurfaceRendered, 'Surface already converted to an image');
//     await integrationTestChannel.invokeMethod<void>(
//       'convertFlutterSurfaceToImage',
//       null,
//     );
//     _isSurfaceRendered = true;

//     addTearDown(() async {
//       assert(_isSurfaceRendered, 'Surface is not an image');
//       await integrationTestChannel.invokeMethod<void>(
//         'revertFlutterImage',
//         null,
//       );
//       _isSurfaceRendered = false;
//     });
//   }

//   @override
//   Future<Map<String, dynamic>> takeScreenshot(String screenshot) async {
//     if (Platform.isAndroid && !_isSurfaceRendered) {
//       throw StateError(
//           'Call convertFlutterSurfaceToImage() before taking a screenshot');
//     }
//     integrationTestChannel.setMethodCallHandler(_onMethodChannelCall);
//     final List<int>? rawBytes =
//         await integrationTestChannel.invokeMethod<List<int>>(
//       'captureScreenshot',
//       <String, dynamic>{'name': screenshot},
//     );
//     if (rawBytes == null) {
//       throw StateError(
//           'Expected a list of bytes, but instead captureScreenshot returned null');
//     }
//     return <String, dynamic>{
//       'screenshotName': screenshot,
//       'bytes': rawBytes,
//     };
//   }

//   Future<dynamic> _onMethodChannelCall(MethodCall call) async {
//     switch (call.method) {
//       case 'scheduleFrame':
//         window.scheduleFrame();
//         break;
//     }
//     return null;
//   }
// }

class IntegrationTestPreviewBinding extends IntegrationTestWidgetsFlutterBinding {
  int gcCount = 0;

  // @override
  // PreviewCallbackManager get callbackManager => _singletonCallbackManager;

  // /// IOCallbackManager singleton.
  // final PreviewCallbackManager _singletonCallbackManager =
  //     PreviewCallbackManager();

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
    // final FlutterDriver driver = await FlutterDriver.connect();

    // if (++gcCount % 3 == 0) {
    //   print('Pre screenshot Garbage Collection count: $gcCount');
    //   await driver.forceGC();
    //   await delayed(const Duration(milliseconds: 1500));
    // }

    reportData ??= <String, dynamic>{};
    reportData!['screenshots'] ??= <dynamic>[];
    final screenshot = await DevicePreview.screenshot(context);
    final Map<String, dynamic> data = {};
    data['bytes'] = screenshot.bytes;
    data['screenshotName'] = screenshotName;
    assert(data.containsKey('bytes'));

    (reportData!['screenshots']! as List<dynamic>).add(data);

    return data['bytes']! as List<int>;

    // reportData ??= <String, dynamic>{};
    // reportData!['web_driver_command'] = '${WebDriverCommandType.screenshot}';
    // reportData!['screenshots'] ??= <dynamic>[];
    // final screenshot = await DevicePreview.screenshot(context);
    // final Map<String, dynamic> data = {};
    // data['bytes'] = screenshot.bytes;
    // data['screenshotName'] = screenshotName;
    // assert(data.containsKey('bytes'));
    // // driver.sendCommand(command);

    // (reportData!['screenshots']! as List<dynamic>).add(data);
    // // callbackManager.callback(params, testRunner);
    // // integrationTestChannel.setMethodCallHandler(_onMethodChannelCall);
    // return data['bytes']! as List<int>;

    // reportData ??= <String, dynamic>{};
    // reportData!['screenshots'] ??= <dynamic>[];
    // final screenshot = await DevicePreview.screenshot(context);
    // // final Map<String, dynamic> data = await callbackManager.takePreviewScreenshot(screenshotName, screenshot.bytes);
    // // callbackManager.cleanup();
    // assert(data.containsKey('bytes'));

    // (reportData!['screenshots']! as List<dynamic>).add(data);
    // return data['bytes']! as List<int>;
  }
}

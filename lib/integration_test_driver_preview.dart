// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a CLI library; we use prints as part of the interface.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

import 'package:integration_test/common.dart';

void called(dynamic methodName) {
  print('\n\n==================== Called $methodName ====================\n\n');
}

void show(String key, Object object, { bool showLog = true }) {
  if(showLog) {
    if(object is Map) {
      showMap(key, object);
    } else if(object is List) {
      showList(key, object);
    } else {
      print('\n\n$key: $object\n\n');
    }
  }
}

void showMap(String key, Map jsonObject, { bool showLog = true }) {
  var encoder = const JsonEncoder.withIndent('  ');
  if(jsonObject is Map<String, File> && showLog) {
    for (var fileEntry in jsonObject.entries) {
      var requestFile = jsonObject[fileEntry.key];
      print('\n\n${fileEntry.key}: $requestFile\n\n');
    }
  } else if(showLog) {
    print('\n\n$key: ${encoder.convert(jsonObject)}\n\n');

  }
}
void showList(String key, List jsonArray, { bool showLog = true }) {
  var encoder = const JsonEncoder.withIndent('  ');
  if(showLog) print('\n\n$key: ${encoder.convert(jsonArray)}\n\n');
}

/// Adaptor to run an integration test using `flutter drive`.
///
/// To an integration test `<test_name>.dart` using `flutter drive`, put a file named
/// `<test_name>_test.dart` in the app's `test_driver` directory:
///
/// ```dart
/// import 'dart:async';
///
/// import 'package:integration_test/integration_test_driver_extended.dart';
///
/// Future<void> main() async {
///   final FlutterDriver driver = await FlutterDriver.connect();
///   await integrationDriver(
///     driver: driver,
///     onScreenshot: (String screenshotName, List<int> screenshotBytes) async {
///       return true;
///     },
///   );
/// }
/// ```
///
/// ## Parameters:
///
/// `driver` A custom driver. Defaults to `FlutterDriver.connect()`.
///
/// `onScreenshot` can be used to process the screenshots taken during the test.
/// An example could be that this callback compares the byte array against a baseline image,
/// and it returns `true` if both images are equal.
///
/// As a result, returning `false` from `onScreenshot` will make the test fail.
Future<void> integrationDriver(
    {FlutterDriver? driver, ScreenshotCallback? onScreenshot}) async {
      print('=== Called integrationDriver ===');
  driver ??= await FlutterDriver.connect();
  // Test states that it's waiting on web driver commands.
  // [DriverTestMessage] is converted to string since json format causes an
  // error if it's used as a message for requestData.
  String jsonResponse = await driver.requestData(DriverTestMessage.pending().toString());

  Response response = Response.fromJson(jsonResponse);

  // Until `integration_test` returns a [WebDriverCommandType.noop], keep
  // executing WebDriver commands.
  while (response.data != null &&
      response.data!['web_driver_command'] != null &&
      response.data!['web_driver_command'] != '${WebDriverCommandType.noop}') {

    final String? webDriverCommand = response.data!['web_driver_command'] as String?;
    show('webDriverCommand', webDriverCommand ?? 'No command passed');

    // if (webDriverCommand == '${WebDriverCommandType.screenshot}' && response.data != null && response.data!['screenshots'] != null && onScreenshot != null) {

    //   final List<dynamic> screenshots = response.data!['screenshots'] as List<dynamic>;
    //   final List<String> failures = <String>[];
    //   for (final dynamic screenshot in screenshots) {
    //     final Map<String, dynamic> data = screenshot as Map<String, dynamic>;
    //     final List<dynamic> screenshotBytes = data['bytes'] as List<dynamic>;
    //     final String screenshotName = data['screenshotName'] as String;
    //     show('screenshotName', screenshotName);

    //     bool ok = false;
    //     try {
    //       ok = await onScreenshot(screenshotName, screenshotBytes.cast<int>());
    //     } catch (exception) {
    //       throw StateError(
    //         'Screenshot failure:\n'
    //         'onScreenshot("$screenshotName", <bytes>) threw an exception: $exception',
    //       );
    //     }
    //     if (!ok) {
    //       failures.add(screenshotName);
    //     }
    //   }
    //   if (failures.isNotEmpty) {
    //     throw StateError(
    //         'The following screenshot tests failed: ${failures.join(', ')}');
    //   }
    // } else 
    if (webDriverCommand == '${WebDriverCommandType.screenshot}') {
      assert(onScreenshot != null,
          'screenshot command requires an onScreenshot callback');
      // Use `driver.screenshot()` method to get a screenshot of the web page.
      final List<int> screenshotImage = await driver.screenshot();
      final String screenshotName =
          response.data!['screenshot_name']! as String;

      final bool screenshotSuccess =
          await onScreenshot!(screenshotName, screenshotImage);
      if (screenshotSuccess) {
        jsonResponse =
            await driver.requestData(DriverTestMessage.complete().toString());
      } else {
        jsonResponse =
            await driver.requestData(DriverTestMessage.error().toString());
      }

      response = Response.fromJson(jsonResponse);
    } else if (webDriverCommand == '${WebDriverCommandType.ack}') {
      // Previous command completed ask for a new one.
      jsonResponse =
          await driver.requestData(DriverTestMessage.pending().toString());

      response = Response.fromJson(jsonResponse);
    } else {
      break;
    }
  }

  // If No-op command is sent, ask for the result of all tests.
  if (response.data != null &&
      response.data!['web_driver_command'] != null &&
      response.data!['web_driver_command'] == '${WebDriverCommandType.noop}') {
    jsonResponse = await driver.requestData(null);

    response = Response.fromJson(jsonResponse);
    print('result $jsonResponse');
  }

  if (response.data != null &&
      response.data!['screenshots'] != null &&
      onScreenshot != null) {
    final List<dynamic> screenshots =
        response.data!['screenshots'] as List<dynamic>;
    final List<String> failures = <String>[];
    for (final dynamic screenshot in screenshots) {
      final Map<String, dynamic> data = screenshot as Map<String, dynamic>;
      final List<dynamic> screenshotBytes = data['bytes'] as List<dynamic>;
      final String screenshotName = data['screenshotName'] as String;
      show('screenshotName', screenshotName);

      bool ok = false;
      try {
        ok = await onScreenshot(screenshotName, screenshotBytes.cast<int>());
      } catch (exception) {
        throw StateError(
          'Screenshot failure:\n'
          'onScreenshot("$screenshotName", <bytes>) threw an exception: $exception',
        );
      }
      if (!ok) {
        failures.add(screenshotName);
      }
    }
    if (failures.isNotEmpty) {
      throw StateError(
          'The following screenshot tests failed: ${failures.join(', ')}');
    }
  }

  await driver.close();

  if (response.allTestsPassed) {
    print('All tests passed.');
    exit(0);
  } else {
    print('Failure Details:\n${response.formattedFailureDetails}');
    exit(1);
  }
}

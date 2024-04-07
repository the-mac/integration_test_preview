// ignore_for_file: avoid_print

import 'dart:io';
import 'package:integration_test_preview/integration_test_driver.dart';

Future<void> main() => integrationDriver(
    clearScreenshots: true, onScreenshot: (String screenshotPath, List<int> screenshotBytes, [Map<String, Object?>? args]) async {
        
        final File image = File(screenshotPath);
        print(image);

        final dir = image.parent;
        if(!await dir.exists()) await dir.create(recursive: true);

        image.writeAsBytesSync(screenshotBytes);
        
        return true;

    }
);
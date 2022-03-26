
// clear && printf '\e[3J' && flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart ; flutter clean

// clear && printf '\e[3J' && flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

import 'package:device_frame/src/devices/devices.dart';
import 'package:device_frame/src/info/info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_preview/integration_test_binding.dart';

import 'package:example/main.dart' as app;
import 'app_test_groups.dart';

void main() async {

    final binding = IntegrationTestPreviewBinding.ensureInitialized();

    testWidgets('Testing end to end multi-screen integration', (WidgetTester tester) async {
      
          final main = app.setupMainWidget();
          final List<DeviceInfo> testDevices = [
            Devices.ios.iPhone12,
            Devices.android.samsungGalaxyNote20
          ];
          
          final integrationTestGroups = ScreenIntegrationTestGroups(binding);
          await integrationTestGroups.initializeDevices(testDevices, state: ScreenshotState.PREVIEW);
          await integrationTestGroups.initializeTests(tester, main);
          await integrationTestGroups.testDevicesEndToEnd();

      }, timeout: const Timeout(Duration(minutes: 3))
    );
    
}

// ignore_for_file: avoid_print
import 'package:device_frame_community/src/info/info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_preview/integration_test_preview.dart';
import 'package:responsive_widgets_prefix/responsive_widgets_prefix.dart';

import 'package:example/the_mac.dart';
import 'package:example/platforms.dart';
import 'package:example/preferences.dart';

class ScreenIntegrationTestGroups extends IntegrationTestPreview {

    late DeviceInfo currentDevice;

    late Map _languagesTestData;

    ScreenIntegrationTestGroups(binding) : super(binding);

    @override
    Future<void> setupInitialData() async {

        _languagesTestData = await loadFixtureJSON('assets/fixtures/languages.json') as Map;

        if (_languagesTestData.isEmpty) {
            throw 'No languages test data found';
        }

    }

    @override
    Future<BuildContext> getBuildContext() async {
        if(await isPlatformAndroid()) {
          final elementType = find.byType(ResponsiveMaterialApp);
          return tester.element(elementType);
        } else {
          final elementType = find.byType(ResponsiveCupertinoApp);
          return tester.element(elementType);
        }
    }
    
    @override
    Future<void> toggleDeviceUI(DeviceInfo device) async {
        ScreenType screenType = ResponsiveHelper.setupScreenType(device.screenSize.width);
        PlatformWidget.setPlatform(device.identifier.platform, screenType);
    }
    
    @override
    Future<void> testDeviceEndToEnd(DeviceInfo device) async {

        currentDevice = device;
        await waitForUI(durationMultiple: 2);
        await testHelloFlutterFeature();
        await testLanguagesFeature();
        await testCounterFeature();
        await testSocialFeature();
        await testPreferencesFeature();

    }

    Future<void> validateTestDataAt(int itemIndex, { required String widgetSuffix, required String jsonKey }) async {
        var languageData = _languagesTestData['results'][itemIndex] as Map;
        var itemText = languageData[jsonKey] as String;
        await verifyListExactText(itemIndex, widgetPrefix: 'item', widgetSuffix: widgetSuffix, expectedText: itemText);
    }

    Future<void> verifyAppBarText(String appBarText) async {
        if(PlatformWidget.isAndroid) {
            await verifyTextForKey('app-bar-text', appBarText);
        }
        await waitForUI();
    }

    Future<void> showHelloFlutter() async {
        print('Showing Hello, Flutter!');
        if(PlatformWidget.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-hello');
        } else {
            await tapWidget('Hello');
        }
        await waitForUI();
    }

    Future<void> showLanguagesList() async {
        print('Showing Languages');
        if(PlatformWidget.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-languages');
        } else {
            await tapWidget('Languages');
        }
        await waitForUI();
    }

    Future<void> showCounterSample() async {
        print('Showing Counter Sample');
        if(PlatformWidget.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-counter');
        } else {
            await tapWidget('Counter Sample');
        }
        await waitForUI();
    }

    Future<void> showTheMACSocials() async {
        print('Showing Mobile Community');
        if(PlatformWidget.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-community');
        } else {
            await tapWidget('Mobile Community');
        }
        await waitForUI();
    }

    Future<void> showPreferences() async {
        print('Showing Preferences');
        if(PlatformWidget.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-preferences');
        } else {
            await tapWidget('Preferences');
        }
        await waitForUI();
    }

    Future<void> tapPreference(int number) async {
      await tapForKey('preference-$number');
    }

    Future<void> setupScreenshot(String fileName, DeviceInfo device) async {
        await waitForUI(durationMultiple: 30);
        String platformType = PlatformWidget.isAndroid ? 'android' : 'ios';
        String devicePath = device.identifier.name.replaceAll('-', '_');
        String screenshotPath = 'screenshots/$platformType/$devicePath/$fileName.png';
        print('Setting up screenshot: $screenshotPath');
        await takeScreenshot(screenshotPath);
        await waitForUI(durationMultiple: 15);
    }

    Future<void> testHelloFlutterFeature() async {
        await showHelloFlutter();
        await verifyAppBarText('Hello');
        await verifyTextForKey('hello-page-text', 'Hello, Flutter!');
        await setupScreenshot('1_hello_flutter', currentDevice);
    }

    Future<void> testLanguagesFeature() async {
        
        // VIEW LANGUAGES PAGE
        await showLanguagesList();
        await verifyAppBarText('Languages');
        await setupScreenshot('2_languages_0_list', currentDevice);

        await validateTestDataAt(0, widgetSuffix: 'name', jsonKey: 'name');
        await validateTestDataAt(1, widgetSuffix: 'name', jsonKey: 'name');

        // VIEW LANGUAGE PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 0);
        await verifyExactText('Python');
        await setupScreenshot('2_languages_1_python', currentDevice);
        await tapBackArrow();

        // VIEW LANGUAGE PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 1);
        await verifyExactText('Java');
        await tapBackArrow();  

    }

    Future<void> testCounterFeature() async {

        await showCounterSample();
        await verifyAppBarText('Counter Sample');
        await setupScreenshot('3_counter_sample_0', currentDevice);

        await verifyTextForKey('counter-page-text', '0');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '1');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '2');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '3');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '4');
        await setupScreenshot('3_counter_sample_4', currentDevice);

    }

    Future<void> testSocialFeature() async {

        await showTheMACSocials();
        await verifyAppBarText('Mobile Community');
        await verifyExactText('Welcome to\nThe Mobile Apps Community!');
        await setupScreenshot('4_mobile_community_0', currentDevice);

        await verifyExactText('View Integration Test Helper');
        await tapWidget('View Integration Test Helper');
        await waitForUI(durationMultiple: 15);

        final launchResultsHasShareURL = launchResults.containsKey(TheMACPage.shareURL);
        final pubDevLaunchSuccessful = launchResultsHasShareURL && launchResults[TheMACPage.shareURL];
        assert(pubDevLaunchSuccessful);
        
        await setupScreenshot('4_mobile_community_1_facebook', currentDevice);
        await tapBackArrow();

        await verifyExactText('Check out our Facebook');
        await tapWidget('Check out our Facebook');
        await waitForUI(durationMultiple: 15);

        final launchResultsHasFacebookURL = launchResults.containsKey(TheMACPage.facebookURL);
        final facebookLaunchSuccessful = launchResultsHasFacebookURL && launchResults[TheMACPage.facebookURL];
        assert(facebookLaunchSuccessful);

        await setupScreenshot('4_mobile_community_2_facebook', currentDevice);
        await tapBackArrow();

        await verifyExactText('Check out our Github');
        await tapWidget('Check out our Github');
        await waitForUI(durationMultiple: 15);

        final launchResultsHasGithubURL = launchResults.containsKey(TheMACPage.githubURL);
        final githubLaunchSuccessful = launchResultsHasGithubURL && launchResults[TheMACPage.githubURL];
        assert(githubLaunchSuccessful);
        
        await setupScreenshot('4_mobile_community_3_github', currentDevice);
        await tapBackArrow();

    }

    Future<void> testPreferencesFeature() async {

        // SHOW SETTINGS PAGE
        await showPreferences();
        await verifyAppBarText('Preferences');
        await setupScreenshot('5_preferences_0_start', currentDevice);
        
        await verifyExactText('Notifications for new packages');
        assert(!Prefs.getBool('preference-0'));

        await tapPreference(0);
        assert(Prefs.getBool('preference-0'));

        await verifyExactText('Github Pull Requests updates');
        assert(!Prefs.getBool('preference-1'));

        await tapPreference(1);
        assert(Prefs.getBool('preference-1'));

        await showCounterSample();
        await showPreferences();

        assert(Prefs.getBool('preference-0'));
        assert(Prefs.getBool('preference-1'));

        await verifyExactText('Send Mobile Community updates');
        assert(!Prefs.getBool('preference-2'));
        
        await tapPreference(2);
        assert(Prefs.getBool('preference-2'));

        await tapPreference(2);
        assert(!Prefs.getBool('preference-2'));
        await setupScreenshot('5_preferences_1_end', currentDevice);

    }

}

// ignore_for_file: avoid_print
import 'package:device_frame_community/src/info/info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_preview/integration_test_preview.dart';

import 'package:example/the_mac.dart';
import 'package:example/platforms.dart';
import 'package:example/preferences.dart';

class ScreenIntegrationTestGroups extends IntegrationTestPreview {

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
          final elementType = find.byType(MaterialApp);
          return tester.element(elementType);
        } else {
          final elementType = find.byType(CupertinoApp);
          return tester.element(elementType);
        }
    }

    @override
    Future<void> togglePlatformUI(TargetPlatform platform) async {
        PlatformWidget.setPlatform(platform);
        PlatformWidget.reassembleApplication();
        await waitForUI(durationMultiple: 2);
    }
    
    @override
    Future<void> testDeviceEndToEnd(DeviceInfo device) async {

        await waitForUI(durationMultiple: 2);
        await testHelloFlutterFeature();
        await testLanguagesFeature();
        await testCounterFeature();
        // await testSocialFeature();
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

    Future<void> setupScreenshot(String fileName) async {
        String platformType = PlatformWidget.isAndroid ? 'android' : 'ios';
        String screenshotPath = 'screenshots/$platformType/$fileName.png';
        print('Setting up screenshot: $screenshotPath');
        await takeScreenshot(screenshotPath);
    }

    Future<void> testHelloFlutterFeature() async {
        await showHelloFlutter();
        await verifyAppBarText('Hello');
        await verifyTextForKey('hello-page-text', 'Hello, Flutter!');
        await setupScreenshot('hello_flutter');
    }

    Future<void> testLanguagesFeature() async {
        
        // VIEW LANGUAGES PAGE
        await showLanguagesList();
        await verifyAppBarText('Languages');
        await setupScreenshot('languages_list');

        await validateTestDataAt(0, widgetSuffix: 'name', jsonKey: 'name');
        await validateTestDataAt(1, widgetSuffix: 'name', jsonKey: 'name');

        // VIEW LANGUAGE PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 0);
        await verifyExactText('Python');
        await setupScreenshot('language_python');
        await tapBackArrow();

        // VIEW LANGUAGE PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 1);
        await verifyExactText('Java');
        await tapBackArrow();  

    }

    Future<void> testCounterFeature() async {

        await showCounterSample();
        await verifyAppBarText('Counter Sample');
        await setupScreenshot('counter_sample');

        await verifyTextForKey('counter-page-text', '0');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '1');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '2');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '3');
        await tapForTooltip('Increment');

        await verifyTextForKey('counter-page-text', '4');
        await setupScreenshot('counter_sample_4');

    }

    Future<void> testSocialFeature() async {

        await showTheMACSocials();
        await verifyAppBarText('Mobile Community');
        await verifyExactText('Welcome to\nThe Mobile Apps Community!');
        await setupScreenshot('mobile_community');

        await verifyExactText('View Integration Test Helper');
        await tapWidget('View Integration Test Helper');
        await waitForUI(durationMultiple: 3);
        await tapBackArrow();

        final launchResultsHasShareURL = launchResults.containsKey(TheMACPage.shareURL);
        final pubDevLaunchSuccessful = launchResultsHasShareURL && launchResults[TheMACPage.shareURL];
        assert(pubDevLaunchSuccessful);

        await verifyExactText('Check out our Facebook');
        await tapWidget('Check out our Facebook');
        await waitForUI(durationMultiple: 3);
        await setupScreenshot('mobile_community_facebook');
        await tapBackArrow();

        final launchResultsHasFacebookURL = launchResults.containsKey(TheMACPage.facebookURL);
        final facebookLaunchSuccessful = launchResultsHasFacebookURL && launchResults[TheMACPage.facebookURL];
        assert(facebookLaunchSuccessful);

        await verifyExactText('Check out our Github');
        await tapWidget('Check out our Github');
        await waitForUI(durationMultiple: 3);
        await setupScreenshot('mobile_community_github');
        await tapBackArrow();

        final launchResultsHasGithubURL = launchResults.containsKey(TheMACPage.githubURL);
        final githubLaunchSuccessful = launchResultsHasGithubURL && launchResults[TheMACPage.githubURL];
        assert(githubLaunchSuccessful);

    }

    Future<void> testPreferencesFeature() async {

        // SHOW SETTINGS PAGE
        await showPreferences();
        await verifyAppBarText('Preferences');
        await setupScreenshot('preferences_start');
        
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
        await setupScreenshot('preferences_end');

    }

}
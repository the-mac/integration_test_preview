
// ignore_for_file: avoid_print
import 'package:intl/intl.dart' as intl;
import 'package:device_frame_community/src/info/info.dart';
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
        await testHelloFlutterFeature();
        await testLanguagesFeature();
        await testCounterFeature();
        await testSocialFeature();
        await testFormWidgetsFeature();

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
            await tapWidget('Counter');
        }
        await waitForUI();
    }

    Future<void> showTheMACSocials() async {
        print('Showing Mobile Community');
        if(PlatformWidget.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-community');
        } else {
            await tapWidget('Community');
        }
        await waitForUI();
    }

    Future<void> showFormInputs() async {
        print('Showing Form Inputs');
        if (PlatformWidget.isAndroid) {
            await tapForTooltip('Open navigation menu');
            await tapForKey('drawer-forms');
        } else {
            await tapWidget('Form Inputs');
        }
        await waitForUI();
    }

    Future<void> tapPreference(int number) async {
      await tapForKey('preference-$number');
    }

    Future<DateTime> changeDate(DateTime start, int daysDelta) async {

        await waitForUI();

        DateTime end;
        if (daysDelta > 0) {
          end = start.add(Duration(days: daysDelta));
        } else {
          end = start.subtract(Duration(days: daysDelta.abs()));
        }

        final dateSlug =
            intl.DateFormat.yMd().format(end).toLowerCase().replaceAll('/', '_');

        final startingFormat = intl.DateFormat.yMd().format(start);
        await verifyExactText(startingFormat);

        await tapWidget('Edit');
        await setupScreenshot('form_widgets_3_${dateSlug}_initial', currentDevice);

        await selectPlatformDate(start, end);
        await setupScreenshot('form_widgets_3_${dateSlug}_update', currentDevice);
        await waitForUI(durationMultiple: 3);

        final endingFormat = intl.DateFormat.yMd().format(end);
        await verifyExactText(endingFormat);

        return end;
    }

    Future<void> validateCheckboxState(bool expectedState) async {
        final widgetFinder = find.byKey(const Key('form-checkbox'));
        await tester.tap(widgetFinder);
        await waitForUI();

        final widget = tester.firstWidget(widgetFinder);
        final Checkbox checkboxWidget = widget as Checkbox;

        await waitForUI(durationMultiple: 2);
        expect(checkboxWidget.value, expectedState);
    }

    Future<void> validateSwitchState(bool expectedState) async {
        final widgetFinder = find.byKey(const Key('form-switch'));
        await tester.tap(widgetFinder);
        await waitForUI();

        final widget = tester.firstWidget(widgetFinder);
        final Switch switchWidget = widget as Switch;

        await waitForUI(durationMultiple: 2);
        expect(switchWidget.value, expectedState);
    }

    Future<void> setupScreenshot(String fileName, DeviceInfo device) async {
        await waitForUI(durationMultiple: 5);
        String platformType = PlatformWidget.isAndroid ? 'android' : 'ios';
        String devicePath = device.identifier.name.replaceAll('-', '_');
        String screenshotPath = 'screenshots/$platformType/$devicePath/$fileName.png';
        print('Setting up screenshot: $screenshotPath');
        await takeScreenshot(screenshotPath);
        await waitForUI(durationMultiple: 5);
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
        await setupScreenshot('3_counter_sample_0', currentDevice);
        await verifyAppBarText('Counter');

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
        await verifyAppBarText('Community');
        await verifyExactText('Welcome to\nThe Mobile Apps Community!');
        await setupScreenshot('4_mobile_community_0', currentDevice);

        await verifyExactText('View Integration Test Helper');
        await tapWidget('View Integration Test Helper');
        await waitForUI(durationMultiple: 25);

        final launchResultsHasShareURL = launchResults.containsKey(TheMACPage.shareURL);
        final pubDevLaunchSuccessful = launchResultsHasShareURL && launchResults[TheMACPage.shareURL];
        assert(pubDevLaunchSuccessful);
        
        await setupScreenshot('4_mobile_community_1_facebook', currentDevice);
        await tapBackArrow();

        await verifyExactText('Check out our Facebook');
        await tapWidget('Check out our Facebook');
        await waitForUI(durationMultiple: 25);

        final launchResultsHasFacebookURL = launchResults.containsKey(TheMACPage.facebookURL);
        final facebookLaunchSuccessful = launchResultsHasFacebookURL && launchResults[TheMACPage.facebookURL];
        assert(facebookLaunchSuccessful);

        await setupScreenshot('4_mobile_community_2_facebook', currentDevice);
        await tapBackArrow();

        await verifyExactText('Check out our Github');
        await tapWidget('Check out our Github');
        await waitForUI(durationMultiple: 25);

        final launchResultsHasGithubURL = launchResults.containsKey(TheMACPage.githubURL);
        final githubLaunchSuccessful = launchResultsHasGithubURL && launchResults[TheMACPage.githubURL];
        assert(githubLaunchSuccessful);
        
        await setupScreenshot('4_mobile_community_3_github', currentDevice);
        await tapBackArrow();

    }

    Future<void> testFormWidgetsFeature() async {

        // VIEW FORMS PAGE
        await showFormInputs();
        await verifyAppBarText('Form Inputs');
        await setupScreenshot('form_widgets_0', currentDevice);

        // VIEW SIGN IN PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 0);
        await setupScreenshot('form_widgets_1_sign_in_0', currentDevice);

        await waitForUI();
        await tapWidget('Sign in');
        await setupScreenshot('form_widgets_1_sign_in_1', currentDevice);
        await verifyExactText('Unable to sign in.');
        await tapWidget('OK');

        await waitForUI();
        await tapWidget('Forgot Password');
        await setupScreenshot('form_widgets_1_sign_in_2a', currentDevice);
        await verifyExactText(
            'To verify that this is your email address, select the location to send your verification code.');
        await tapForKey('dialog-radio-1');
        await setupScreenshot('form_widgets_1_sign_in_2b', currentDevice);
        await tapWidget('Send Code');

        await waitForUI();
        await enterText('input-email', 'email@gmail.com');
        await enterText('input-password', 'emailP@s5');
        await setupScreenshot('form_widgets_1_sign_in_3', currentDevice);

        await waitForUI();
        await tapWidget('Sign in');
        await setupScreenshot('form_widgets_1_sign_in_4', currentDevice);
        await verifyExactText('Successfully signed in.');
        await tapWidget('OK');
        await tapBackArrow();

        // VIEW FORM WIDGETS PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 1);
        await setupScreenshot('form_widgets_2', currentDevice);

        await waitForUI();
        final startingDate = DateTime(2022, 4, 15);
        final newDate = await changeDate(startingDate, 300);
        await changeDate(newDate, -250);

        await waitForUI();
        await verifyExactText('\$0');
        await setupScreenshot('form_widgets_4', currentDevice);
        await changeSliderForKey('form-slider', percentage: 0.50);
        await setupScreenshot('form_widgets_5', currentDevice);
        await verifyExactText('\$250');

        await waitForUI();
        await validateCheckboxState(true);
        await setupScreenshot('form_widgets_6', currentDevice);
        await validateCheckboxState(false);
        await setupScreenshot('form_widgets_7', currentDevice);

        await waitForUI();
        await validateSwitchState(true);
        await setupScreenshot('form_widgets_8', currentDevice);

        // VERIFY ALL INPUT DATA IN DIALOG
        await tapWidget('Submit');
        await setupScreenshot('form_widgets_9', currentDevice);
        await waitForUI();

        await verifyTextForKey('dialog-date', 'Date: 6/4/2022');
        await verifyTextForKey('dialog-dollars', 'Dollars: \$250.00');
        await verifyTextForKey('dialog-fb-notifications', 'Facebook Notifications: false');
        await verifyTextForKey('dialog-gh-notifications', 'Github Notifications: true');
        await tapWidget('OK');
        await tapBackArrow();

        // SHOW PREFERENCES PAGE
        await tapListItem(widgetPrefix: 'item', itemIndex: 2);
        await setupScreenshot('form_widgets_10', currentDevice);

        await verifyExactText('Notifications for new packages');
        assert(!Prefs.getBool('preference-0'));

        await tapPreference(0);
        assert(Prefs.getBool('preference-0'));

        await verifyExactText('Github Pull Requests updates');
        assert(!Prefs.getBool('preference-1'));

        await tapPreference(1);
        assert(Prefs.getBool('preference-1'));

        await verifyExactText('Send Mobile Community updates');
        assert(!Prefs.getBool('preference-2'));

        await tapPreference(2);
        assert(Prefs.getBool('preference-2'));

        await tapPreference(2);
        assert(!Prefs.getBool('preference-2'));
        await setupScreenshot('form_widgets_11', currentDevice);

        await tapBackArrow();
        await showHelloFlutter();
    }

}
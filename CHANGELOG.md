## 0.1.1

* Added Form Widgets Feature
* Added Form Widgets Test Group
* Added Generation of Device Previews Webpage
* Added auto-deletion of screenshots
* Added Custom integrationDriver
* Upgrade of Integration Test Helper (0.0.9)

## 0.1.0

* Adding waitForUI call after binding.takePreviewScreenshot
* Adding waitForUI call after binding.takeScreenshot
* Adding default waitForMilliseconds = 550 to initializeTests arguments
* Upgrade of Integration Test Helper (0.0.7)
* Breaking change: initializeDevices now accepts unordered Set<DeviceInfo>
* Updated README directions
* Added Platform Type validation
* Shortened _setPreviewState time
* Increased example setupScreenshot wait to 30 times
* Increased example minutesPerDevice to 4

## 0.0.5

* Adding responsive_widgets_prefix to example 
* Updating screenshots for README
* Adding assertion that the platform types match
* Adding call to DevicePreview.selectDevice(...)
* Adding call to WidgetsBinding.instance!.reassembleApplication()
* Defaulting to no Device Preview Toolbar
* Breaking change "Refactored testDevicesEndToEnd to private"
* Breaking change "Replacing togglePlatformUI \w toggleDeviceUI"

## 0.0.4

* Upgrade of Integration Test Helper (0.0.6)

## 0.0.3

* Upgrade of Integration Test Helper (0.0.5)
* Added Responsive Widgets Prefix to example (0.0.2)

## 0.0.2

* Upgrade of Integration Test Helper (0.0.4)
* Upgrade to subclass of IntegrationTestHelperBinding
* Added super() call for BaseIntegrationTest(binding)

## 0.0.1

* Initial release.

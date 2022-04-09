
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_widgets_prefix/responsive_helper.dart';


class PlatformApp extends PlatformWidget {

  PlatformApp({
    Key? key,
    required MaterialApp androidApp,
    required CupertinoApp iosApp,
    required TargetPlatform defaultPlatform,
    required ScreenType defaultScreenType,
  }) : super(key: key,
      androidBuilder: (BuildContext context) => androidApp,
      iosBuilder:  (BuildContext context) => iosApp
    ) {
      PlatformWidget.setPlatform(defaultPlatform, defaultScreenType);
  }

}

class PlatformWidget extends StatefulWidget {
  
  static TargetPlatform? _currentPlatform;

  static get platform {
      if(_currentPlatform == null) {
        return TargetPlatform.android;
      }
      return _currentPlatform;
  }

  static get screenType {
      if(ResponsiveHelper.testingScreenType == ScreenType.None) {
        return ScreenType.MediumPhone;
      }
      return ResponsiveHelper.testingScreenType;
  }

  static get isAndroid {
      return _currentPlatform == TargetPlatform.android;
  }

  static get isIOS {
      return _currentPlatform == TargetPlatform.iOS;
  }

  static void setPlatform(TargetPlatform platform, ScreenType screenType) {
      _currentPlatform = platform;
      ResponsiveHelper.testingScreenType = screenType;
      ResponsiveHelper.updateTestingScreenType();
  }

  const PlatformWidget({
    Key? key,
    required this.androidBuilder,
    required this.iosBuilder,
  }) : super(key: key);

  final WidgetBuilder androidBuilder;
  final WidgetBuilder iosBuilder;

  @override
  State<PlatformWidget> createState() => _PlatformWidgetState();
}

class _PlatformWidgetState extends State<PlatformWidget> {
  @override
  Widget build(context) {
    switch (PlatformWidget._currentPlatform) {
      case TargetPlatform.android:
        return widget.androidBuilder(context);
      case TargetPlatform.iOS:      
        return widget.iosBuilder(context);        
      default:
        assert(false, 'Unexpected platform ${PlatformWidget._currentPlatform}');
        return Container();
    }
  }
}
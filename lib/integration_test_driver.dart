// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:async';
import "package:collection/collection.dart";
import 'package:integration_test/common.dart';
import 'package:flutter_driver/flutter_driver.dart';

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
    {required bool clearScreenshots,
    String screenshotsPath = 'screenshots',
    FlutterDriver? driver,
    ScreenshotCallback? onScreenshot}) async {
    print('Called integrationDriver');

  if(clearScreenshots) {

      final screenshotsDir = Directory(screenshotsPath);
      if(screenshotsDir.existsSync()) {
          screenshotsDir.deleteSync(recursive: true);
      }

  }

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

    if (webDriverCommand == '${WebDriverCommandType.screenshot}') {
      assert(onScreenshot != null, 'screenshot command requires an onScreenshot callback');
      // Use `driver.screenshot()` method to get a screenshot of the web page.
      final String screenshotName = response.data!['screenshot_name']! as String;
      final List<int> screenshotImage = await driver.screenshot();

      final bool screenshotSuccess = await onScreenshot!(screenshotName, screenshotImage);
      if (screenshotSuccess) {
        jsonResponse = await driver.requestData(DriverTestMessage.complete().toString());
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

  if (response.data != null && response.data!['screenshots'] != null && onScreenshot != null) {
    final List<dynamic> screenshots = response.data!['screenshots'] as List<dynamic>;
    final List<String> failures = <String>[];
    final List<String> previewDevicePaths = [];

    for (final dynamic screenshot in screenshots) {
      final Map<String, dynamic> data = screenshot as Map<String, dynamic>;
      final List<dynamic> screenshotBytes = data['bytes'] as List<dynamic>;
      final String screenshotName = data['screenshotName'] as String;

      bool ok = false;
      try {

        ok = await onScreenshot(screenshotName, screenshotBytes.cast<int>());
        final File image = File(screenshotName);
        previewDevicePaths.add(image.path.toString());

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

    Previews.generateDevicePreviews(
      filePath: 'screenshots.html',
      previewDevicePaths: previewDevicePaths
    );

    if (failures.isNotEmpty) {
     throw StateError('The following screenshot tests failed: ${failures.join(', ')}');
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

/// [Previews] is the class in charge of actually generating the HTML previews.
class Previews {

// https://github.com/jorgecoca/ozzie.flutter/blob/master/lib/html_report.dart
/// Beginning of the generated HTML report.
/// It includes the declaration of the <head> plus the <header> of the report.
static const beginningOfDevicePreviews = """
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="300">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="Integration Test Preview">
  <title>Integration Test Preview</title>
  <style>
    body {
      margin: 0;
      background-color: black;
      font-family: Arial;
      color: whitesmoke;
      scrollbar-width: none; /* for Firefox */
      -ms-overflow-style: none; /* for Internet Explorer, Edge */
      overflow-y: scroll; 
    }

    #previewModal.modal::-webkit-scrollbar,
    body::-webkit-scrollbar {
      display: none;        /* for Chrome, Safari, and Opera */
      width: 0px;           /* width of the entire scrollbar */
    }

    * {
        box-sizing: border-box;
    }

    .row>.column {
        padding: 0 8px;
    }

    .row:after {
        content: "";
        display: table;
        clear: both;
    }

    .column {
        float: left;
        width: 16.5%;
    }

    /* The Modal (background) */
    .modal {
        display: none;
        position: fixed;
        z-index: 1;
        padding-top: 10px;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: black;
    }

    /* Modal Content */
    .modal-content {
        position: relative;
        background-color: #fefefe;
        margin: auto;
        padding: 0;
        width: 40%;
        max-width: 800px;
    }

    /* The Close Button */
    .close {
        color: white;
        position: absolute;
        top: 10px;
        right: 25px;
        font-size: 35px;
        font-weight: bold;
    }

    .close:hover,
    .close:focus {
        color: #999;
        text-decoration: none;
        cursor: pointer;
    }

    .previewSlides {
        display: none;
    }

    .cursor {
        cursor: pointer;
    }

    /* Next & previous buttons */
    .prev,
    .next{
        cursor: pointer;
        position: absolute;
        top: 50%;
        width: auto;
        padding: 16px;
        margin-top: -50px;
        color: #888;
        font-weight: bold;
        font-size: 20px;
        transition: 0.6s ease;
        border-radius: 0 3px 3px 0;
        user-select: none;
        -webkit-user-select: none;
    }

    /* Above & Below buttons */
    .above,
    .below {
        cursor: pointer;
        position: absolute;
        left: 50%;
        height: auto;
        padding: 16px;
        margin-left: -20px;
        color: #888;
        font-weight: bold;
        font-size: 20px;
        transition: 0.6s ease;
        border-radius: 0 3px 3px 0;
        user-select: none;
        -webkit-user-select: none;
    }

    /* Position the "next button" to the right */
    .next {
        right: 0;
        border-radius: 3px 0 0 3px;
    }

    /* Position the "next button" to the right */
    .above {
        top: 0;
        transform: rotate(90deg);
        margin-top: -8px;
        border-radius: 3px 0 0 3px;
    }

    /* Position the "next button" to the right */
    .below {
        bottom: 0;
        transform: rotate(90deg);
        margin-bottom: 40px;
        border-radius: 3px 0 0 3px;
    }

    /* On hover, add a black background color with a little bit see-through */
    .prev:hover,
    .next:hover,
    .above:hover,
    .below:hover {
        background-color: rgba(0, 0, 0, 0.8);
    }

    /* Number text (1/3 etc) */
    .numbertext {
        color: #f2f2f2;
        font-size: 12px;
        padding: 8px 12px;
        position: absolute;
        top: 0;
    }

    img {
        margin-bottom: -4px;
    }

    .caption-container {
        text-align: center;
        background-color: black;
        padding: 2px 16px;
        color: white;
    }

    .preview {
        opacity: 0.6;
    }

    .active,
    .preview:hover {
        opacity: 1;
    }

    img.hover-shadow {
        transition: 0.3s;
    }

    .hover-shadow:hover {
        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
    }
  </style>
  <script>

      document.onkeydown = checkKey;
      function checkKey(e) {
          e = e || window.event;

          if (e.keyCode == '38') {
              plusRow(-1);// up arrow
          } else if (e.keyCode == '40') {
              plusRow(1);// down arrow
          } else if (e.keyCode == '37') {
              plusSlides(-1);// left arrow
          } else if (e.keyCode == '39') {
              plusSlides(1);// right arrow
          } else if (e.keyCode == '27') {
              closeModal();// escape key
          }
      }

      function openModalForRow(row) {
          slideRow = row;
          document.getElementById("previewModal").style.display = "block";
      }

      function closeModal() {
          document.getElementById("previewModal").style.display = "none";
      }

      function plusSlides(n) {
          showSlidesFromRow(slideRow, slideIndex += n);
      }

      function plusRow(n) {
          showSlidesFromRow(slideRow += n, slideIndex);
      }

      function currentSlide(n) {
          showSlidesFromRow(slideRow, slideIndex = n);
          console.log('After slideIndex: ' + slideIndex);
      }

      function showSlidesFromRow(r, n) {
          var i;
          var slides = document.getElementsByClassName("previewSlides");
          var previews = document.getElementsByClassName("preview");
          var captionText = document.getElementById("caption");
          
          console.log('rowCount: ' + rowCount);
          console.log('Before slideRow: ' + slideRow);
          if (r >= rowCount) { slideRow = 0; }
          if (r < 0) { slideRow = rowCount - 1; }
          console.log('After slideRow: ' + slideRow);
          
          if (n > slides.length) { slideIndex = 1; }
          if (n < 1) { slideIndex = slides.length; }
          
          for (i = 0; i < slides.length; i++) {
              slides[i].style.display = "none";
          }
          for (i = 0; i < previews.length; i++) {
              
              var img = document.querySelector("#row"+slideRow+" > div:nth-child(" +(i + 1) +") > div > img");
              document.querySelector("#previewModal > div > div:nth-child(" +(i + 1) +") > img").src = img.src
              
              previews[i].src = img.src;
              previews[i].className = previews[i].className.replace(" active", "");
              
          }

          slides[slideIndex - 1].style.display = "block";
          previews[slideIndex - 1].className += " active";
          
          var rowName = document.getElementById("row"+slideRow).title;
          captionText.innerHTML = rowName + ' ( ' + previews[slideIndex - 1].alt+ ' )';
      }

  </script>
</head>
<body>
    <div class="album py-5">
      <div class="container">
        <div class="row">
""";

/// Ending of the generated HTML report.
/// It includes the <footer> and the setup for the different JS libraries used.
 static const endingOfDevicePreviews = '''
</div>
      </div>
    </div>
  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"
    crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"
    crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"
    crossorigin="anonymous"></script>
</body>
</html>
''';
  /// This method is what generates the HTML report with the given
  /// `rootFolderName`.
  /// It should only be called after all the screnshots have been taken,
  /// so the reporter can inspect the given `rootFolderName` and generate
  /// the proper HTML code. That's why, calling this method from
  /// `Previews.generateDevicePreviews` is ideal.
  /// The `groupName` is necessary to generate the ZIP files included in
  /// the HTML report.
  static void generateDevicePreviews({
    required String filePath,
    required List<String> previewDevicePaths
  }) async {

    String previewDevicesModal = '';
    String previewDeviceRows = '';
    final previewDeviceGroups = _groupImages(previewDevicePaths);
    final rowCount = previewDeviceGroups.length;
    final previewGroupsKeys = previewDeviceGroups.keys.toList();

    previewDeviceGroups.forEach((group, list) {

        if(previewDeviceRows.isEmpty) {
            final rowName = _capitilize(group.replaceAll("_", " "));
            previewDevicesModal = _buildSlideshow(
              list, rowCount: rowCount, modalId: 'previewModal', modalName: rowName,
            );
        }
        final rowIndex = previewGroupsKeys.indexOf(group);
        final rowName = _capitilize(group.replaceAll("_", " ")).replaceAll("Ip", "iP");
        final row = _buildImageRow(rowIndex, rowName, list);
        previewDeviceRows += row;
    });
    final imageGallery = _buildDevicePreviews(previewDeviceRows);
    String htmlContent =
        '$beginningOfDevicePreviews$previewDevicesModal$imageGallery$endingOfDevicePreviews';

    final file = File(filePath);
    file.writeAsStringSync(htmlContent);
    print('Device Previews: ' + file.absolute.path);

  }

  static Map<String, List<String>> _groupImages(List<String> images) {
    
    Map<String, List<String>> groups = {};

    for (int index = 0; index < images.length; index++) {
        final imagePath = images[index];

        final group = imagePath.split("/")[2];
        final hasKey = groups.containsKey(group);
        final isNotFilled = hasKey;// && groups[group]!.length < 16;

        if(isNotFilled) {
            groups[group]!.add(imagePath);
        } else if(!hasKey) {
            groups[group] = [];
            groups[group]!.add(imagePath);
        }
    }

    return groups;

  }
  static String _capitilize(String str) {
      return str.toLowerCase().split(' ').map((word) {
        String leftText = (word.length > 1) ? word.substring(1, word.length) : '';
        return word[0].toUpperCase() + leftText;
      }).join(' ');
  }

  static String _buildImageRow(int rowID, String rowName, List<String> images) {
    var imageCardsBuffer = StringBuffer();
    images.forEachIndexed((index, imagePath) {
      final position = index + 1;
      imageCardsBuffer.write("""
<div class="column col-md-2">
  <div class="mb-2 shadow-sm">
    <img class="card-img-top" style="width: 100%; display: block;" src="./$imagePath" onclick="openModalForRow($rowID); currentSlide($position);" data-holder-rendered="true">
    <div card="card-body">
    </div>
  </div>
</div>
      """);
    });
    final imageCards = imageCardsBuffer.toString();
    return '<div title="$rowName" id="row$rowID" class="row">$imageCards</div>';
  }

  static String _buildDevicePreviews(String previewDevices) {
    String accordionId = '1234';
    String performanceDeviceSnippet = '';
    return _buildScreenshotsAndPerformanceTabs(accordionId, previewDevices, performanceDeviceSnippet);
  }

  static String _buildScreenshotsAndPerformanceTabs(String accordionId,
      String screenshotsDeviceSnippet, String performanceDeviceSnippet) {
    return """
<div class="tab-content" id="nav-tabContent">
    <p>
      $screenshotsDeviceSnippet
    </p>
</div>
    """;
  }

  static String _buildCarousel(List<String> images) {
    final buffer = StringBuffer();
    for (var index = 0; index < images.length; index++) {
      final position = index + 1;
        buffer.write("""
            <div class="column">
                <img class="preview cursor" src="./${images[index]}" style="width:100%" onclick="currentSlide($position)"
                    alt="${images[index]}">
            </div>
        """);
    }
    return buffer.toString();
  }

  static String _buildSlides(List<String> images) {
    final buffer = StringBuffer();
    for (var index = 0; index < images.length; index++) {
      final position = index + 1;
        buffer.write("""
            <div class="previewSlides">
                <div class="numbertext">$position / ${images.length}</div>
                <img src="./${images[index]}" style="width:100%">
            </div>
        """);
    }
    return buffer.toString();
  }

  static String _buildSlideshow(
    List<String> images, {
    required int rowCount,
    required String modalId,
    required String modalName,
  }) {
    return """

    <div id="previewModal" class="modal">
        <span class="close cursor" onclick="closeModal()">&times;</span>
        <div class="modal-content">

            ${_buildSlides(images)}
            
            <a class="prev" onclick="plusSlides(-1)" title="Keyboard Left">&#10094;</a>
            <a class="above" onclick="plusRow(-1)" title="Keyboard Up">&#10094;</a>
            <a class="next" onclick="plusSlides(1)" title="Keyboard Right">&#10095;</a>
            <a class="below" onclick="plusRow(1)" title="Keyboard Down">&#10095;</a>

            <div class="caption-container">
                <p id="caption"></p>
            </div>

            ${_buildCarousel(images)}

        </div>
    </div>
<script type="text/javascript">

    var slideRow = 0;
    var slideIndex = 1;
    var rowCount = $rowCount;
      
    document.onload = function () {
      showSlidesFromRow(slideRow, slideIndex);
    };

  </script>
           """;
  }

}
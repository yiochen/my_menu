import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() {
  return integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      final Directory directory = Directory('../../docs/screenshots');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final File file = File('${directory.path}/$screenshotName.png');
      await file.writeAsBytes(screenshotBytes, flush: true);
      return true;
    },
  );
}

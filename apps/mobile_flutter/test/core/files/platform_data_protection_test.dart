import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android excludes app data from backup and device transfer', () {
    final String manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final String cloudRules =
        File('android/app/src/main/res/xml/backup_rules.xml')
            .readAsStringSync();
    final String extractionRules = File(
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
    for (final String domain in <String>[
      'root',
      'file',
      'database',
      'sharedpref',
      'external',
    ]) {
      expect(cloudRules, contains('domain="$domain"'));
      expect(extractionRules, contains('domain="$domain"'));
    }
  });

  test('iOS applies complete protection and backup exclusion before startup',
      () {
    final String delegate =
        File('ios/Runner/AppDelegate.swift').readAsStringSync();
    final String bootstrap = File('lib/app/bootstrap.dart').readAsStringSync();

    expect(delegate, contains('isExcludedFromBackupKey'));
    expect(delegate, contains('FileProtectionType.complete'));
    expect(delegate, contains('hardenLocalMenuStorage'));
    expect(bootstrap, contains('PlatformDataProtection.harden()'));
    expect(
      bootstrap.indexOf('PlatformDataProtection.harden()'),
      lessThan(bootstrap.indexOf('Supabase.initialize')),
    );
  });
}

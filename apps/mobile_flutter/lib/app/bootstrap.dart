import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:mymenu/core/debug/shared_preferences_debug_controls.dart';
import 'package:mymenu/core/network/processing_api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  DebugControlsBootstrap? debugControlsBootstrap;
  if (kDebugMode) {
    final SharedPreferencesDebugControls controls =
        await SharedPreferencesDebugControls.load();
    debugControlsBootstrap = DebugControlsBootstrap(
      settings: controls.settings,
      persistence: controls,
    );
  }
  if (ProcessingApiConfig.shouldUseSupabase) {
    await Supabase.initialize(
      url: ProcessingApiConfig.url,
      publishableKey: ProcessingApiConfig.anonKey,
    );
  }
  runApp(MyMenuApp(debugControlsBootstrap: debugControlsBootstrap));
}

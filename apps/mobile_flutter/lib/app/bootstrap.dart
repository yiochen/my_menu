import 'package:flutter/widgets.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseApiConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseApiConfig.url,
      publishableKey: SupabaseApiConfig.anonKey,
    );
  }
  runApp(const MyMenuApp());
}

part of 'processing_api_client.dart';

class ProcessingApiConfig {
  const ProcessingApiConfig._();

  static const String apiMode = String.fromEnvironment(
    'MY_MENU_API_MODE',
    defaultValue: 'auto',
  );
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static bool get shouldUseSupabase {
    switch (apiMode) {
      case 'auto':
        return isConfigured;
      case 'fake':
        return false;
      case 'supabase':
        if (!isConfigured) {
          throw StateError(
            'MY_MENU_API_MODE=supabase requires SUPABASE_URL and '
            'SUPABASE_ANON_KEY.',
          );
        }
        return true;
      default:
        throw StateError(
          'Unsupported MY_MENU_API_MODE "$apiMode". Use auto, fake, or '
          'supabase.',
        );
    }
  }
}

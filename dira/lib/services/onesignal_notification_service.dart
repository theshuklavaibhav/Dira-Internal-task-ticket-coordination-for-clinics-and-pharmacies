import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sends push notifications via OneSignal's REST API, targeting a specific
/// user by their `external_id` (which we set to their Firebase Auth UID —
/// see OneSignal.login(uid) in main.dart's AuthGate).
class OneSignalPushService {
  static const _appId = 'a0829472-f917-4c4c-90a2-d2a7c975b423';
  static const _restApiKey = String.fromEnvironment('ONESIGNAL_REST_API_KEY');

  static Future<void> sendToUser({
    required String externalUserId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    if (_restApiKey.isEmpty) {
      // ignore: avoid_print
      print('OneSignalPushService: REST API key missing (dart-define not set) — skipping push.');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'include_aliases': {
            'external_id': [externalUserId],
          },
          'target_channel': 'push',
          'headings': {'en': title},
          'contents': {'en': message},
          if (data != null) 'data': data,
        }),
      );
      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('OneSignalPushService: send failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('OneSignalPushService: send error: $e');
    }
  }
}
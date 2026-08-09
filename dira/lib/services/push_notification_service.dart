import 'dart:convert';
import 'package:http/http.dart' as http;

class PushNotificationService {
  static const _workerUrl = String.fromEnvironment('PUSH_WORKER_URL');
  static const _sharedSecret = String.fromEnvironment('PUSH_WORKER_SECRET');

  static Future<void> sendToUser({
    required String externalUserId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    if (_workerUrl.isEmpty || _sharedSecret.isEmpty) {
      // ignore: avoid_print
      print('PushNotificationService: worker env vars missing — skipping push.');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$_workerUrl/send-push'),
        headers: {'Content-Type': 'application/json', 'X-Dira-Secret': _sharedSecret},
        body: jsonEncode({
          'externalUserId': externalUserId,
          'title': title,
          'message': message,
          'data': data ?? {},
        }),
      );
      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('PushNotificationService: send failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('PushNotificationService: send error: $e');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const _serviceId = String.fromEnvironment('EMAILJS_SERVICE_ID');
  static const _templateId = String.fromEnvironment('EMAILJS_TEMPLATE_ID');
  static const _publicKey = String.fromEnvironment('EMAILJS_PUBLIC_KEY');
  static const _apkUrl = 'https://github.com/theshuklavaibhav/Dira-Internal-task-ticket-coordination-for-clinics-and-pharmacies/releases/download/v1.0.3/app-release.apk';

  static Future<void> sendInviteEmail({
    required String toEmail,
    required String clinicName,
    required String role,
    required String inviterName,
  }) async {
    if (_serviceId.isEmpty || _templateId.isEmpty || _publicKey.isEmpty) {
      throw Exception('EmailJS not configured. Pass --dart-define values at run time.');
    }

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {
          'to_email': toEmail,
          'clinic_name': clinicName,
          'role': role,
          'inviter_name': inviterName,
          'apk_url': _apkUrl,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send invite email (${response.statusCode}): ${response.body}');
    }
  }
}
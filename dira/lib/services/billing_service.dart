import 'dart:convert';
import 'package:http/http.dart' as http;

class BillingService {
  static const _workerUrl = String.fromEnvironment('PUSH_WORKER_URL');
  static const _sharedSecret = String.fromEnvironment('PUSH_WORKER_SECRET');

  // static Future<Map<String, dynamic>> createOrder(String clinicId, int amountInPaise) async {
  //   final response = await http.post(
  //     Uri.parse('$_workerUrl/create-order'),
  //     headers: {'Content-Type': 'application/json', 'X-Dira-Secret': _sharedSecret},
  //     body: jsonEncode({'clinicId': clinicId, 'planAmount': amountInPaise}),
  //   );
  //   return jsonDecode(response.body);
  // }

  static Future<Map<String, dynamic>> createOrder(String clinicId, int amountInPaise) async {
  final response = await http.post(
    Uri.parse('$_workerUrl/create-order'),
    headers: {'Content-Type': 'application/json', 'X-Dira-Secret': _sharedSecret},
    body: jsonEncode({'clinicId': clinicId, 'planAmount': amountInPaise}),
  );

  if (response.statusCode != 200) {
    throw Exception('Order creation failed (${response.statusCode}): ${response.body}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (data['orderId'] == null) {
    throw Exception('Order creation failed: ${data['error'] ?? 'unknown error'}');
  }
  return data;
}

  static Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String clinicId,
  }) async {
    final response = await http.post(
      Uri.parse('$_workerUrl/verify-payment'),
      headers: {'Content-Type': 'application/json', 'X-Dira-Secret': _sharedSecret},
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
        'clinicId': clinicId,
      }),
    );
    final data = jsonDecode(response.body);
    return data['verified'] == true;
  }
}
// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../services/billing_service.dart';

// class BillingScreen extends StatefulWidget {
//   final String clinicId;
//   final String clinicName;
//   const BillingScreen({super.key, required this.clinicId, required this.clinicName});

//   @override
//   State<BillingScreen> createState() => _BillingScreenState();
// }

// class _BillingScreenState extends State<BillingScreen> {
//   late final Razorpay _razorpay;
//   bool _isProcessing = false;
//   static const int _monthlyPricePaise = 99900; // ₹999/month — adjust as needed

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   Future<void> _startCheckout() async {
//     setState(() => _isProcessing = true);
//     try {
//       final order = await BillingService.createOrder(widget.clinicId, _monthlyPricePaise);
//       print('DEBUG order response: $order'); 
//       final options = {
//         'key': order['keyId'],
//         'amount': order['amount'],
//         'order_id': order['orderId'],
//         'name': 'Dira',
//         'description': '${widget.clinicName} — Monthly Subscription',
//         'prefill': {},
//       };
//        print('DEBUG checkout options: $options'); // add this line too
//       _razorpay.open(options);
//     } catch (e) {
//       setState(() => _isProcessing = false);
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to start payment: $e'), backgroundColor: Theme.of(context).colorScheme.error),
//       );
//     }
//   }

//   Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
//   final orderId = response.orderId;
//   final paymentId = response.paymentId;
//   final signature = response.signature;

//   if (orderId == null || paymentId == null || signature == null) {
//     setState(() => _isProcessing = false);
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Payment succeeded but confirmation data was incomplete (order: $orderId, payment: $paymentId). Please contact support with this Payment ID if the charge appears on your statement.'),
//         backgroundColor: Theme.of(context).colorScheme.error,
//       ),
//     );
//     return;
//   }

//   final verified = await BillingService.verifyPayment(
//     orderId: orderId,
//     paymentId: paymentId,
//     signature: signature,
//     clinicId: widget.clinicId,
//   );
//   setState(() => _isProcessing = false);
//   if (!mounted) return;
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(verified ? 'Subscription activated!' : 'Payment received but verification failed — contact support.'),
//       backgroundColor: verified ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
//     ),
//   );
//   if (verified && mounted) Navigator.pop(context);
// }

//   // Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
//   //   final verified = await BillingService.verifyPayment(
//   //     orderId: response.orderId!,
//   //     paymentId: response.paymentId!,
//   //     signature: response.signature!,
//   //     clinicId: widget.clinicId,
//   //   );
//   //   setState(() => _isProcessing = false);
//   //   if (!mounted) return;
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Text(verified ? 'Subscription activated!' : 'Payment received but verification failed — contact support.'),
//   //       backgroundColor: verified ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
//   //     ),
//   //   );
//   //   if (verified && mounted) Navigator.pop(context);
//   // }

//   void _onPaymentError(PaymentFailureResponse response) {
//     setState(() => _isProcessing = false);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: Theme.of(context).colorScheme.error),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(title: const Text('Subscription')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Container(
//             padding: const EdgeInsets.all(28),
//             decoration: BoxDecoration(
//               color: scheme.surfaceContainerLowest,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.workspace_premium_outlined, size: 48, color: scheme.primary),
//                 const SizedBox(height: 16),
//                 Text('Upgrade ${widget.clinicName}', style: Theme.of(context).textTheme.headlineSmall),
//                 const SizedBox(height: 8),
//                 Text('₹999/month', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: scheme.primary)),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _isProcessing ? null : _startCheckout,
//                   child: _isProcessing
//                       ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
//                       : const Text('Pay & Activate'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/billing_service.dart';

class BillingScreen extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  const BillingScreen({super.key, required this.clinicId, required this.clinicName});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late final Razorpay _razorpay;
  bool _isProcessing = false;
  static const int _monthlyPricePaise = 99900;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _startCheckout() async {
    setState(() => _isProcessing = true);
    try {
      final order = await BillingService.createOrder(widget.clinicId, _monthlyPricePaise);
      final options = {
        'key': order['keyId'],
        'amount': order['amount'],
        'order_id': order['orderId'],
        'name': 'Dira',
        'description': '${widget.clinicName} — Monthly Subscription',
        'prefill': {},
      };
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start payment: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final verified = await BillingService.verifyPayment(
      orderId: response.orderId!,
      paymentId: response.paymentId!,
      signature: response.signature!,
      clinicId: widget.clinicId,
    );
    setState(() => _isProcessing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(verified ? 'Subscription activated!' : 'Payment received but verification failed — contact support.'),
        backgroundColor: verified ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
      ),
    );
    // No manual Navigator.pop here anymore — the StreamBuilder below will
    // automatically show the "Active" state once Firestore updates.
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('clinics').doc(widget.clinicId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.data();
          final plan = data?['plan'] as String? ?? 'trial';
          final isActive = plan == 'active';
          final expiresAt = (data?['subscriptionExpiresAt'] as Timestamp?)?.toDate();

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? Icons.verified_outlined : Icons.workspace_premium_outlined,
                      size: 48,
                      color: isActive ? scheme.primary : scheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(widget.clinicName, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    if (isActive) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('ACTIVE SUBSCRIPTION',
                            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      if (expiresAt != null) ...[
                        const SizedBox(height: 12),
                        Text('Renews on ${expiresAt.day}/${expiresAt.month}/${expiresAt.year}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ] else ...[
                      Text('₹999/month', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: scheme.primary)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _startCheckout,
                        child: _isProcessing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                            : const Text('Pay & Activate'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
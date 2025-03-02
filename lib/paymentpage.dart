import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'databasepayment.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear all event listeners
    super.dispose();
  }

  void _openCheckout() {
    var options = {
      'key': 'your_razorpay_key', // Replace with your Razorpay key
      'amount': 5000, // 5000 paise = 50 INR
      'name': 'Quick Foodie',
      'description': 'Payment for food order',
      'prefill': {
        'contact': '1234567890',
        'email': 'test@razorpay.com',
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Log successful payment to Firebase Firestore
    _firestore.collection('payments').add({
      'paymentId': response.paymentId,
      'status': 'success',
      'user': _auth.currentUser?.uid,
      'amount': 5000,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Payment successful: ${response.paymentId}"),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Log error to Firebase Firestore
    _firestore.collection('payments').add({
      'code': response.code,
      'message': response.message,
      'status': 'failed',
      'user': _auth.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Payment failed: ${response.message}"),
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Log external wallet use to Firebase Firestore
    _firestore.collection('payments').add({
      'walletName': response.walletName,
      'status': 'external_wallet',
      'user': _auth.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show wallet message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("External Wallet: ${response.walletName}"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Razorpay Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: _openCheckout, // Open Razorpay checkout
          child: Text("Pay with Razorpay"),
        ),
      ),
    );
  }
}

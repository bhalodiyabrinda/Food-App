import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to log a successful payment
  Future<void> logPaymentSuccess(String paymentId, int amount) async {
    try {
      await _firestore.collection('payments').add({
        'paymentId': paymentId,
        'status': 'success',
        'user': _auth.currentUser?.uid,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'code': null,
        'message': null,
      });
    } catch (error) {
      print("Failed to log payment success: $error");
    }
  }

  // Method to log a failed payment
  Future<void> logPaymentFailure(
      String paymentId, int code, String message) async {
    try {
      await _firestore.collection('payments').add({
        'paymentId': paymentId,
        'status': 'failed',
        'user': _auth.currentUser?.uid,
        'amount': null,
        'timestamp': FieldValue.serverTimestamp(),
        'code': code,
        'message': message,
      });
    } catch (error) {
      print("Failed to log payment failure: $error");
    }
  }

  // Method to log external wallet usage
  Future<void> logExternalWallet(String walletName) async {
    try {
      await _firestore.collection('payments').add({
        'walletName': walletName,
        'status': 'external_wallet',
        'user': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      print("Failed to log external wallet usage: $error");
    }
  }
}

import 'package:firebase_database/firebase_database.dart';

class FirebaseTest {
  static Future<void> testConnection() async {
    try {
      final ref = FirebaseDatabase.instance.ref('test');
      await ref.set({'test': 'success', 'timestamp': DateTime.now().toString()});
      print('Firebase connection successful!');
    } catch (e) {
      print('Firebase connection failed: $e');
    }
  }
}
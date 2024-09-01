import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/EncryptionUtils.dart';


class LoginRepository {
  Future<void> signIn(String email, String password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('User signed in: ${userCredential.user?.email}');


      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', EncryptionUtils.encrypt(email));
      await prefs.setString('password', EncryptionUtils.encrypt(password));

    } on FirebaseAuthException catch (e) {

      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
        throw Exception('Wrong password provided.');
      } else {
        print(e.message);
        throw Exception(e.message);
      }
    }
  }
}

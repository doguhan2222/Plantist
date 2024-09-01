import 'package:firebase_auth/firebase_auth.dart';

class SignUpRepository{
  Future<void> signUp(String email,String password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('User signed up: ${userCredential.user?.email}');

    } on FirebaseAuthException catch (e) {

      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print(e.message);
      }
    } catch (e) {
      print(e.toString());
    }
  }

}
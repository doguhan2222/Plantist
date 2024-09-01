import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/EncryptionUtils.dart';
import '../constants/LoginStatus.dart';
import '../repository/LoginRepository.dart';

class LoginViewModel extends GetxController {
  final LoginRepository _signUpRepository = LoginRepository();

  var status = LoginStatus.initial.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    ever(status, (LoginStatus status) {
      if (status == LoginStatus.success) {
        Get.offAllNamed('/home');
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      status(LoginStatus.loading);
      await _signUpRepository.signIn(email, password);
      status(LoginStatus.success);


    } catch (e) {
      status(LoginStatus.failure);
      errorMessage(e.toString());
      print(e.toString());
    }
  }


  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedEmail = prefs.getString('email');
    return encryptedEmail != null ? EncryptionUtils.decrypt(encryptedEmail) : null;
  }

  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedPassword = prefs.getString('password');
    return encryptedPassword != null ? EncryptionUtils.decrypt(encryptedPassword) : null;
  }
}

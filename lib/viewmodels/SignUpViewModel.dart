import 'package:get/get.dart';

import '../constants/SignUpStatus.dart';
import '../repository/SignUpRepository.dart';

class SignUpViewmodel extends GetxController {

  final SignUpRepository _signUpRepository = SignUpRepository();


  var status = SignUpStatus.initial.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    ever(status, (SignUpStatus status) {
      if (status == SignUpStatus.success) {
        Get.offAllNamed('/login');
      }
    });
  }

  Future<void> signUp(String email, String password) async {
    try {
      status(SignUpStatus.loading);
      await _signUpRepository.signUp(email, password);
      status(SignUpStatus.success);
    } catch (e) {
      status(SignUpStatus.failure);
      errorMessage(e.toString());
    }
  }
}

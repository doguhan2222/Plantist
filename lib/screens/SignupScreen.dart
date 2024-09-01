import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/constants/CommonVariables.dart';
import '../constants/SignUpStatus.dart';
import '../constants/Texts.dart';
import '../viewmodels/SignUpViewModel.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

class _SignupScreenState extends State<SignupScreen> {
  final RxBool _isEmailValid = false.obs;
  final RxBool _isPasswordValid = false.obs;
  final SignUpViewmodel _signUpController = Get.put(SignUpViewmodel());

  void _onEmailChanged(bool isValid) {
    _isEmailValid.value = isValid;
  }

  void _onPasswordChanged(bool isValid) {
    _isPasswordValid.value = isValid;
  }

  @override
  Widget build(BuildContext context) {
    CommonVariables.init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            Get.offAllNamed('/');
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: CommonVariables.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: CommonVariables.height * 0.005),
            Text(
              Texts.signUpWithEmail,
              style: TextStyle(
                fontSize: CommonVariables.width * 0.09,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: CommonVariables.height * 0.01),
            Text(
              Texts.enterEmailAndPassword,
              style: TextStyle(
                fontSize: CommonVariables.width * 0.04,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: CommonVariables.height * 0.05),
            EmailField(onChanged: _onEmailChanged),
            SizedBox(height: CommonVariables.height * 0.02),
            PasswordField(onChanged: _onPasswordChanged),
            SizedBox(height: CommonVariables.height * 0.04),
            Obx(() {
              if (_signUpController.status.value == SignUpStatus.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (_signUpController.status.value == SignUpStatus.failure) {
                return Text(
                  'Error: ${_signUpController.errorMessage.value}',
                  style: TextStyle(color: Colors.red),
                );
              } else {
                return Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isEmailValid.value && _isPasswordValid.value)
                          ? () {
                        _signUpController.signUp(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: CommonVariables.height * 0.03),
                        backgroundColor: (_isEmailValid.value && _isPasswordValid.value)
                            ? Colors.indigo[900]
                            : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      child: Text(
                        Texts.signUpButton,
                        style: TextStyle(
                          fontSize: CommonVariables.width * 0.05,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                });
              }
            }),
            Spacer(),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: Texts.agreementPrefix,
                      style: TextStyle(
                        fontSize: CommonVariables.width * 0.035,
                        color: Colors.grey[400],
                      ),
                    ),
                    TextSpan(
                      text: Texts.privacyPolicy,
                      style: TextStyle(
                        fontSize: CommonVariables.width * 0.035,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: Texts.andText,
                      style: TextStyle(
                        fontSize: CommonVariables.width * 0.035,
                        color: Colors.grey[400],
                      ),
                    ),
                    TextSpan(
                      text: Texts.termsOfUse,
                      style: TextStyle(
                        fontSize: CommonVariables.width * 0.035,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class EmailField extends StatefulWidget {
  final void Function(bool isValid) onChanged;

  EmailField({required this.onChanged});

  @override
  _EmailFieldState createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  final RxBool _containsAtSymbol = false.obs;

  void _onChanged(String text) {
    bool isValid = text.contains('@') && text.contains('.');
    widget.onChanged(isValid);
    _containsAtSymbol.value = isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        onChanged: _onChanged,
        decoration: InputDecoration(
          labelText: Texts.emailLabel,
          labelStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          suffixIcon: _containsAtSymbol.value
              ? Icon(
            Icons.check_circle,
            color: Colors.black,
          )
              : null,
        ),
      );
    });
  }
}

class PasswordField extends StatefulWidget {
  final void Function(bool isValid) onChanged;

  PasswordField({required this.onChanged});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _passwordController,
      onChanged: (text) {
        bool isValid = text.isNotEmpty;
        widget.onChanged(isValid);
      },
      decoration: InputDecoration(
        labelText: Texts.passwordLabel,
        labelStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
      ),
    );
  }
}

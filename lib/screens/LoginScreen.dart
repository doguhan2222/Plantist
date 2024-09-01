import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:plantist/constants/CommonVariables.dart';
import 'package:plantist/constants/LoginStatus.dart';
import 'package:plantist/viewmodels/LoginViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/EncryptionUtils.dart';
import '../constants/Texts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final LoginViewModel _loginController = Get.put(LoginViewModel());

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  var _isEmailValid = false.obs;
  var _isPasswordValid = false.obs;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final encryptedEmail = prefs.getString('email');
    final encryptedPassword = prefs.getString('password');

    if (encryptedEmail != null && encryptedPassword != null) {
      try {
        final email = EncryptionUtils.decrypt(encryptedEmail);
        final password = EncryptionUtils.decrypt(encryptedPassword);
        _emailController.text = email;
        _passwordController.text = password;
        _isEmailValid.value = true;
        _isPasswordValid.value = true;
        print('Decrypted Email: $email');
      } catch (e) {
        print('Decryption error: $e');
      }

      // Check biometric authentication support and trigger if supported
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authService.authenticateWithBiometrics(context);
      });
    }
  }

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
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
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
              Texts.signInWithEmail,
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
            SizedBox(height: CommonVariables.height * 0.02),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  Texts.forgotPassword,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: CommonVariables.height * 0.025),
            Obx(() {
              if (_loginController.status.value == LoginStatus.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (_loginController.status.value == LoginStatus.failure) {
                return Text(
                  'Error: ${_loginController.errorMessage.value}',
                  style: TextStyle(color: Colors.red),
                );
              } else {
                return SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: (_isEmailValid.value && _isPasswordValid.value)
                          ? () {
                        _loginController.signIn(_emailController.text, _passwordController.text);
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
                        Texts.signInButton,
                        style: TextStyle(
                          fontSize: CommonVariables.width * 0.05,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }),
                );
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

class EmailField extends StatelessWidget {
  final void Function(bool isValid) onChanged;

  EmailField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    var _containsAtSymbol = false.obs;

    return Obx(() {
      return TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        onChanged: (text) {
          bool isValid = text.contains('@') && text.contains('.');
          onChanged(isValid);
          _containsAtSymbol.value = isValid;
        },
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

class PasswordField extends StatelessWidget {
  final void Function(bool isValid) onChanged;

  PasswordField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    var _obscureText = true.obs;
    var _hasText = false.obs;

    return Obx(() {
      return TextField(
        controller: _passwordController,
        onChanged: (text) {
          bool isValid = text.isNotEmpty;
          onChanged(isValid);
          _hasText.value = isValid;
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
          suffixIcon: _hasText.value
              ? IconButton(
            icon: Icon(
              _obscureText.value ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              _obscureText.value = !_obscureText.value;
            },
          )
              : null,
        ),
        obscureText: _obscureText.value,
      );
    });
  }
}

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> authenticateWithBiometrics(BuildContext context) async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    bool isBiometricSupported = await _localAuth.isDeviceSupported();

    if (canCheckBiometrics && isBiometricSupported) {
      try {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to log in',
        );

        if (authenticated) {
          _loginController.signIn(_emailController.text, _passwordController.text);
        }
      } catch (e) {
        print("Biometric authentication error: $e");
      }
    }
  }
}

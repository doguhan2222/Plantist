import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/constants/CommonVariables.dart';
import '../constants/Texts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  void _onEmailChanged(bool isValid) {
    setState(() {
      _isEmailValid = isValid;
    });
  }

  void _onPasswordChanged(bool isValid) {
    setState(() {
      _isPasswordValid = isValid;
    });
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isEmailValid && _isPasswordValid) ? () {} : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: CommonVariables.height * 0.03),
                  backgroundColor: (_isEmailValid && _isPasswordValid)
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
              ),
            ),
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
  bool _containsAtSymbol = false;

  void _onChanged(String text) {
    bool isValid = text.contains('@') && text.contains('.');
    widget.onChanged(isValid);
    setState(() {
      _containsAtSymbol = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      onChanged: _onChanged,
      decoration: InputDecoration(
        labelText: Texts.emailLabel,
        labelStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none, // Default border is none
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        suffixIcon: _containsAtSymbol
            ? Icon(
          Icons.check_circle,
          color: Colors.black,
        )
            : null,
      ),
    );
  }
}


class PasswordField extends StatefulWidget {
  final void Function(bool isValid) onChanged;

  PasswordField({required this.onChanged});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  bool _hasText = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (text) {
        bool isValid = text.isNotEmpty;
        widget.onChanged(isValid);
        setState(() {
          _hasText = isValid;
        });
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
        suffixIcon: _hasText
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: _togglePasswordVisibility,
        )
            : null,
      ),
      obscureText: _obscureText,
    );
  }
}

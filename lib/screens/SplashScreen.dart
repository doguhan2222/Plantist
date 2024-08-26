import 'package:flutter/material.dart';
import 'package:plantist/constants/CommonVariables.dart';

import '../constants/Texts.dart';


class SplashScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    CommonVariables.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Texts.SPLASH_LOGO_ASSET,
                height: CommonVariables.height*0.4,
              ),
              Column(
                children: [
                  Text(
                    Texts.WELCOME_BACK,
                    style: TextStyle(
                      fontSize: CommonVariables.width * 0.1,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    Texts.PLANTIST,
                    style: TextStyle(
                      fontSize: CommonVariables.width * 0.1,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: CommonVariables.height*0.01),
                  Text(
                    Texts.START_PRODUCTIVE_LIFE,
                    style: TextStyle(
                      fontSize: CommonVariables.width * 0.04,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: CommonVariables.height*0.03),
                  TextButton.icon(
                    onPressed: () {

                    },
                    icon: Icon(Icons.email_rounded, color: Colors.black),
                    label: Text(
                      Texts.SIGN_IN_WITH_EMAIL,
                      style: TextStyle(
                        fontSize: CommonVariables.width * 0.05,
                        color: Colors.black,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: CommonVariables.height * 0.02, horizontal: CommonVariables.width * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),

                  SizedBox(height: CommonVariables.height*0.03),
                  TextButton(
                    onPressed: () {

                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: Texts.DONT_HAVE_ACCOUNT,
                            style: TextStyle(
                              color: Colors.black26,
                              fontWeight: FontWeight.w400,

                              fontSize: CommonVariables.width * 0.045,
                            ),
                          ),
                          TextSpan(
                            text: Texts.SIGN_UP,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: CommonVariables.width * 0.045,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
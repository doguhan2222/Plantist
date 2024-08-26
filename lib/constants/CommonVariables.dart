import 'package:flutter/cupertino.dart';

class CommonVariables {
  static double width = 0.0;
  static double height = 0.0;

  static void init(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }
}

/*
How to use
@override
Widget build(BuildContext context) {
  CommonVariables.init(context);


  CommonVariables.width * 0.5;
  CommonVariables.height * 0.5;
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantist/constants/Texts.dart';


class CommonVariables {
  static double width = 0.0;
  static double height = 0.0;

  static void init(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }

  static const Map<String, Color> priorityColors = {
    Texts.VERYIMPORTANT: Colors.red,
    Texts.IMPORTANT: Colors.orange,
    Texts.LESSIMPORTANT: Colors.lightBlueAccent,
    Texts.NOTIMPORTANT: Colors.grey,
  };

}

/*
How to use
@override
Widget build(BuildContext context) {
  CommonVariables.init(context);


  CommonVariables.width * 0.5;
  CommonVariables.height * 0.5;
*/
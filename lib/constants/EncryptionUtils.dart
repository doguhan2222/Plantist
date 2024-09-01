import 'dart:convert';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionUtils {
  static const String _key = "tIxxbcczLj2Nia01WTfyiUBSRffN6a85"; //encryption key

  static String encrypt(String text) {
    var result = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      var charCode = text.codeUnitAt(i) ^ _key.codeUnitAt(i % _key.length);
      result.write(String.fromCharCode(charCode));
    }
    return base64.encode(utf8.encode(result.toString()));
  }

  static String decrypt(String encryptedText) {
    var decodedText = utf8.decode(base64.decode(encryptedText));
    var result = StringBuffer();
    for (var i = 0; i < decodedText.length; i++) {
      var charCode = decodedText.codeUnitAt(i) ^ _key.codeUnitAt(i % _key.length);
      result.write(String.fromCharCode(charCode));
    }
    return result.toString();
  }
}
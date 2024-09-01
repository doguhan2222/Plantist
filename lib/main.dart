import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:plantist/screens/HomeScreen.dart';
import 'package:plantist/screens/LoginScreen.dart';
import 'package:plantist/screens/SignupScreen.dart';
import 'package:plantist/screens/SplashScreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart';
import 'dart:io' show File, Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  //locks the screen vertically
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications();
  await Workmanager().initialize(callbackDispatcher);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(

      options: FirebaseOptions(
        apiKey: 'AIzaSyCISxPAt0AxtqhGRf847Y6LdGg2qgtXrvE',
        appId: '1:968152324264:android:6f5e575082a8bc123b8a9d',
        messagingSenderId: '968152324264',
        projectId: 'plantist-1e545',
        storageBucket: 'plantist-1e545.appspot.com',
      )

  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Plantist',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

    );
  }

}


Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Native called background task: $task");
    await checkAndSendNotification();
    return Future.value(true);
  });
}

Future<void> checkAndSendNotification() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? savedDates = prefs.getStringList('notificationDates');

  if (savedDates != null) {
    DateTime now = DateTime.now();
    for (String dateString in savedDates) {
      DateTime savedDate = DateTime.parse(dateString);
      if (savedDate.isBefore(now)) {
        savedDates.remove(dateString);
      }
    }
    await prefs.setStringList('notificationDates', savedDates);
  }
}

Future<void> sendNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails('1', 'EventNotification',
      importance: Importance.max, priority: Priority.high, showWhen: false);
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics);
}



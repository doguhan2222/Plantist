
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../main.dart';
import '../models/Reminder.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
class HomeRepository {


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> uploadFile(String reminderId,File? attachment) async {
   if(attachment != null){


      // Get file name and extension
       String fileName = basename(attachment.path);


       Reference storageRef = FirebaseStorage.instance.ref()
           .child('reminders')
           .child(reminderId)
           .child(fileName);

       try {

         UploadTask uploadTask = storageRef.putFile(attachment);

// To get the URL when the upload is complete
        TaskSnapshot snapshot = await uploadTask;
         String downloadUrl = await snapshot.ref.getDownloadURL();

         print("File successfully uploaded: $downloadUrl");
         return downloadUrl;
       } catch (e) {
         print("Error loading file: $e");
         return null;
       }
     } else {
     print("No file selected");
     return null;
     }


  }
  Future<void> addReminder(Reminder reminder,File? attachment) async {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;

      CollectionReference userReminders = _firestore.collection('users').doc(uid).collection('reminders');

      DocumentReference docRef = await userReminders.add(reminder.toRTDB());

      if(attachment !=null){
        String? downloadUrl = await uploadFile(docRef.id,attachment);
        if (downloadUrl != null) {
          await userReminders.doc(docRef.id).update({
            'attachmentUrl': downloadUrl,
          });
        }
      }


    } else {
      print('User is not logged in.');
    }
  }
//To pull the file from Firebase Storage, you can download the file using the file's URL or by using the Storage reference directly.
    Future<void> downloadFile(String reminderId) async {
    try {

      final ref = FirebaseStorage.instance.ref().child('reminders').child(reminderId);


      String downloadURL = await ref.getDownloadURL();


      print("file URL: $downloadURL");




    } catch (e) {
      print("Error occurred while downloading file: $e");
    }
  }

  Future<void> downloadAndSaveFile(String attachmentUrl) async {
    try {
      // Firebase Storage referansı oluşturun
      final storageRef = FirebaseStorage.instance.refFromURL(attachmentUrl);


      final Directory? directory = await getExternalStorageDirectory();
      final String filePath = '${directory?.path}/${attachmentUrl.split('/').last}';


      await storageRef.writeToFile(File(filePath));
      print('File successfully downloaded and saved: $filePath');


      final file = File(filePath);
      const Map<String, String> types = {
        ".3gp": "video/3gpp",
        ".torrent": "application/x-bittorrent",
        ".kml": "application/vnd.google-earth.kml+xml",
        ".gpx": "application/gpx+xml",
        ".csv": "application/vnd.ms-excel",
        ".apk": "application/vnd.android.package-archive",
        ".asf": "video/x-ms-asf",
        ".avi": "video/x-msvideo",
        ".bin": "application/octet-stream",
        ".bmp": "image/bmp",
        ".c": "text/plain",
        ".class": "application/octet-stream",
        ".conf": "text/plain",
        ".cpp": "text/plain",
        ".doc": "application/msword",
        ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ".xls": "application/vnd.ms-excel",
        ".xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        ".exe": "application/octet-stream",
        ".gif": "image/gif",
        ".gtar": "application/x-gtar",
        ".gz": "application/x-gzip",
        ".h": "text/plain",
        ".htm": "text/html",
        ".html": "text/html",
        ".jar": "application/java-archive",
        ".java": "text/plain",
        ".jpeg": "image/jpeg",
        ".jpg": "image/jpeg",
        ".js": "application/x-javascript",
        ".log": "text/plain",
        ".m3u": "audio/x-mpegurl",
        ".m4a": "audio/mp4a-latm",
        ".m4b": "audio/mp4a-latm",
        ".m4p": "audio/mp4a-latm",
        ".m4u": "video/vnd.mpegurl",
        ".m4v": "video/x-m4v",
        ".mov": "video/quicktime",
        ".mp2": "audio/x-mpeg",
        ".mp3": "audio/x-mpeg",
        ".mp4": "video/mp4",
        ".mpc": "application/vnd.mpohun.certificate",
        ".mpe": "video/mpeg",
        ".mpeg": "video/mpeg",
        ".mpg": "video/mpeg",
        ".mpg4": "video/mp4",
        ".mpga": "audio/mpeg",
        ".msg": "application/vnd.ms-outlook",
        ".ogg": "audio/ogg",
        ".pdf": "application/pdf",
        ".png": "image/png",
        ".pps": "application/vnd.ms-powerpoint",
        ".ppt": "application/vnd.ms-powerpoint",
        ".pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        ".prop": "text/plain",
        ".rc": "text/plain",
        ".rmvb": "audio/x-pn-realaudio",
        ".rtf": "application/rtf",
        ".sh": "text/plain",
        ".tar": "application/x-tar",
        ".tgz": "application/x-compressed",
        ".txt": "text/plain",
        ".wav": "audio/x-wav",
        ".wma": "audio/x-ms-wma",
        ".wmv": "audio/x-ms-wmv",
        ".wps": "application/vnd.ms-works",
        ".xml": "text/plain",
        ".z": "application/x-compress",
        ".zip": "application/x-zip-compressed",
        "": "*/*"
      };
      final extension = path.extension(filePath);

      await OpenFile.open(filePath, type: types[extension]);

    } catch (e) {
      print('Error downloading or saving file: $e');
    }
  }


  Future<List<Reminder>> getReminders() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference userReminders = _firestore.collection('users').doc(uid).collection('reminders');

      QuerySnapshot querySnapshot = await userReminders.get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Reminder> reminders = querySnapshot.docs.map((doc) {
          Reminder reminder = Reminder.fromRTDB(doc.data() as Map<String, dynamic>);
          reminder.id = doc.id;
          return reminder;
        }).toList();

        return reminders;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }
  Future<void> deleteReminder(String reminderId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference userReminders = _firestore.collection('users').doc(uid).collection('reminders');

      await userReminders.doc(reminderId).delete();
    }
  }

  Future<void> updateReminder(Reminder updatedReminder,File? attachment) async {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference userReminders = _firestore.collection('users').doc(uid).collection('reminders');

      await userReminders.doc(updatedReminder.id).update(updatedReminder.toRTDB());

      if(attachment !=null){
        String? downloadUrl = await uploadFile(updatedReminder.id,attachment);
        if (downloadUrl != null) {

          await userReminders.doc(updatedReminder.id).update({
            'attachmentUrl': downloadUrl,
          });
        }
      }
    }

  }


  Future<void> addReminderNotification(int dueDateMilliseconds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDates = prefs.getStringList('notificationDates') ?? [];

    DateTime reminderDate = DateTime.fromMillisecondsSinceEpoch(dueDateMilliseconds);
    savedDates.add(reminderDate.toIso8601String());

    await prefs.setStringList('notificationDates', savedDates);


    DateTime fiveMinutesBefore = reminderDate.subtract(Duration(minutes: 5));
    if (fiveMinutesBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
          fiveMinutesBefore,
          'Your event is coming up!',
          'Your event will start in 5 minutes.',
          reminderDate.millisecondsSinceEpoch
      );
    }


    DateTime oneDayBefore = reminderDate.subtract(Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
          oneDayBefore,
          'Your event is tomorrow!',
          'You have an event tomorrow at ${reminderDate.hour}:${reminderDate.minute}\.',
          reminderDate.millisecondsSinceEpoch + 1
      );
    }


    await Workmanager().cancelAll();
    await Workmanager().registerPeriodicTask(
      "checkNotification",
      "checkNotification",
      frequency: Duration(hours: 1),
    );

    print("Reminders scheduled for: ${reminderDate.toString()}");
  }
  Future<void> _scheduleNotification(DateTime scheduledDate, String title, String body, int id) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1',
      'EventNotification',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    tz.initializeTimeZones();
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: 5));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,

    );
  }


}
import 'dart:io';
import 'package:get/get.dart';
import '../constants/Texts.dart';
import '../models/Reminder.dart';
import '../repository/HomeRepository.dart';

class HomeViewModel extends GetxController {
  final HomeRepository _homeRepository = HomeRepository();

  var reminders = <Reminder>[].obs;
  var allReminders = <Reminder>[].obs; // Yedek liste

  var isLoading = false.obs;
  var errorMessage = ''.obs;


  final Map<String, int> priorityOrder = {
    Texts.VERYIMPORTANT: 1,
    Texts.IMPORTANT: 2,
    Texts.LESSIMPORTANT: 3,
    Texts.NOTIMPORTANT: 4,
  };

  @override
  void onInit() {
    super.onInit();
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    try {
      isLoading(true);
      var fetchedReminders = await _homeRepository.getReminders();
      allReminders(fetchedReminders);
      reminders(fetchedReminders);

// Priority order
    reminders.sort((a, b) => priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!));

    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void searchReminders(String query) {
    if (query.isEmpty) {
      reminders.value = allReminders;
    } else {
      reminders.value = allReminders.where((reminder) {
        return reminder.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    // Sıralamayı koru
    reminders.sort((a, b) => priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!));
  }

  void clearSearch() {
    reminders.value = allReminders;

    // Sıralamayı koru
    reminders.sort((a, b) => priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!));
  }

  Future<void> addReminder(Reminder reminder, File? attachment) async {
    try {
      isLoading(true);
      await _homeRepository.addReminder(reminder, attachment);
      fetchReminders();
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateReminder(Reminder reminder, File? attachment) async {
    try {
      isLoading(true);
      await _homeRepository.updateReminder(reminder, attachment);
      fetchReminders();
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      isLoading(true);
      await _homeRepository.deleteReminder(reminderId);
      fetchReminders();
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }



  Future<void> getReminderFileDetails(Reminder reminder) async {
    try {
      if (reminder.attachmentUrl.isNotEmpty) {
        await _homeRepository.downloadAndSaveFile(reminder.attachmentUrl);
      } else {
        print('Attached file URL not found.');
      }
    } catch (e) {
      errorMessage(e.toString());
    }
  }
  Future<void> registerNotification (int dueDateMilliseconds) async {
    try {

      await _homeRepository.addReminderNotification(dueDateMilliseconds);
    } catch (e) {
      errorMessage(e.toString());
    }
  }
}

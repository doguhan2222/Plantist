import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart';
import 'package:plantist/constants/CommonVariables.dart';
import 'package:plantist/viewmodels/HomeViewModel.dart';

import 'dart:io' show File, Platform;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/Texts.dart';
import '../models/Reminder.dart';





final HomeViewModel _homeController = Get.put(HomeViewModel());

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
final Rx<File?> selectedFile = Rx<File?>(null);
DateTime? dueDate;
RxString _selectedReminderId = "".obs;
RxBool _isUpdateMode = false.obs;
RxBool _showTimePicker = false.obs;
Rx<DateTime?> _selectedDate = Rx<DateTime?>(null);
RxBool _showDatePicker = false.obs;
Rx<TimeOfDay?> _selectedTime = Rx<TimeOfDay?>(null);
Rx<TextEditingController> _titleController = TextEditingController().obs;
 Rx<TextEditingController> _noteController = TextEditingController().obs;
RxString _selectedPriority = Texts.NOTIMPORTANT.obs;
String _category = Texts.GENERAL;
List<String> _tags = [];
RxBool _hasAttachment = false.obs;
RxBool _isSearching = false.obs;
Rx<TextEditingController> _searchController = TextEditingController().obs;
Rx<Reminder?> selectedReminder = Rx<Reminder?>(null);



class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    CommonVariables.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => _isSearching.value
            ? TextField(
          controller: _searchController.value,
          autofocus: true,
          decoration: InputDecoration(
            hintText: Texts.SEARCH,
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _homeController.searchReminders(value);
          },
        )
            : Text(Texts.PLANTIST, style: TextStyle(fontWeight: FontWeight.bold))),
        actions: [
          Obx(() => _isSearching.value
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _isSearching.value = false;
              _searchController.value.clear();
              _homeController.clearSearch();

            },
          )
              : IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _isSearching.value = true;
            },
          )),
        ],
      ),
      body: Obx(() {
        if (_homeController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (_homeController.reminders.isEmpty) {
          return Center(child: Text(Texts.NOREMINDERS));
        } else {
          return ListView(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(
                    vertical: CommonVariables.height * 0.01, horizontal: CommonVariables.width * 0.04),
                child: Text(
                  Texts.REMINDERS,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: CommonVariables.width * 0.04,
                      fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _homeController.reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _homeController.reminders[index];
                  dueDate = DateTime.fromMillisecondsSinceEpoch(reminder.dueDate!);
                  return Dismissible(
                    key: ValueKey(reminder.id),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: CommonVariables.width * 0.03),
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: CommonVariables.width * 0.03),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {

                          _titleController.value.text = reminder.title;
                          _noteController.value.text = reminder.note;
                          _selectedDate.value =
                              DateTime.fromMillisecondsSinceEpoch(
                                  reminder.dueDate);
                          _selectedTime.value =
                              TimeOfDay.fromDateTime(_selectedDate.value!);
                          _selectedPriority.value = reminder.priority;
                          _category = reminder.category;
                          _tags = reminder.tags;
                          _selectedReminderId.value = reminder.id;
                          _isUpdateMode.value = true;
                          selectedReminder.value = _homeController.reminders.value.firstWhere(
                                (reminder) => reminder.id == _selectedReminderId.value,
                            orElse: () => null!,
                          );


                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return NewReminderSheet();
                          },
                        ).whenComplete(() {


                          _noteController.value.text = "";
                          _titleController.value.text = "";
                          selectedReminder.value = null;
                          _searchController.value.text = "";
                          _isSearching.value = false;
                          _hasAttachment.value = false;
                          _selectedPriority.value = Texts.NOTIMPORTANT;
                          _titleController.value.text = "";
                          _isUpdateMode.value = false;
                          _selectedReminderId.value = "";
                          _showDatePicker.value = false;
                          _showTimePicker.value = false;
                          _selectedDate.value = null;
                          _selectedTime.value = null;
                          selectedFile.value = null;
                        });;
                        return false;
                      } else if (direction == DismissDirection.endToStart) {

                        await _homeController.deleteReminder(reminder.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(Texts.REMINDERDELETED)),
                        );
                        return true;
                      }
                      return false;
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 10,
                        backgroundColor: CommonVariables.priorityColors[reminder.priority]!.withOpacity(0.3),
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: CommonVariables.priorityColors[reminder.priority]!,
                        ),
                      ),
                      title: Text(
                        reminder.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if(reminder.attachmentUrl.isNotEmpty)...[

                                Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.attachment,
                                    size: CommonVariables.width * 0.04, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(Texts.ATTACHMENT1,
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          ],
                          if (reminder.category.isNotEmpty) ...[
                            SizedBox(height: CommonVariables.height * 0.005),
                            Text(
                              Texts.CATEGORY + ' ${reminder.category}',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                          if (reminder.tags.isNotEmpty) ...[
                            SizedBox(height: CommonVariables.height * 0.005),
                            Text(
                              Texts.TAGS + '${reminder.tags.join(", ")}',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ],
                      ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (dueDate != null)
                              Text(
                                dueDate!.toLocal().toString().split(' ')[0],
                                style: TextStyle(color: Colors.grey),
                              ),
                            if (dueDate != null && dueDate!.hour > 0)
                              Text(
                                "${dueDate!.hour}:${dueDate!.minute}",
                               style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                    ),
                  );
                },
              ),
            ],
          );
        }
      }),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.all(CommonVariables.width * 0.03),
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return NewReminderSheet();
              },
            ).whenComplete(() {


              _noteController.value.text = "";
              _titleController.value.text = "";
              selectedReminder.value = null;
              _searchController.value.text = "";
              _isSearching.value = false;
              _hasAttachment.value = false;
              _selectedPriority.value = Texts.NOTIMPORTANT;
              _titleController.value.text = "";
              _isUpdateMode.value = false;
              _selectedReminderId.value = "";
              _showDatePicker.value = false;
              _showTimePicker.value = false;
              _selectedDate.value = null;
              _selectedTime.value = null;
              selectedFile.value = null;
            });;
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: CommonVariables.width * 0.05),
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: CommonVariables.width * 0.06,color: Colors.white,),
              SizedBox(width: CommonVariables.width * 0.03),
              Text(Texts.NEWREMINDER, style: TextStyle(fontSize: CommonVariables.width * 0.045,color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

}

class NewReminderSheet extends StatefulWidget {
  @override
  _NewReminderSheetState createState() => _NewReminderSheetState();
}

class _NewReminderSheetState extends State<NewReminderSheet> {
  @override
  Widget build(BuildContext context) {
    CommonVariables.init(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: CommonVariables.height * 0.01,
        left: CommonVariables.width * 0.05,
        right: CommonVariables.width * 0.05,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {

                    _selectedReminderId.value = "";
                    _isUpdateMode.value == false;


                  Navigator.of(context).pop();
                },
                child: Text(Texts.CANCEL, style: TextStyle(color: Colors.blue)),
              ),
              Text(
                _isUpdateMode == true ?  Texts.UPDATEREMINDER: Texts.NEWREMINDER,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: CommonVariables.width * 0.045),
              ),
              TextButton(
                onPressed: () async {
                  int dueDate = _selectedDate.value != null && _selectedTime.value != null
                      ? DateTime(
                              _selectedDate!.value!.year,
                              _selectedDate!.value!.month,
                              _selectedDate!.value!.day,
                              _selectedTime!.value!.hour,
                              _selectedTime!.value!.minute)
                          .millisecondsSinceEpoch
                      : 0;


                  if (_isUpdateMode == true) {
                    Reminder newReminder = Reminder(
                      id: _selectedReminderId.value,
                      title: _titleController.value.text,
                      note: _noteController.value.text,
                      priority: _selectedPriority.value,
                      dueDate: dueDate,
                      category: _category,
                      tags: _tags,
                      attachmentUrl: "",
                    );


                    await _homeController.updateReminder(newReminder,selectedFile?.value);
                    if (dueDate != 0) {
                      await _homeController.registerNotification(dueDate);
                    }
                  } else {
                    Reminder newReminder = Reminder(
                      title: _titleController.value.text,
                      note: _noteController.value.text,
                      priority: _selectedPriority.value,
                      dueDate: dueDate,
                      category: _category,
                      tags: _tags,
                      attachmentUrl: "",
                    );
                    await _homeController.addReminder(newReminder,selectedFile?.value);
                    if (dueDate != 0) {
                      await _homeController.registerNotification(dueDate);
                    }
                  }

                    _selectedReminderId.value = "";
                    _isUpdateMode.value = false;

                  Navigator.of(context).pop();
                },
                child: Text(_isUpdateMode == true ? Texts.UPDATE : Texts.ADD,
                    style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          TextField(
            controller: _titleController.value,
            decoration: InputDecoration(
              hintText: Texts.TITLE,
              border: InputBorder.none,
            ),
          ),
          Divider(),
          TextField(
            controller: _noteController.value,
            decoration: InputDecoration(
              hintText: Texts.NOTES,
              border: InputBorder.none,
            ),
            maxLines: null,
          ),
          Padding(
            padding:  EdgeInsets.all(CommonVariables.width * 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(Texts.DETAILS, style: TextStyle(color: Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showModalBottomSheet(

                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          top: CommonVariables.height * 0.01,
                          left: CommonVariables.width * 0.05,
                          right: CommonVariables.width * 0.05,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: CommonVariables.height * 0.01),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.blue),
                                      SizedBox(width: CommonVariables.width * 0.045),
                                      Text(Texts.DATE,
                                          style: TextStyle(fontSize: CommonVariables.width * 0.04)),
                                    ],
                                  ),
                                  Obx(() => Text(
                                        _showDatePicker.value &&
                                                _selectedDate.value != null
                                            ? _selectedDate.value!
                                                .toLocal()
                                                .toShortDateString()
                                            : Texts.NODATESELECTED,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      )),
                                  Obx(() => Switch(
                                        value: _showDatePicker.value,
                                        onChanged: (bool value) {
                                          _showDatePicker.value = value;

                                          if (value) _selectDate(context);
                                        },
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: CommonVariables.height * 0.01),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: Colors.blue),
                                      SizedBox(width: CommonVariables.width * 0.045),
                                      Text(Texts.TIME,
                                          style: TextStyle(fontSize: CommonVariables.width * 0.04)),
                                    ],
                                  ),
                                  Obx(() => Text(
                                        _showTimePicker.value &&
                                                _selectedTime.value != null
                                            ? _selectedTime!.value!
                                                .format(context)
                                            : Texts.NOTIMESELECTED,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      )),
                                  Obx(() => Switch(
                                        value: _showTimePicker.value,
                                        onChanged: (bool value) {
                                          _showTimePicker.value = value;
                                          if (value) _selectTime(context);
                                        },
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.all(CommonVariables.width * 0.04),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Obx(() => ListTile(
                                      title: Text(Texts.PRIORITY,
                                          style:
                                              TextStyle(color: Colors.black)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(_selectedPriority.value,
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          SizedBox(width: CommonVariables.width * 0.04),
                                          Icon(Icons.arrow_forward_ios),
                                        ],
                                      ),
                                      onTap: () =>
                                          _showPrioritySelector(context),
                                    )),
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.all(CommonVariables.width * 0.04),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Obx(() => ListTile(
                                  title: Text(Texts.ATTACHAFILE, style: TextStyle(color: Colors.black)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                      selectedFile.value != null
                      ? _truncateFileName(basename(selectedFile.value!.path), 15)
                          : (selectedReminder.value != null && selectedReminder.value!.attachmentUrl.isNotEmpty
                      ? Texts.ATTACHMENT1
                          : Texts.NONE),
                                          style: TextStyle(color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: CommonVariables.width * 0.04),
                                      Icon(Icons.attach_file),
                                    ],
                                  ),
                                  onTap: () async {
                                    if(selectedFile.value != null ||selectedReminder.value!.attachmentUrl.isEmpty ){
                                      await pickFile();
                                    }
                                    else{
                                      await _homeController.getReminderFileDetails(selectedReminder.value!);

                                    }

                                  }
                                  ,
                                )),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrioritySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(CommonVariables.width * 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriorityOption(context, Texts.VERYIMPORTANT, Colors.red),
            _buildPriorityOption(context, Texts.IMPORTANT, Colors.orange),
            _buildPriorityOption(context, Texts.LESSIMPORTANT, Colors.blue),
            _buildPriorityOption(context, Texts.NOTIMPORTANT, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(BuildContext context, String priority, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        radius: 16,
      ),
      title: Text(priority),
      onTap: () {
        _selectedPriority.value = priority;
        Navigator.pop(context);
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    if (Platform.isIOS) {
      final DateTime? picked = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: CommonVariables.height * 0.2,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate.value ?? DateTime.now(),
              onDateTimeChanged: (DateTime newDateTime) {

                  _selectedDate.value = newDateTime;

              },
            ),
          );
        },
      );
      if (picked != null && picked != _selectedDate)

          _selectedDate.value = picked;

    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate.value ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null && picked != _selectedDate.value)

          _selectedDate.value = picked;

    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (Platform.isIOS) {
      final TimeOfDay? picked = await showCupertinoModalPopup<TimeOfDay>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: CommonVariables.height * 0.2,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: _selectedDate != null
                  ? DateTime(0, 0, 0, _selectedTime!.value!.hour ?? 0,
                      _selectedTime?.value?.minute ?? 0)
                  : DateTime.now(),
              onDateTimeChanged: (DateTime newDateTime) {

                  _selectedTime.value = TimeOfDay(
                      hour: newDateTime.hour, minute: newDateTime.minute);

              },
            ),
          );
        },
      );
      if (picked != null && picked != _selectedTime)

          _selectedTime.value = picked;

    } else {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime.value ?? TimeOfDay.now(),
      );
      if (picked != null && picked != _selectedTime)

          _selectedTime.value = picked;

    }
  }

  String _truncateFileName(String fileName, int maxLength) {
    if (fileName.length <= maxLength) return fileName;
    return fileName.substring(0, maxLength - 3) + '...';
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        File file = File(result.files.single.path!);
        selectedFile.value = file;

      } else {
        selectedFile.value = null;
      }
    } catch (e) {
      selectedFile.value = null;
    }
  }
}

extension DateUtils on DateTime {
  String toShortDateString() {
    return "${this.day}/${this.month}/${this.year}";
  }
}


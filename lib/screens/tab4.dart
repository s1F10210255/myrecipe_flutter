import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Tab4 extends StatefulWidget {
  @override
  _Tab4State createState() => _Tab4State();
}

class _Tab4State extends State<Tab4> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  String? _selectedEvent;
  final formatter = DateFormat('yyyy-MM-dd');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }

  Future<void> _showEditDialog() async {
    TextEditingController eventController = TextEditingController(text: _selectedEvent);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: eventController,
                  decoration: InputDecoration(hintText: "Enter your event"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _saveDateToFirebase(_selected!, eventController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteEventFromFirebase(_selected!);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveDateToFirebase(DateTime selectedDate, String event) {
    final String formattedDate = formatter.format(selectedDate);
    final String? userUID = getCurrentUserUID();

    if (userUID != null) {
      FirebaseFirestore.instance.collection('users')
          .doc(userUID)
          .collection('Calendar')
          .doc(formattedDate)
          .set({
        'event': event,
      });
    }
  }

  void _deleteEventFromFirebase(DateTime selectedDate) {
    final String formattedDate = formatter.format(selectedDate);
    final String? userUID = getCurrentUserUID();

    if (userUID != null) {
      FirebaseFirestore.instance.collection('users')
          .doc(userUID)
          .collection('Calendar')
          .doc(formattedDate)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TableCalendar(
          firstDay: DateTime.utc(2022, 4, 1),
          lastDay: DateTime.utc(2029, 12, 31),
          selectedDayPredicate: (day) {
            return isSameDay(_selected, day);
          },
          onDaySelected: (selected, focused) async {
            setState(() {
              _selected = selected;
              _focused = focused;
            });
            await _showEditDialog();
          },
          focusedDay: _focused,
        ),
      ),
    );
  }
}

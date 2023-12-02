import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g14/screens/edit_description.dart';
import 'package:g14/screens/edit_email.dart';
import 'package:g14/screens/edit_image.dart';
import 'package:g14/screens/edit_name.dart';
import 'package:g14/screens/edit_phone.dart';
import 'package:g14/widget/display_image_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Tab5 extends StatefulWidget {
  @override
  _Tab5State createState() => _Tab5State();
}

class _Tab5State extends State<Tab5> {
  User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser != null) {
      String imageUrl;
      try {
        imageUrl = await FirebaseStorage.instance
            .ref('user_images/${_currentUser!.uid}.jpg')
            .getDownloadURL();
      } catch (e) {
        imageUrl = 'assets/images/default_image.jpg';
      }

      String phone = 'Not set';
      String firstName = 'Not set';
      String lastName = 'Not set';
      String email ='Not set';

      try {
        var phoneDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('profiles')
            .doc('phone')
            .get();
        if (phoneDoc.exists && phoneDoc.data() != null) {
          phone = phoneDoc.data()!['phone'] ?? 'Not set';
        }

        var nameDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('profiles')
            .doc('name')
            .get();
        if (nameDoc.exists && nameDoc.data() != null) {
          firstName = nameDoc.data()!['firstName'] ?? 'Not set';
          lastName = nameDoc.data()!['lastName'] ?? 'Not set';
        }

        var emailDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('profiles')
            .doc('email')
            .get();

        if (emailDoc.exists && emailDoc.data() != null) {
          email = emailDoc.data()!['mail'] ?? 'Not set';
        }

        setState(() {
          _profileData = {
            'name': '$firstName $lastName',
            'phone': phone,
            'email': email,
            'about': 'No description added.',
            'image': imageUrl,
          };
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading user profile: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 10,
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  '設定',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(64, 105, 225, 1),
                  ),
                ),
              ),
            ),
            InkWell(
              child: DisplayImage(
                imagePath: _profileData['image'],
                onPressed: () {
                  navigateSecondPage(EditImagePage());
                },
              ),
            ),
            buildUserInfoDisplay('Name', '${_profileData['name']}', EditNameFormPage()),
            buildUserInfoDisplay('Phone', '${_profileData['phone']}', EditPhoneFormPage()),
            buildUserInfoDisplay('Email', '${_profileData['email']}', EditEmailFormPage()),
            buildAbout('${_profileData['about']}'),
          ],
        ),
      ),
    );
  }

  Widget buildUserInfoDisplay(String title, String? getValue, Widget editPage) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 1),
          Container(
            width: 350,
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      navigateSecondPage(editPage);
                    },
                    child: Text(
                      getValue ?? 'Not set',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                  size: 40.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAbout(String? aboutMeDescription) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell Us About Yourself',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 1),
          Container(
            width: 350,
            height: 200,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () {
                  navigateSecondPage(EditDescriptionFormPage());
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Text(
                    aboutMeDescription ?? 'No description added.',
                    style: TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateSecondPage(Widget editForm) {
    Route route = MaterialPageRoute(builder: (context) => editForm);
    Navigator.push(context, route).then(onGoBack);
  }

  void onGoBack(dynamic value) {
    setState(() {});
  }
}

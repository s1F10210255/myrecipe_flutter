import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g14/widget/appbar_widget.dart'; // あなたのカスタムAppBarウィジェットへのパスを確認してください

class EditImagePage extends StatefulWidget {
  const EditImagePage({Key? key}) : super(key: key);

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String? _downloadUrl;
  bool _isUploading = false;

  Future<void> _uploadAndSaveImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final File file = File(image.path);
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${_currentUser!.uid}.jpg');

      await ref.putFile(file);
      final String url = await ref.getDownloadURL();

      // Firestoreに保存
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('users').doc(_currentUser!.uid).collection('profiles').doc('image');
      await userDoc.set({'url': url});

      setState(() {
        _downloadUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      _handleUploadError(e);
    }
  }


  void _handleUploadError(dynamic e) {
    setState(() {
      _isUploading = false;
    });

    String errorMessage;
    if (e is FirebaseException) {
      errorMessage = 'Firebase error: ${e.code} - ${e.message}';
    } else {
      errorMessage = 'An unknown error occurred: $e';
    }
    print(errorMessage);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Failed'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }


  String _getErrorMessage(dynamic e) {
    // 特定のエラータイプに基づいたメッセージをここで追加します。
    // 例: if (e is FirebaseException) return e.message;
    return 'An error occurred: $e';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 330,
            child: const Text(
              "Upload a photo of yourself:",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: SizedBox(
              width: 330,
              child: GestureDetector(
                onTap: _uploadAndSaveImage,
                child: _downloadUrl != null
                    ? Image.network(_downloadUrl!)
                    : Image.asset('assets/images/default_image.jpg'), // デフォルト画像
              ),
            ),
          ),
          if (_isUploading) const CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 330,
                height: 50,
                child: ElevatedButton(
                  onPressed: _uploadAndSaveImage,
                  child: const Text('Update', style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

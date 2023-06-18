import 'dart:io' show File;
//import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';

late final String? downloadURL;

class ImageUploader {
  final FirebaseStorage _storage;
  File? selectedImage;

  ImageUploader(this._storage);

  Future<void> selectImage() async {
    // if (kIsWeb) {
    //   //web code
    // } else {
      print('mobile version');
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
      }
    //}
  }

  Future<String?> uploadImageToFirebase(File? image) async {
    if (image == null) {
      return null;
    }

    try {
      Reference storageReference = _storage
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}');

      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image to Firebase: $e');
      return null;
    }
  }
}

Future<void> selectAndUploadImageToFirebase() async {
  FirebaseStorage storage = FirebaseStorage.instance;
  ImageUploader imageUploader = ImageUploader(storage);

  await imageUploader.selectImage();
  downloadURL =
      await imageUploader.uploadImageToFirebase(imageUploader.selectedImage);
      

}

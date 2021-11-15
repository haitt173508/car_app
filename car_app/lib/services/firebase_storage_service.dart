import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final _storage = FirebaseStorage.instance;
  get storage => _storage;
  Future<UploadTask?> uploadFile(File file, String destination) async {
    try {
      final ref = _storage.ref(destination);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e.toString());
      return null;
    }
  }
}

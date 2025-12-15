// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();

  /// Upload an image to Firebase Storage and return the download URL
  static Future<String?> uploadImage({
    required File imageFile,
    required String folder,
    required String fileName,
  }) async {
    try {
      // Create a reference to the file location
      final ref = _storage.ref().child('$folder/$fileName');
      
      // Upload the file
      final uploadTask = await ref.putFile(imageFile);
      
      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Pick an image from gallery or camera
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Generate a unique filename with timestamp
  static String generateFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(originalName);
    return '${timestamp}_${path.basenameWithoutExtension(originalName)}$extension';
  }

  /// Delete an image from Firebase Storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Upload image for lost/found items
  static Future<String?> uploadLostFoundImage(File imageFile) async {
    final fileName = generateFileName(imageFile.path);
    return await uploadImage(
      imageFile: imageFile,
      folder: 'lost_found',
      fileName: fileName,
    );
  }

  /// Upload image for club logos
  static Future<String?> uploadClubLogo(File imageFile) async {
    final fileName = generateFileName(imageFile.path);
    return await uploadImage(
      imageFile: imageFile,
      folder: 'clubs',
      fileName: fileName,
    );
  }

  /// Upload profile picture for users
  static Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    return await uploadImage(
      imageFile: imageFile,
      folder: 'profile_pictures',
      fileName: fileName,
    );
  }

  /// Show image picker dialog and return selected image
  static Future<File?> showImagePickerDialog() async {
    // This would typically show a dialog with options for camera/gallery
    // For now, we'll default to gallery
    return await pickImage(source: ImageSource.gallery);
  }
}

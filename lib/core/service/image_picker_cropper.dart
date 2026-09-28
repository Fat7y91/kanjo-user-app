import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_color.dart';

abstract class ImagePickerService {
  Future<File?> pickImage(
      {bool crop = true, ImageSource source = ImageSource.gallery});

  Future<File?> cropImage(String path);
}

class ImagePickerServiceImpl extends ImagePickerService {
  @override
  Future<File?> pickImage(
      {bool crop = true, ImageSource source = ImageSource.gallery}) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
    );
    if (pickedImage == null) {
      return null;
    }
    if (!crop) {
      return File(pickedImage.path);
    }

    final cropped = await cropImage(pickedImage.path);
    // If crop was cancelled or failed, keep the original pick.
    return cropped ?? File(pickedImage.path);
  }

  @override
  Future<File?> cropImage(String path) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image'.tr,
            toolbarColor: AppColor.primary,
            toolbarWidgetColor: AppColor.white,
            statusBarColor: AppColor.primary,
            activeControlsWidgetColor: AppColor.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            title: 'Crop Image'.tr,
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:snap_tale/data/api/api_services.dart';
import 'package:snap_tale/data/controller/story_controller.dart';

import '../../common.dart';
import '../../flavors/flavor_config.dart';

class StoryAddController extends GetxController {
  final descController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final isLoading = false.obs;

  final ApiServices _apiService = ApiServices();

  final RxDouble? lat = RxDouble(0.0);
  final RxDouble? lon = RxDouble(0.0);
  final selectedAddress = ''.obs;

  void setLocation(double latitude, double longitude) {
    lat?.value = latitude;
    lon?.value = longitude;
  }

  void setImage(File image) {
    selectedImage.value = image;
  }

  void resetForm() {
    descController.clear();
    selectedImage.value = null;
  }

  Future<void> updateAddressFromLatLng(double lat, double lon, context) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        selectedAddress.value =
            "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        selectedAddress.value =
            AppLocalizations.of(context)!.textGetAddressNotFound;
      }
    } catch (e) {
      selectedAddress.value =
          AppLocalizations.of(context)!.textGetAddressFailed;
    }
  }

  Future<void> submitStory(BuildContext context) async {
    final StoryController controller = Get.put(StoryController());
    if (selectedImage.value == null || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.textErrorDescAndPictCannotEmpty,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🆕 Tambahin validasi lokasi khusus buat versi paid
    if (FlavorConfig.isPaid) {
      if (lat?.value == 0.0 || lon?.value == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Silakan pilih lokasi terlebih dahulu."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      isLoading.value = true;

      final file = selectedImage.value!;
      final bytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;

      final response = await _apiService.addStory(
        bytes: bytes,
        fileName: fileName,
        description: descController.text,
        lat: lat?.value,
        lon: lon?.value,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(true);
      context.go('/home');
      resetForm();
      controller.storyList;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    descController.dispose();
    super.onClose();
  }
}

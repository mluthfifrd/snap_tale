import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap_tale/data/controller/story_add_controller.dart';

import '../classes/language_dropdown.dart';
import '../common.dart';
import '../flavors/flavor_config.dart';

class StoryAddScreen extends StatefulWidget {
  const StoryAddScreen({super.key});

  @override
  State<StoryAddScreen> createState() => _StoryAddScreenState();
}

class _StoryAddScreenState extends State<StoryAddScreen> {
  final controller = Get.put(StoryAddController());
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final sizeInBytes = await file.length();

      if (sizeInBytes > 1024 * 1024) {
        Get.snackbar("Error", "Maximum image size 1MB");
        return;
      }

      controller.setImage(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.textAddStory),
        actions: [LanguageDropdown()],
      ),
      body: Obx(() => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPicture(),
              const SizedBox(height: 24),
              TextField(
                controller: controller.descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.textDescription,
                  hintText: AppLocalizations.of(context)!.textHintDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FlavorConfig.isPaid
                  ? _buildLocation(context)
                  : _buildLocationUnavailable(context),
              _submitButton()
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPicture() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.textBtnTakePicture,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.textBtnGalery,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.selectedImage.value != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              controller.selectedImage.value!,
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }

  Widget _buildLocation(BuildContext context) {
    return Column(
      children: [
        Text(
          "${AppLocalizations.of(context)!.textSelectLocation}:",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
              () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(controller.selectedAddress.value)],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: Obx(() {
            final LatLng initialPosition =
            controller.lat!.value != 0.0 &&
                controller.lon!.value != 0.0
                ? LatLng(controller.lat!.value, controller.lon!.value)
                : const LatLng(-6.8957473, 107.6337669);

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 14,
              ),
              onTap: (LatLng pos) async {
                controller.lat!.value = pos.latitude;
                controller.lon!.value = pos.longitude;

                await controller.updateAddressFromLatLng(
                  pos.latitude,
                  pos.longitude,
                  context,
                );
              },
              markers: {
                if (controller.lat!.value != 0.0 &&
                    controller.lon!.value != 0.0)
                  Marker(
                    markerId: const MarkerId("selected_location"),
                    position: LatLng(
                      controller.lat!.value,
                      controller.lon!.value,
                    ),
                  ),
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: true,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLocationUnavailable(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${AppLocalizations.of(context)!.textSelectLocation}:",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            AppLocalizations.of(context)!.textPaidFeature,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Obx(() {
          return controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.submitStory(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.textAddStory,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

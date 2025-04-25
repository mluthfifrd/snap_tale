import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../common.dart';
import '../api/api_services.dart';
import '../model/story_detail_response.dart';

class StoryDetailController extends GetxController {
  final String storyId;

  StoryDetailController(this.storyId);

  var story = Rxn<StoryDetailElement>();
  var isLoading = false.obs;
  final selectedAddress = ''.obs;

  Future<void> getAddressFromLatLng(BuildContext context) async {
    isLoading.value = true;
    try {
      final placemarks = await placemarkFromCoordinates(story.value!.lat!, story.value!.lon!);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        selectedAddress.value =
        "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        isLoading.value = false;
      } else {
        isLoading.value = false;
        selectedAddress.value = AppLocalizations.of(context)!.textGetAddressNotFound;
      }
    } catch (e) {
      isLoading.value = false;
      selectedAddress.value = AppLocalizations.of(context)!.textGetAddressFailed;
    }
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    getStoryDetail();
  }

  Future<void> getStoryDetail() async {
    isLoading.value = true;
    try {
      final response = await ApiServices.fetchStoryDetail(storyId);
      story.value = response.story;
      isLoading.value = false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:get/get.dart';

import '../api/api_services.dart';
import '../model/story_model.dart';

class StoryController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var allStories = <StoryListElement>[];
  var storyList = <StoryListElement>[].obs;

  final int pageSize = 10;
  int currentPage = 1;
  var hasMore = true.obs;

  @override
  void onInit() {
    fetchStories();
    super.onInit();
  }

  Future<void> fetchStories({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage = 1;
        hasMore.value = true;
        storyList.clear();
      }

      isLoading.value = true;

      final response = await ApiServices().getStoryList(
        page: currentPage,
        size: pageSize,
      );

      if (response.listStory.isEmpty) {
        hasMore.value = false;
      } else {
        storyList.addAll(response.listStory);
        currentPage++;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreStories() {
    if (!hasMore.value || isLoading.value) return;
    fetchStories();
  }

  Future<void> refreshStories() async {
    await fetchStories(isRefresh: true);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../classes/language_dropdown.dart';
import '../common.dart';
import '../data/controller/auth/auth_controller.dart';
import '../data/controller/story_controller.dart';
import '../data/model/story_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authController = Get.put(AuthController());
  final controller = Get.put(StoryController());
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          controller.hasMore.value &&
          !controller.isLoading.value) {
        controller.loadMoreStories();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildBody(context)),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(
        () => Text(
          "${AppLocalizations.of(context)!.textHomeScreen}, ${authController.name.value}",
        ),
      ),
      actions: [
        LanguageDropdown(),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => AuthController().logout(context),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value && controller.storyList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(child: Text(controller.errorMessage.value));
    }

    if (controller.storyList.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.textEmptyStoryList),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => controller.refreshStories(),
      child: ListView.builder(
        controller: scrollController,
        itemCount:
            controller.storyList.length + (controller.isLoading.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < controller.storyList.length) {
            final story = controller.storyList[index];
            return _buildStoryCard(context, story);
          } else {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child:
                    controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryListElement story) {
    return GestureDetector(
      onTap: () => context.push('/detail/${story.id}'),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  story.photoUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      story.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed:
          () => context.push('/add-story').then((result) {
            if (result == true) {
              controller.refreshStories();
            }
          }),
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        AppLocalizations.of(context)!.textAddStory,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: Colors.blueAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 6,
    );
  }
}

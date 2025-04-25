import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:snap_tale/data/model/story_detail_response.dart';

import '../classes/language_dropdown.dart';
import '../common.dart';
import '../data/controller/story_detail_controller.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late final StoryDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      StoryDetailController(widget.storyId),
      tag: widget.storyId,
    );
    controller.getStoryDetail();
  }

  @override
  void dispose() {
    Get.delete<StoryDetailController>(tag: widget.storyId);
    super.dispose();
  }

  String dateFormat(DateTime date) {
    return DateFormat(
      "EEEE, dd MMMM yyyy - HH:mm:ss",
      AppLocalizations.of(context)!.textDaysMonthYear,
    ).format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final story = controller.story.value;
      return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.textDetailScreen),
            actions: [LanguageDropdown()]
        ),
        body:
            story == null
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context, story)
      );
    });
  }

  Widget _buildBody(BuildContext context, StoryDetailElement story) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: 350,
              child: Image.network(
                story.photoUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            story.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            story.description,
            style: const TextStyle(fontSize: 16),
            softWrap: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${AppLocalizations.of(context)!.textCreatedAt}: ${dateFormat(story.createdAt)}',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (story.lat != null && story.lon != null) ...[
            Obx(() {
              controller.getAddressFromLatLng(context);
              return Text(
                controller.selectedAddress.value.isEmpty
                    ? AppLocalizations.of(context)!.textGetAddress
                    : controller.selectedAddress.value,
                style: const TextStyle(fontSize: 14),
              );
            }),
            const SizedBox(height: 10),
            SizedBox(
              height: 300, // Height constraint for the map
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(story.lat!, story.lon!),
                  zoom: 18,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('story_location'),
                    position: LatLng(story.lat!, story.lon!),
                    infoWindow: InfoWindow(
                      title: controller.selectedAddress.value.isEmpty
                          ? AppLocalizations.of(context)!.textGetAddress
                          : controller.selectedAddress.value,
                    ),
                  ),
                },
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

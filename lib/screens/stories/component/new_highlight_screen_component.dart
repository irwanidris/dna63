// new_highlight_screen.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/stories/model/highlight_model.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class NewHighlightScreen extends StatefulWidget {
  final List<StoryHighlight> allStories; // Pass all stories to select from
  final VoidCallback? onCreated;

  const NewHighlightScreen({super.key, required this.allStories, this.onCreated});

  @override
  _NewHighlightScreenState createState() => _NewHighlightScreenState();
}

class _NewHighlightScreenState extends State<NewHighlightScreen> {
  final TextEditingController _titleController = TextEditingController();
  final Set<int> _selectedStories = {};

  bool _loading = false;

  String _title = "";

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {
        _title = _titleController.text.trim();
      });
    });
  }

  Future<void> _createHighlight() async {
    try {
      ///Upload story
      /// create new api for highlight creation
      var request = {
        'type': "highlight",
        'parent_title': _title,
        'existing_story_id': _selectedStories.toList().toString(),
      };
      await createHighlightStory(request: request).then((value) {
        log("Highlight created: ${value.message}");
      });

      toast(language.highlightCreated);
      widget.onCreated?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      toast(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.newHighlight,
      actions: [
        if (_selectedStories.isNotEmpty && _title.isNotEmpty)
          TextButton(
            onPressed: _loading ? null : _createHighlight,
            child: Text(language.create, style: boldTextStyle(color: appColorPrimary)),
          ).paddingOnly(right: 16),
      ],
      child: Column(
        children: [
          if (_selectedStories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: language.highlightName,
                  hintText: language.enterHighlightName,
                  prefixIcon: const Icon(Icons.star, color: appColorPrimary),
                  filled: true,
                  fillColor: context.cardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appStore.isDarkMode ? cardDarkColor : Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appColorPrimary.withValues(alpha: 0.5), width: 2),
                  ),
                ),
              ),
            ),

          // grid of stories
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(12),
              itemCount: widget.allStories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 2 / 3,
              ),
              itemBuilder: (context, index) {
                final StoryHighlight story = widget.allStories[index];
                final isSelected = _selectedStories.contains(story.id);
                log("isSelected: $isSelected, storyId: ${story.id}, selectedStories: $_selectedStories");

                /// convert story time in date formate
                var date = timeStampToDateFormat(story.createdTime!);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedStories.remove(story.id);
                      } else {
                        _selectedStories.add(story.id);
                      }
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      cachedImage(
                        story.mediaUrl,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(8),
                      if (isSelected)
                        Container(
                          color: Colors.black45,
                          child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
                        ),
                      // Date overlay at bottom
                      Positioned(
                        bottom: 6,
                        left: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            date.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

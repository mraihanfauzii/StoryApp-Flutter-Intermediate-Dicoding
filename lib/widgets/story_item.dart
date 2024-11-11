import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../navigation/router_delegate.dart';

class StoryItem extends StatelessWidget {
  final Story story;

  const StoryItem({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        story.photoUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
      title: Text(story.name),
      subtitle: Text(story.description),
      onTap: () {
        final routerDelegate = Router.of(context).routerDelegate as MyRouterDelegate;
        routerDelegate.showStoryDetail(story.id);
      },
    );
  }
}
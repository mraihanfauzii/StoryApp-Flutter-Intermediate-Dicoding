import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/router_delegate.dart';
import '../providers/story_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/story_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  _StoryListScreenState createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      storyProvider.fetchStories(authProvider.user!.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final storyProvider = Provider.of<StoryProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.stories),
      ),
      body: storyProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : storyProvider.errorMessage != null
          ? Center(child: Text(storyProvider.errorMessage!))
            : RefreshIndicator(
                onRefresh: () async {
                  await storyProvider.fetchStories(authProvider.user!.token);
                },
                child: storyProvider.stories.isEmpty
                  ? Center(child: Text(localizations.noStories))
                  : ListView.builder(
                    itemCount: storyProvider.stories.length,
                    itemBuilder: (context, index) {
                      return StoryItem(story: storyProvider.stories[index]);
                    },
                  ),
            ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: FloatingActionButton(
            onPressed: () async {
              final routerDelegate = Router.of(context).routerDelegate as MyRouterDelegate;
              routerDelegate.showAddStoryPage();
            },
            child: const Icon(Icons.add),
          ),
      ),
    );
  }
}
import 'dart:math';
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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  late AuthProvider _authProvider;
  late StoryProvider _storyProvider;

  int _oldStoryCount =
      0; // Menyimpan jumlah story yang sudah di-insert ke AnimatedList

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _storyProvider = Provider.of<StoryProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset dan fetch data awal
      _storyProvider.reset();
      _storyProvider.fetchStories(_authProvider.user!.token);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Jika posisi scroll mendekati bagian bawah list, load halaman berikutnya
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_storyProvider.isLoading && _storyProvider.hasMoreStories) {
        _storyProvider.fetchStories(_authProvider.user!.token);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleNewStories(StoryProvider storyProvider) {
    final newCount = storyProvider.stories.length;
    // Jika terdapat story baru
    if (newCount > _oldStoryCount) {
      final startIndex = _oldStoryCount;
      final itemCount = newCount - _oldStoryCount;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (int i = 0; i < itemCount; i++) {
          _listKey.currentState?.insertItem(startIndex + i);
        }
        _oldStoryCount = newCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.stories),
      ),
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          if (storyProvider.isLoading && storyProvider.stories.isEmpty) {
            // Kondisi loading awal
            return const Center(child: CircularProgressIndicator());
          } else if (storyProvider.errorMessage != null) {
            // Jika terjadi error
            return Center(child: Text(storyProvider.errorMessage!));
          }

          // Tangani story baru yang datang
          _handleNewStories(storyProvider);

          return RefreshIndicator(
            onRefresh: () async {
              // Saat refresh, reset segalanya
              _oldStoryCount = 0;
              storyProvider.reset();
              await storyProvider.fetchStories(_authProvider.user!.token,
                  refresh: true);
            },
            child: storyProvider.stories.isEmpty
                ? ListView(
                    children: [
                      Center(child: Text(localizations.noStories)),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          controller: _scrollController,
                          initialItemCount: _oldStoryCount,
                          itemBuilder: (context, index, animation) {
                            if (index < storyProvider.stories.length) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(
                                    begin: Offset(_random.nextDouble(), 1.0),
                                    end: Offset.zero,
                                  ).chain(CurveTween(curve: Curves.easeInOut)),
                                ),
                                child: StoryItem(
                                    story: storyProvider.stories[index]),
                              );
                            } else {
                              // Jika index di luar jangkauan stories
                              return const SizedBox();
                            }
                          },
                        ),
                      ),
                      if (storyProvider.isLoading &&
                          storyProvider.hasMoreStories)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          onPressed: () async {
            final routerDelegate =
                Router.of(context).routerDelegate as MyRouterDelegate;
            routerDelegate.showAddStoryPage();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

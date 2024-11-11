import 'package:flutter/material.dart';
import '../models/route_path.dart';
import '../providers/auth_provider.dart';
import '../screens/add_story_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/story_detail_screen.dart';

class MyRouterDelegate extends RouterDelegate<MyRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<MyRoutePath> {
  @override

  final GlobalKey<NavigatorState> navigatorKey;
  final AuthProvider authProvider;

  String? selectedStoryId;
  bool show404 = false;
  bool showAddStory = false;
  bool showRegisterPage = false;

  MyRouterDelegate(this.authProvider) : navigatorKey = GlobalKey<NavigatorState>(){
    authProvider.addListener(notifyListeners);
  }

  @override
  MyRoutePath get currentConfiguration {
    if (show404) {
      return MyRoutePath.unknown();
    } else if (showRegisterPage) {
      return MyRoutePath.register();
    } else if (!authProvider.isLoggedIn) {
      return MyRoutePath.login();
    } else if (showAddStory) {
      return MyRoutePath.addStory();
    } else if (selectedStoryId != null) {
      return MyRoutePath.storyDetail(selectedStoryId!);
    } else {
      return MyRoutePath.home();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Page<dynamic>> pages = [];

    if (authProvider.isLoading) {
      pages.add(
        const MaterialPage(
          child: Scaffold(
            body: Center(child: CircularProgressIndicator())
          ),
        ),
      );
    } else if (!authProvider.isLoggedIn) {
      pages.add(const MaterialPage(child: LoginScreen()));
      if (showRegisterPage) {
        pages.add(const MaterialPage(child: RegisterScreen()));
      }
    } else {
      pages.add(const MaterialPage(child: HomeScreen()));
    }

    if (showAddStory) {
      pages.add(
        const MaterialPage(
          key: ValueKey('AddStoryPage'),
          child: AddStoryScreen()
        ),
      );
    }

    if (selectedStoryId != null) {
      pages.add(
        MaterialPage(
            key: const ValueKey('StoryDetailPage'),
            child: StoryDetailScreen(storyId: selectedStoryId!)
        ),
      );
    }

    if (show404) {
      pages.add(
        const MaterialPage(
            child: Scaffold(
              body: Center(
                child: Text('Page not found')
              ),
            ),
        ),
      );
    }

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        if (route.settings is MaterialPage) {
          final page = route.settings as MaterialPage;
          if (page.child is AddStoryScreen) {
            showAddStory = false;
          } else if (page.child is StoryDetailScreen) {
            selectedStoryId = null;
          } else if (page.child is RegisterScreen) {
            showRegisterPage = false;
          }
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(MyRoutePath configuration) async {
    if (configuration.isUnknown) {
      show404 = true;
      return;
    }
    if (configuration.isRegisterPage) {
      showRegisterPage = true;
    } else if (configuration.isAddStoryPage) {
      showAddStory = true;
    } else if (configuration.isStoryDetailPage) {
      selectedStoryId = configuration.id;
    } else {
      showRegisterPage = false;
      showAddStory = false;
      selectedStoryId = null;
    }
    show404 = false;
  }

  void showRegister() {
    showRegisterPage = true;
    notifyListeners();
  }

  void login() {
    showRegisterPage = false;
    notifyListeners();
  }

  void logout() {
    authProvider.logout();
    notifyListeners();
  }

  void showStoryDetail(String id) {
    selectedStoryId = id;
    notifyListeners();
  }

  void showAddStoryPage() {
    showAddStory = true;
    notifyListeners();
  }
}

import 'package:dicoding_flutter_intermediate/screens/select_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  bool showSelectLocationPage = false;

  LatLng? selectedLocation;
  String? selectedAddress;

  MyRouterDelegate(this.authProvider)
      : navigatorKey = GlobalKey<NavigatorState>() {
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
      if (showSelectLocationPage) {
        return MyRoutePath.selectLocation();
      } else {
        return MyRoutePath.addStory();
      }
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
          child: Scaffold(body: Center(child: CircularProgressIndicator())),
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
        MaterialPage(
            key: const ValueKey('AddStoryPage'),
            child: AddStoryScreen(key: AddStoryScreen.globalKey)),
      );
      if (showSelectLocationPage) {
        pages.add(
          const MaterialPage(
            key: ValueKey('SelectLocationPage'),
            child: SelectLocationScreen(),
          ),
        );
      }
    }

    if (selectedStoryId != null) {
      pages.add(
        MaterialPage(
            key: const ValueKey('StoryDetailPage'),
            child: StoryDetailScreen(storyId: selectedStoryId!)),
      );
    }

    if (show404) {
      pages.add(
        const MaterialPage(
          child: Scaffold(
            body: Center(child: Text('Page not found')),
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
          if (page.child is SelectLocationScreen) {
            showSelectLocationPage = false;
            if (result != null && result is Map) {
              selectedLocation = result['location'];
              final address = result['address'];
              final addStoryScreenState = AddStoryScreen.globalKey.currentState;
              if (addStoryScreenState != null && selectedLocation != null) {
                addStoryScreenState.setLocation(selectedLocation!, address);
              }
            }
          } else if (page.child is AddStoryScreen) {
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

  void setSelectedLocation(LatLng? location, String address) {
    selectedLocation = location;
    selectedAddress = address;
    final addStoryScreenState = AddStoryScreen.globalKey.currentState;
    if (addStoryScreenState != null && selectedLocation != null) {
      addStoryScreenState.setLocation(selectedLocation!, selectedAddress!);
    }
    showSelectLocationPage = false;
    notifyListeners();
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

  void showSelectLocation() {
    showSelectLocationPage = true;
    notifyListeners();
  }
}

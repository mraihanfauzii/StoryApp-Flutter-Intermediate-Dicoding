import 'package:flutter/material.dart';
import '../models/route_path.dart';

class MyRouteInformationParser extends RouteInformationParser<MyRoutePath> {
  @override
  Future<MyRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');
    if (uri.pathSegments.isEmpty) {
      return MyRoutePath.home();
    } else if (uri.pathSegments.length == 1) {
      switch (uri.pathSegments[0]) {
        case 'login':
          return MyRoutePath.login();
        case 'register':
          return MyRoutePath.register();
        case 'home':
          return MyRoutePath.home();
        case 'stories-add':
          return MyRoutePath.addStory();
        default:
          return MyRoutePath.unknown();
      }
    } else if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'stories') {
        return MyRoutePath.storyDetail(uri.pathSegments[1]);
      }
    }
    return MyRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(MyRoutePath configuration) {
    if (configuration.isUnknown) {
      return const RouteInformation(location: '/404');
    } else if (configuration.isLoginPage) {
      return const RouteInformation(location: '/login');
    } else if (configuration.isRegisterPage) {
      return const RouteInformation(location: '/register');
    } else if (configuration.isHomePage) {
      return const RouteInformation(location: '/home');
    } else if (configuration.isAddStoryPage) {
      return const RouteInformation(location: '/stories-add');
    } else if (configuration.isStoryDetailPage) {
      return RouteInformation(location: '/stories/${configuration.id}');
    }
    return null;
  }
}

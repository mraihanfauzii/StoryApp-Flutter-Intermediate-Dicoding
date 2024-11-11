import 'package:flutter/material.dart';
import '../services/story_service.dart';
import '../models/story_model.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();
  List<Story> _stories =  [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStories(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stories = await _storyService.fetchStories(token);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStory(String token, String description, String filePath) async {
    await _storyService.addStory(token, description, filePath);
  }

  Future<Story> fetchStoryDetail(String token, String id) async {
    return await _storyService.fetchStoryDetail(token, id);
  }
}
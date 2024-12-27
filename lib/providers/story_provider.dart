import 'package:flutter/material.dart';
import '../services/story_service.dart';
import '../models/story_model.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();
  final List<Story> _stories = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMoreStories = true;

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreStories => _hasMoreStories;

  Future<void> fetchStories(String token, {bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    if (refresh) {
      _stories.clear();
      _currentPage = 1;
      _hasMoreStories = true;
    }

    try {
      final newStories =
          await _storyService.fetchStories(token, page: _currentPage);
      if (newStories.isEmpty) {
        _hasMoreStories = false;
      } else {
        _stories.addAll(newStories);
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _stories.clear();
    _currentPage = 1;
    _hasMoreStories = true;
    notifyListeners();
  }

  Future<void> addStory(String token, String description, String filePath,
      {double? lat, double? lon}) async {
    await _storyService.addStory(token, description, filePath,
        lat: lat, lon: lon);
  }

  Future<Story> fetchStoryDetail(String token, String id) async {
    return await _storyService.fetchStoryDetail(token, id);
  }
}

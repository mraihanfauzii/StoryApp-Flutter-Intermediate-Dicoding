import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../providers/auth_provider.dart';
import '../models/story_model.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  _StoryDetailScreenState createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  Story? _story;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStoryDetail();
  }

  Future<void> _fetchStoryDetail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    try {
      final story = await storyProvider.fetchStoryDetail(authProvider.user!.token, widget.storyId);
      setState(() {
        _story = story;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Detail'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _story!.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    _story!.photoUrl,
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity
                  ),
                  const SizedBox(height: 10),
                  Text(_story!.description)
                ],
              ),
          ),
    );
  }
}
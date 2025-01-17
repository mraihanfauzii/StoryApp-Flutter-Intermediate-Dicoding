import 'api_service.dart';
import '../models/story_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoryService {
  Future<List<Story>> fetchStories(String token,
      {int page = 1, int size = 10}) async {
    final response =
        await ApiService.get('/stories?page=$page&size=$size', token: token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List storiesJson = data['listStory'];
      return storiesJson.map((json) => Story.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Story> fetchStoryDetail(String token, String id) async {
    final response = await ApiService.get('/stories/$id', token: token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Story.fromJson(data['story']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> addStory(String token, String description, String filePath,
      {double? lat, double? lon}) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiService.baseUrl}/stories'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['description'] = description;

    if (lat != null && lon != null) {
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();
    }

    request.files.add(await http.MultipartFile.fromPath('photo', filePath));
    final response = await request.send();
    if (response.statusCode != 201) {
      final respStr = await response.stream.bytesToString();
      throw Exception(jsonDecode(respStr)['message']);
    }
  }
}

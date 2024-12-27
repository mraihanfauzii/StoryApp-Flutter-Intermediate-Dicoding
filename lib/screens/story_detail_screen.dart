import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../providers/auth_provider.dart';
import '../providers/story_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoryDetailScreen extends StatelessWidget {
  final String storyId;

  Future<String?> _reverseGeocodeCoordinates(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.subLocality}, '
            '${placemark.locality}, ${placemark.country}';
      }
      return 'No address found';
    } catch (e) {
      return 'No address available';
    }
  }

  const StoryDetailScreen({Key? key, required this.storyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<Story>(
      future: storyProvider.fetchStoryDetail(authProvider.user!.token, storyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.storyDetail),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.storyDetail),
            ),
            body: Center(child: Text(snapshot.error.toString())),
          );
        } else if (snapshot.hasData) {
          final story = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.storyDetail),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      story.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Image.network(
                      story.photoUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(story.description),
                    const SizedBox(height: 20),
                    if (story.lat != null && story.lon != null)
                      FutureBuilder<String?>(
                        future:
                            _reverseGeocodeCoordinates(story.lat!, story.lon!),
                        builder: (context, addressSnapshot) {
                          final address =
                              addressSnapshot.data ?? "Fetching address...";
                          return Column(
                            children: [
                              SizedBox(
                                height: 300,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(story.lat!, story.lon!),
                                    zoom: 14,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(story.id),
                                      position: LatLng(story.lat!, story.lon!),
                                      infoWindow: InfoWindow(
                                        title: story.name,
                                        snippet: address,
                                      ),
                                    ),
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text('Latitude: ${story.lat}'),
                              Text('Longitude: ${story.lon}'),
                              Text(
                                'Address: $address',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.storyDetail),
            ),
            body: const Center(child: Text('No data')),
          );
        }
      },
    );
  }
}

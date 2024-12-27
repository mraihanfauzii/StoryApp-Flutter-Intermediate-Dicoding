import 'package:dicoding_flutter_intermediate/navigation/router_delegate.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({Key? key}) : super(key: key);

  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? _selectedLocation;
  String? _address;
  GoogleMapController? _mapController;

  Future<void> _onTap(LatLng position) async {
    setState(() {
      _selectedLocation = position;
      _address = null;
    });

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          _address =
              '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.country}';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'No address available';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    _onTap(currentLatLng);

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(currentLatLng),
    );
  }

  void _onConfirm() {
    if (_selectedLocation != null) {
      final routerDelegate =
          Router.of(context).routerDelegate as MyRouterDelegate;
      routerDelegate.setSelectedLocation(_selectedLocation, _address ?? '');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onConfirm,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onTap,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-6.1751, 106.8650), // Jakarta coordinates
              zoom: 12,
            ),
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation!,
                      infoWindow: InfoWindow(
                        title: 'Selected Location',
                        snippet: _address ?? 'Fetching address...',
                      ),
                    ),
                  }
                : {},
          ),
          if (_address != null)
            Positioned(
              bottom: 50,
              left: 10,
              right: 10,
              child: Container(
                color: Colors.white70,
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Address: $_address',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

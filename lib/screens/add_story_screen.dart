import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../navigation/router_delegate.dart';
import '../providers/story_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

class AddStoryScreen extends StatefulWidget {
  static final GlobalKey<AddStoryScreenState> globalKey =
      GlobalKey<AddStoryScreenState>();

  const AddStoryScreen({super.key});

  @override
  AddStoryScreenState createState() => AddStoryScreenState();
}

class AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  XFile? _image;
  bool _isLoading = false;
  double? _lat;
  double? _lon;
  String? _address;

  void setLocation(LatLng? location, String address) {
    if (location == null) return;
    setState(() {
      _lat = location.latitude;
      _lon = location.longitude;
      _address = address;
    });
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final routerDelegate =
        Router.of(context).routerDelegate as MyRouterDelegate;
    final isPaidVersion = MyApp.isPaidVersion;

    return Scaffold(
        appBar: AppBar(
          title: Text(localizations.addStory),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_image != null)
                        Image.file(
                          File(_image!.path),
                          height: 200,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: Text(localizations.chooseImage),
                          ),
                          ElevatedButton(
                            onPressed: _captureImage,
                            child: const Text('camera'),
                          ),
                        ],
                      ),
                      CustomTextField(
                        label: localizations.description,
                        onSaved: (value) => _description = value!,
                        validator: Validators.requiredValidator,
                      ),
                      const SizedBox(height: 20),
                      if (isPaidVersion)
                        ElevatedButton(
                          onPressed: () {
                            routerDelegate.showSelectLocation();
                          },
                          child: Text(localizations.selectLocation),
                        )
                      else
                        Text(localizations.locationAvailableInPaidVersion),
                      if (_lat != null && _lon != null)
                        Text('Localion selected: ($_lat, $_lon)'),
                      const SizedBox(height: 10),
                      if (isPaidVersion)
                        Text(
                          _address ?? localizations.noLocationSelected,
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: _submit, child: Text(localizations.submit))
                    ],
                  ),
                ),
              )));
  }

  void _pickImage() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    setState(() {
      _image = image;
    });
  }

  void _captureImage() async {
    final image =
        await _picker.pickImage(source: ImageSource.camera, maxWidth: 600);
    setState(() {
      _image = image;
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        final storyProvider =
            Provider.of<StoryProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        await storyProvider.addStory(
          authProvider.user!.token,
          _description,
          _image!.path,
          lat: _lat,
          lon: _lon,
        );
        await storyProvider.fetchStories(authProvider.user!.token,
            refresh: true);
        final routerDelegate =
            Router.of(context).routerDelegate as MyRouterDelegate;
        routerDelegate.showAddStory = false;
        routerDelegate.notifyListeners();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
    }
  }
}

import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../navigation/router_delegate.dart';
import '../providers/story_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  _AddStoryScreenState createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  XFile? _image;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.addStory),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
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
                ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(localizations.chooseImage),
                ),
                CustomTextField(
                  label: localizations.description,
                  onSaved: (value) => _description = value!,
                  validator: Validators.requiredValidator,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _submit(storyProvider, authProvider),
                  child: Text(localizations.submit)
                )
              ],
            ),
          ),
      )
    );
  }

  void _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    setState(() {
      _image = image;
    });
  }

  void _submit(StoryProvider storyProvider, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await storyProvider.addStory(authProvider.user!.token, _description, _image!.path);
        await storyProvider.fetchStories(authProvider.user!.token);
        final routerDelegate = Router.of(context).routerDelegate as MyRouterDelegate;
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
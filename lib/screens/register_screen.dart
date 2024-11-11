import 'package:dicoding_flutter_intermediate/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/router_delegate.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _email, _password, _passwordConfirmation;
  bool _isLoading = false;

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: AppBar(
          title: Text(localizations.register),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: localizations.name,
                      onSaved: (value) => _name = value!,
                      validator: Validators.requiredValidator,
                    ),
                    CustomTextField(
                      label: localizations.email,
                      onSaved: (value) => _email = value!,
                      validator: Validators.emailValidator,
                    ),
                    CustomTextField(
                      label: localizations.password,
                      controller: _passwordController,
                      onSaved: (value) => _password = value!,
                      validator: Validators.passwordValidator,
                      obscureText: true,
                    ),
                    CustomTextField(
                        label: localizations.passwordConfirmation,
                        onSaved: (value) => _passwordConfirmation = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password confirmation is required';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _submit(authProvider),
                      child: Text(localizations.register),
                    ),
                    TextButton(
                      onPressed: () {
                        final routerDelegate = Router.of(context).routerDelegate as MyRouterDelegate;
                        routerDelegate.login();
                      },
                      child: Text(localizations.login),
                    ),
                ],
              )
          ),
        )
    );
  }

  void _submit(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await authProvider.register(_name, _email, _password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful, please login')),
        );
        final routerDelegate = Router.of(context).routerDelegate as MyRouterDelegate;
        routerDelegate.showRegisterPage = false;
        routerDelegate.notifyListeners();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
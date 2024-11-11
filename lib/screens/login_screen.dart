import 'package:dicoding_flutter_intermediate/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/router_delegate.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password;
  bool _isLoading = false;

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.login),
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
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () => _submit(authProvider),
                    child: Text(localizations.login),
                ),
                TextButton(
                  onPressed: () {
                    final routerDelegate = Router.of(context).routerDelegate as MyRouterDelegate;
                    routerDelegate.showRegister();
                  },
                  child: Text(localizations.register),
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
        await authProvider.login(_email, _password);
        final routerDelegate = Router.of(context).routerDelegate as MyRouterDelegate;
        routerDelegate.login();
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
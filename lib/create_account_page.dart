import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty ||
        fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Create user in Supabase Auth
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        setState(() {
          _errorMessage =
              'Account created, but user data not immediately available. Check email for verification link if required.';
          _isLoading = false;
        });
      }

      final userId = user?.id;

      try {
        // Insert user info into the "profiles" table
        await _supabase.from('profiles').insert({
          'id': userId,
          'full_name': fullName,
          'username': username,
          'email': email,
          'contact_phone': phone,
        });

        // If the insert is successful (no exception thrown)
        setState(() {
          _successMessage = 'Account created successfully! You can now log in.';
          _isLoading = false;
        });
      } on PostgrestException catch (e) {
        // This catches specific database errors during the insert
        debugPrint('PostgrestException during profile insert: ${e.message}');
        setState(() {
          _errorMessage = 'Failed to save user info in database: ${e.message}';
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      debugPrint('AuthException during signup: ${e.message}');
      setState(() {
        _errorMessage = 'Auth error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      // This catches any other unexpected errors from the entire try block
      debugPrint('Unexpected error in signup process: $e');
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create a new account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter your username'
                              : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter your full name'
                              : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter your email'
                              : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter your phone number'
                              : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter your password'
                              : null,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _createAccount();
                            }
                          },
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Create Account'),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_successMessage != null) ...[
                  SizedBox(height: 16),
                  Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

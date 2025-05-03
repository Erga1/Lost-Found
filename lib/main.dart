import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'create_account_page.dart';
import 'forgot_password.dart';
import 'home.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sxhelolghkzputcggqiz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4aGVsb2xnaGt6cHV0Y2dncWl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2MzcyNjcsImV4cCI6MjA2NDIxMzI2N30.OUuwtgBekfGr_oQ9pfBHd00isJOz0ybAmTDQerRVOqE',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const LostFoundApp(),
    ),
  );
}

class LostFoundApp extends StatelessWidget {
  const LostFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost and Found App',
      themeMode: themeProvider.themeMode, // Use themeMode from ThemeProvider
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          bodyLarge: themeProvider.bodyTextStyle,
          bodyMedium: themeProvider.baseTextStyle,
          headlineSmall: themeProvider.headingTextStyle,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          bodyLarge: themeProvider.bodyTextStyle,
          bodyMedium: themeProvider.baseTextStyle,
          headlineSmall: themeProvider.headingTextStyle,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userInfo;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userInfo = null;
    });

    final email = _usernameController.text.trim(); // Assuming username is email
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Supabase Auth sign in with email
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        setState(() {
          _errorMessage = 'Login failed, please check your credentials.';
          _isLoading = false;
        });
        return;
      }

      final userId = response.user?.id;

      if (userId == null) {
        setState(() {
          _errorMessage = 'User  ID not found after login.';
          _isLoading = false;
        });
        return;
      }

      // Fetch user info from "profiles" table filtering by id
      final userInfoResponse =
          await _supabase
              .from('profiles')
              .select(
                'id, username, full_name, email, contact_phone, created_at',
              )
              .eq('id', userId)
              .maybeSingle();

      if (userInfoResponse == null) {
        setState(() {
          _errorMessage = 'User  info not found in profiles tazble.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _userInfo = Map<String, dynamic>.from(userInfoResponse);
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost-Found Login'),
        centerTitle: true,
        elevation: 6,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Login to your account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
              SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter your email'
                                  : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter your password'
                                  : null,
                    ),
                    SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,

                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage(),
                            ),
                          );
                        },

                        child: Text(
                          'Forgot Password?',

                          style: TextStyle(
                            color: Colors.indigo,

                            decoration: TextDecoration.underline,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _login();
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : Text('Login'),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateAccountPage(),
                          ),
                        );
                      },
                      child: Text('Create account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For setting the status bar color
import 'sign_up.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homepage.dart';
import 'package:another_flushbar/flushbar.dart';


void main() async{
  Supabase.initialize(url: 'https://qetahtmumilhqnsdnkde.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJ'
          'lZiI6InFldGFodG11bWlsaHFuc2Rua2RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTIy'
          'MDE2NzcsImV4cCI6MjAyNzc3NzY3N30.tYSbPumTY8MLHCjBLl4Uf4fZa2nOZ0MYFcjKmzpAs7E');

  final isLoggedIn = await isAuthenticated();
  runApp(MyApp(isLoggedIn: isLoggedIn));

}

final supabase = Supabase.instance.client;

Future<bool> isAuthenticated() async {
  final session = supabase.auth.currentSession;
  return session != null && session.user != null;
}



class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // Set the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      title: 'Flutter Login UI',
      theme: ThemeData(// Use dark theme for the entire app
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1), // Translucent white fill
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
      ),
      home: isLoggedIn ? HomePage() : LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final email = TextEditingController();
  final password = TextEditingController();
  bool _ispasswordobscured = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _ispasswordobscured = !_ispasswordobscured;
    });
  }

  void _attemptLogin() async {

        try {
          final AuthResponse res = await supabase.auth.signInWithPassword(
            email: email.text,
            password: password.text,
          );
          final Session? session = res.session;
          final User? user = res.user;

          final authSubscription = supabase.auth.onAuthStateChange.listen((data) {
            final AuthChangeEvent event = data.event;
            if (event == AuthChangeEvent.signedIn) {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()));
            }
          });
        }
        catch(e){
          Flushbar(
            title: 'Invalid login credentials',
            titleColor: Colors.white,
            message: '${e} error',
            messageColor: Colors.white,
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.red,
            margin: EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
            isDismissible: true,
            duration: Duration(seconds: 3),

          ).show(context);
        }
      }


  @override
  Widget build(BuildContext context) {
    return Scaffold(// Dark background color
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome to Your Password Manager',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black26,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: email,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'E-mail',
                      prefixIcon: Icon(Icons.email, color: Colors.blueGrey),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: password,
                    style: TextStyle(color: Colors.black),
                    obscureText: _ispasswordobscured,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.blueGrey),
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _ispasswordobscured ? Icons.visibility : Icons.visibility_off,
                          color: Colors.blueGrey,
                        ),
                      ),

                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      foregroundColor: Colors.white, // Text color
                      minimumSize: Size(double.infinity, 50), // Button size
                    ),
                    onPressed: () {
                      _attemptLogin();
                    },
                    child: Text('Login'),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Don’t have an account?', style: TextStyle(color: Colors.black38)),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpPage()));
                        },
                        child: Text('Sign Up', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

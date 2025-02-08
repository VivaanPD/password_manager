
import 'package:compsci_ia/password_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:email_validator/email_validator.dart';
import 'main.dart';
import 'homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      title: 'Flutter Sign Up UI',
      theme: ThemeData(

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
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final email = TextEditingController();
  final password = TextEditingController();
  final retry = TextEditingController();
  final master = TextEditingController();
  bool _ispasswordobscured = true;
  bool _isretryobscured = true;

  @override
  void dispose() {

    email.dispose();
    password.dispose();
    retry.dispose();
    master.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _ispasswordobscured = !_ispasswordobscured;
    });
  }

  // Function to toggle retry password visibility
  void _toggleRetryPasswordVisibility() {
    setState(() {
      _isretryobscured = !_isretryobscured;
    });
  }

  bool valid_email(String email) {
    final bool isValid = EmailValidator.validate(email);
    return isValid;
  }

  void _attemptSignUp() async {
    if (email.text != "" && valid_email(email.text)) {
      if (retry.text != password.text) {
        Flushbar(
          title: 'Credential error',
          titleColor: Colors.white,
          message: 'Your passwords do not match. Please try again',
          messageColor: Colors.white,
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          isDismissible: true,
          duration: Duration(seconds: 3),

        ).show(context);
      }
      else {
        try {
          final res = await supabase.auth.signUp(email: email.text,
              password: password.text,
              data: {'masterpass': master.text}
          );
          if (res.user != null) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()));
          }
        }
        catch(e){
          print("${e} did not sign up");
        }
      }
    }
    else {
      Flushbar(
        title: 'Invalid email',
        titleColor: Colors.white,
        message: 'Please enter a valid email address',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 60),
              const Text('Welcome To Your Password Manager',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black26,),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account',
                style: TextStyle(fontSize: 22.0),
              ),
              SizedBox(height: 30),
              TextField(
                controller: email,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: Icon(Icons.email, color: Colors.blueGrey),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              TextField(
                controller: retry,
                style: TextStyle(color: Colors.black),
                obscureText: _isretryobscured,
                decoration: InputDecoration(
                  hintText: 'Repeat password',
                  prefixIcon: Icon(Icons.lock, color: Colors.blueGrey),
                  suffixIcon: IconButton(
                    onPressed: _toggleRetryPasswordVisibility,
                    icon: Icon(
                      _isretryobscured ? Icons.visibility : Icons.visibility_off,
                      color: Colors.blueGrey,
                    ),
                ),
              ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: master,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Master Password',
                  prefixIcon: Icon(Icons.password, color: Colors.blueGrey),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  foregroundColor: Colors.white, // Text color
                  minimumSize: Size(double.infinity, 50), // Button size
                ),
                onPressed: _attemptSignUp,
                child: Text('Create an account'),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text(
                      'Go to Login Page',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}

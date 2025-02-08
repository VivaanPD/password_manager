import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'password_model.dart';
import 'main.dart';



class PasswordDetailPage extends StatefulWidget {
  final passwords password;

  const PasswordDetailPage({Key? key, required this.password}) : super(key: key);

  @override
  _PasswordDetailPageState createState() => _PasswordDetailPageState();
}

class _PasswordDetailPageState extends State<PasswordDetailPage> {
  bool masterPasswordAuthenticated = false;

  Future<void> deleteCredentials(BuildContext context) async {
    try{
      final response = await supabase
        .from('passwords')
        .delete()
        .match({'platform': widget.password.platform});


        Navigator.of(context).pop(widget.password.platform);
    } catch(e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting credentials: ${e}')),
      );
    }
  }

  Future<bool> verifyMasterPassword(String enteredPassword) async {
    final user = supabase.auth.currentUser;
    String masterpass = "oihdfasohiasfdoiihoadsihfoadshifoihasdfojviyvih";
    if (user != null) {
      masterpass = user.userMetadata!['masterpass'];
    }
    await Future.delayed(Duration(seconds: 1));
    return enteredPassword == masterpass;
  }


  Future<void> showPasswordDialog(BuildContext context) async {
    final _passwordController = TextEditingController();
    bool? isPasswordCorrect = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Master Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: false,
            decoration: InputDecoration(hintText: "Master Password"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final isCorrect = await verifyMasterPassword(_passwordController.text);
                Navigator.of(context).pop(isCorrect);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    if (isPasswordCorrect == true) {
      setState(() {
        masterPasswordAuthenticated = true;
      });
    }
    else {
      Flushbar(
        title: 'Credential error',
        titleColor: Colors.white,
        message: 'Your master password was incorrect',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.password.platform),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Username: ${widget.password.username}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              "Password: ${masterPasswordAuthenticated ? widget.password.password : '*******'}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20), // Add some spacing before the button
            IconButton(
              icon: Icon(
                masterPasswordAuthenticated ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                if (!masterPasswordAuthenticated) {
                  showPasswordDialog(context);
                } else {
                  setState(() {
                    masterPasswordAuthenticated = false;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => deleteCredentials(context),
              child: Text('Delete Credentials'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red color to signify a potentially destructive action
              ),
            ),
          ],
        ),
      ),
    );
  }
}
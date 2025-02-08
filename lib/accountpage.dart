import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;

  void _changeMasterPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      // Assuming 'masterpass' is stored in user metadata and it's secure to access it this way.
      final currentMasterPass = currentUser.userMetadata!['masterpass'];
      if (_currentPasswordController.text == currentMasterPass) {
        // Proceed to change password in Supabase metadata
        final response = await supabase.auth.updateUser(UserAttributes(
          data: {'masterpass': _newPasswordController.text},
        ));

         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Master password changed successfully.")));
          _currentPasswordController.clear();
          _newPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Current master password is incorrect.")));
      }
    }
    setState(() => _isLoading = false);
  }

  void _logout() {
    Supabase.instance.client.auth.signOut();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    // Define some muted colors
    const Color primaryColor = Color(0xFF78909C); // Muted blue
    const Color secondaryColor = Color(0xFFB0BEC5); // Light grey-blue
    const Color accentColor = Color(0xFFF48FB1); // Soft pink for logout button

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Change Master Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Master Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fillColor: secondaryColor.withAlpha(30),
                  filled: true,
                ),
                obscureText: false,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your current master password' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Master Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fillColor: secondaryColor.withAlpha(30),
                  filled: true,
                ),
                obscureText: false,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a new master password' : null,
              ),
              SizedBox(height: 32),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _changeMasterPassword,
                child: Text('Change Master Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _logout,
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor, // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
import 'package:compsci_ia/main.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'constants.dart';



class AddModal extends StatefulWidget {
  const AddModal({Key? key}) : super(key: key);

  @override
  _AddModalState createState() => _AddModalState();
}

class _AddModalState extends State<AddModal> {
  final TextEditingController platformController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {

    platformController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }



  Future<void> addUserCredential() async {
      await supabase
          .from(
          'passwords')
          .insert({
        'platform': platformController.text,
        'username': usernameController.text,
        'password': passwordController.text,
        'user_id': supabase.auth.currentUser!.id,
      });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
      child: Column(
        children: [
          SizedBox(height: 10),
          Column(
            children: [
              formHeading("Platform"),
              formTextField("Enter Platform Name", Icons.person, platformController),
              formHeading("Username"),
              formTextField("Enter Username", Icons.email, usernameController),
              formHeading("Password"),
              formTextField("Enter Password", Icons.lock_outline, passwordController),
            ],
          ),
          SizedBox(height: 50),
          Container(
            height: screenHeight * 0.065,
            width: screenWidth * 0.7,
            child: ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStatePropertyAll(5),
                shadowColor: MaterialStatePropertyAll(Constants.buttonBackground),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    side: BorderSide(color: Constants.buttonBackground),
                  ),
                ),
                backgroundColor: MaterialStatePropertyAll(Constants.buttonBackground),
              ),
              onPressed: () {
                addUserCredential();
                // Here, you can access the text from the controllers
                // For example, print(platformController.text);
                Navigator.pop(context);
              },
              child: Text(
                "Add Password",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget formTextField(String hintText, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller, // Use the passed controller
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
            child: Icon(icon, color: Constants.searchGrey),
          ),
          filled: true,
          contentPadding: EdgeInsets.all(16),
          hintText: hintText,
          hintStyle: TextStyle(color: Constants.searchGrey, fontWeight: FontWeight.w500),
          fillColor: Color.fromARGB(247, 232, 235, 237),
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 0, style: BorderStyle.none),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget formHeading(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 10),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';



class PasswordGeneratorPage extends StatefulWidget {
  @override
  _PasswordGeneratorPageState createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  // Initial values for sliders
  double _passwordLength = 8;
  double _passwordStrength = 1; // 1 to 4, where 1 is the weakest and 4 is the strongest
  String _generatedPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Length: ${_passwordLength.toInt()}'),
            Slider(
              min: 8,
              max: 20,
              divisions: 12,
              value: _passwordLength,
              label: _passwordLength.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _passwordLength = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Strength: ${_passwordStrength.toInt()}'),
            Slider(
              min: 1,
              max: 4,
              divisions: 3,
              value: _passwordStrength,
              label: _passwordStrength.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _passwordStrength = value;
                });
              },
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _generatedPassword = generatePassword(_passwordLength.toInt(), _passwordStrength.toInt());
                });
              },
              child: Text('Generate Password'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  _generatedPassword,
                  style: TextStyle(fontSize: 24),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: _generatedPassword.isNotEmpty ? () {
                    Clipboard.setData(ClipboardData(text: _generatedPassword));
                    final snackBar = SnackBar(
                      content: Text('Password copied to clipboard!'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  String generatePassword(int length, int strength) {
    const String lowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    const String upperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String specialCharacters = '!@#\$%^&*(),.?":{}|<>';

    String chars = '';
    chars += lowerCaseLetters;
    if (strength > 1) chars += upperCaseLetters;
    if (strength > 2) chars += upperCaseLetters + numbers;
    if (strength > 3) chars += upperCaseLetters + numbers + specialCharacters;

    return List.generate(length, (index) {
      final indexRandom = Random.secure().nextInt(chars.length);
      return chars[indexRandom];
    }).join('');
  }
}

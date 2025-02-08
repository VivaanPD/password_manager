import 'package:compsci_ia/accountpage.dart';
import 'package:compsci_ia/password_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'AddModal.dart';
import 'constants.dart';
import 'package:compsci_ia/sign_up.dart';
import 'main.dart';
import 'password_generator.dart';
import 'passwordpage.dart';

void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<passwords> passwordList = [];
  List<passwords> filteredPasswordList = [];
  bool masterPasswordAuthenticated = false;
  final TextEditingController searchController = TextEditingController();

  void loadPasswords() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {final response = await supabase
          .from('passwords')
          .select()
          .eq('user_id', user.id);


          setState(() {
            passwordList = List<passwords>.from(
              response.map((item) => passwords.fromMap(item)),
          );
          filteredPasswordList = passwordList;
        });
      } catch(e) {
        // Handle or log error
        print('Error loading passwords: ${e}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadPasswords();
    subscribeToInsertEvents();
    searchController.addListener(_updateSearchResults);
    filteredPasswordList = passwordList;
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _updateSearchResults() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPasswordList = passwordList.where((password) {
        return password.platform.toLowerCase().contains(query) ||
            password.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  void subscribeToInsertEvents() {
    supabase
        .channel('public:passwords')
        .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'passwords',
        callback: (payload) {
          print('Change received: ${payload.toString()}');
          final newPassword = passwords.fromMap(payload.newRecord);
          setState(() {
            passwordList.add(newPassword);
          });
        })
        .subscribe();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          onPressed: () {
            bottomModal(context);
          },
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            child: SizedBox(
                height: 60,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => AccountPage()),
                            );
                          },
                          icon: Icon(Icons.person)),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(Icons.generating_tokens),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => PasswordGeneratorPage()),
                          );
                        },
                      ),
                    ]))),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                searchText("Search Password"),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                HeadingText("Your Passwords"),
                SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredPasswordList.length,
                  itemBuilder: (context, index) {
                    final password = filteredPasswordList[index];
                    return PasswordTile(password, context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget PasswordTile(passwords password, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PasswordDetailPage(password: password),
          ),
        ).then((result) {

          if (result != null) {

            setState(() {

              passwordList.removeWhere((item) => item.platform == result);
              filteredPasswordList = passwordList;
            });
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              password.platform,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 22, 22, 22),
                fontSize: 18,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Tap to view details",
              style: TextStyle(
                color: Color.fromARGB(255, 39, 39, 39),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget HeadingText(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 0),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }



  Widget searchText(String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 5, 5, 5),
              child: Icon(
                Icons.search,
                color: Constants.searchGrey,
              ),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(16),
            hintText: hintText,
            hintStyle: TextStyle(
                color: Constants.searchGrey, fontWeight: FontWeight.w500),
            fillColor: Color.fromARGB(247, 232, 235, 237),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(20))),
        style: TextStyle(),
      ),
    );
  }

  Future<dynamic> bottomModal(BuildContext context) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[
            Container(
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors
                        .white, //forDialog ? Color(0xFF737373) : Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0))),
                child: AddModal(),
              ),
            )
          ]);
        });
  }

}

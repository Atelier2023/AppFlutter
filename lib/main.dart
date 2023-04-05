import 'dart:convert';

import 'package:app_flutter/signIn.dart';
import 'package:app_flutter/signUp.dart';
import 'package:app_flutter/addEvent.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:http/http.dart' as http;
import 'package:localstore/localstore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = Localstore.instance; 

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RéunionousApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = Localstore.instance; 
  late bool authenticated = false;

    List<String> events = [
  ];

Future<void> _getEvents() async {

  final db = Localstore.instance;
  final storeid = await db.collection('store').doc('store').get();
  final idUser = storeid!['id'];
  

    try {
      final response = await http.get(Uri.parse('http://localhost:19106/events/getEvent/${idUser}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode == 200) {
        setState(() {
         events = List<String>.from(json.decode(response.body).map((x) => x.toString()));
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  void _handleLoginPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }
  void _handleRegisterPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  void _addEventPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEventForm()),
    );
  }

  void _handleLogoutPressed() async{
    await db.collection('store').doc('store').set({"authenticated": false});
      
    setState(() {
      authenticated = false;
    });
  }

  void _loadIsLoggedIn() async {
    final data = await db.collection('store').doc('store').get();

    print(data);
    if (data == null) {
      authenticated = false;
    } else {
      authenticated = data['authenticated'] ? true : false;
    }

    setState(() {
      authenticated = authenticated;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadIsLoggedIn();
    _getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20), // Espacement
            authenticated 
            ? Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(events[index]),
                    );
                  },
                ),
              ) 
            : const Text('Contenu de votre page'),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              authenticated
            ? Row(
                children: [
                  ElevatedButton(
                    onPressed: _addEventPressed,
                    child: const Text('Créer un événement'),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: _handleLogoutPressed,
                    child: const Text('Se déconnecter'),
                  ),
                ],
              )
                  : Row(
                    children: [ 
                      ElevatedButton(
                        onPressed: _handleLoginPressed,
                        child: const Text('Se connecter'),
                      ),
                      ElevatedButton(
                        onPressed: _handleRegisterPressed,
                        child: const Text('S\'inscrire'),
                      ),
                    ],
                  ), 
              const SizedBox(width: 10.0),
              
            ],
          ),
        ),
      ),
    );
  }
}

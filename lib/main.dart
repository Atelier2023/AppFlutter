import 'dart:convert';

import 'package:app_flutter/sharedEventEmail.dart';
import 'package:app_flutter/signIn.dart';
import 'package:app_flutter/signUp.dart';
import 'package:app_flutter/addEvent.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      final response = await http.get(
        Uri.parse('http://localhost:19106/events/getEvent/${idUser}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          events = List<String>.from(data.map((x) => '${x['title']} - ${x['date_event']} - ${x['address']} - ${x['is_before']} - ${x['is_after']} - ${x['state']} - ${x['shared_url']}' as String));
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

  void _addEventPressed() async {
    final data = await db.collection('store').doc('store').get();

    var refresh_token;
    await http.get(
      Uri.parse('http://localhost:19106/users/validate'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + data!["token"],
      }).then(
        (response) => {
          if (response.statusCode == 200) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEventForm()),
            )
          },
        (error) => {
          if (error.response.statusCode == 401) {
            http.get(
              Uri.parse('http://localhost:19106/users/getRefresh/' + data!["id"]),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
            }).then((response) => {
              refresh_token = jsonDecode(response.body)['refresh_token'],

              http.post(
                Uri.parse('http://localhost:19106/users/refresh'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer ' + refresh_token,
                }).then((response) => {
                  db.collection('store').doc('store').set({
                    "token": jsonDecode(response.body)['accesstoken']
                  }),

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEventForm()),
                  )
                }).catchError((error) => {
                  print(error)
                }) 
            })
          }
        }
      });
  }

  void _sharedURL() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SharedEventEmail()),
    );
  }

  void _handleLogoutPressed() async {
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
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Titre')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Adresse')),
            DataColumn(label: Text('Avant')),
            DataColumn(label: Text('Après')),
            DataColumn(label: Text('Statut')),
            DataColumn(label: Text('Lien de partage')),
          ],
          rows: events.map((event) {
            final eventFields = event.split(' - ');
            return DataRow(cells: [
              DataCell(Text(eventFields[0])),
              DataCell(Text(eventFields[1])),
              DataCell(Text(eventFields[2])),
              DataCell(Text(eventFields[3])),
              DataCell(Text(eventFields[4])),
              DataCell(Text(eventFields[5])),
              DataCell(Text(eventFields[6])),
            ]);
          }).toList(),
        ),
      ) 
      : const Text('Veuillez vous connecter'),
    ],
  ),
),
      floatingActionButton: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                ElevatedButton(
                  onPressed: _sharedURL,
                  child: const Text('shared URL'),
              ),

              authenticated
            ? Row(
                children: [
                  const SizedBox(width: 10.0),
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
                      const SizedBox(width: 10.0),
                      ElevatedButton(
                        onPressed: _handleLoginPressed,
                        child: const Text('Se connecter'),
                      ),
                      const SizedBox(width: 10.0),
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

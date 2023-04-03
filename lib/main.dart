import 'package:app_flutter/signIn.dart';
import 'package:app_flutter/signUp.dart';
import 'package:flutter/material.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = Localstore.instance; 
  late bool authenticated = false;

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

  void _handleLogoutPressed() async{
    await db.collection('store').doc('store').set({"authenticated": false});
      
    setState(() {
      authenticated = false;
    });
  }

  void _loadIsLoggedIn() async {
    final data = await db.collection('store').doc('store').get();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20), // Espacement
            authenticated
            ? ElevatedButton(
                onPressed: _handleLogoutPressed,
                child: const Text('Se déconnecter'),
              )
            : Column(
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
          ],
        ),
      ),
    );
  }
}

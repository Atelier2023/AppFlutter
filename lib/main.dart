import 'package:app_flutter/signIn.dart';
import 'package:app_flutter/signUp.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:localstore/localstore.dart';
import 'package:flutter_map/flutter_map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
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
  Position? position = Position(longitude: 6.1792289, latitude: 48.6837223, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0, heading: 0, speed: 1, speedAccuracy: 1);

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

  Future<void> _getDeviceLocation() async {
    try {
      Position newPosition = await _determinePosition();
      setState(() {
        position = newPosition;
      });
    } catch (e) {
      print (e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getDeviceLocation();
    _loadIsLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          minZoom: 9.0,
          maxZoom: 18.0,
          center: LatLng(position!.latitude, position!.longitude),
          zoom: 13,
          interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
        nonRotatedChildren: [
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap contributors',
            onSourceTapped: null,
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              authenticated
                  ? ElevatedButton(
                      onPressed: _handleLogoutPressed,
                      child: const Text('Se déconnecter'),
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

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  return await Geolocator.getCurrentPosition();
}
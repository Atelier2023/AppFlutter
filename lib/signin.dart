import 'package:app_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstore/localstore.dart';


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String _email = '';
  String _password = '';

  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String basicAuth = 'Basic ${base64.encode(utf8.encode('$_email:$_password'))}';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await http.post(
        Uri.parse('http://localhost:19102/users/signin'),
        headers: <String, String>{'authorization': basicAuth},
      ).then((response) {
        if (response.statusCode == 201) {
          return json.decode(response.body);
        } else {
          throw Exception("Echec de connexion.");
        }
      }).then((jsonData) async {
        final db = Localstore.instance;
        
        await db.collection('store').doc('store').set({
          "authenticated": true,
          "id": jsonData['id_user'],
          "email": jsonData['email'],
          "username": jsonData['user'],
          "tel_number": jsonData['tel'],
          "token": jsonData['accesstoken'],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous êtes connecté !'))
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur est survenue.'))
        );
      }).whenComplete(() => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  } else if (!(value?.contains('@') ?? false)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                ),
                obscureText: true,
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
                }, 
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:app_flutter/signIn.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;
  String? _address;
  String? _telNumber;
  String? _nickname;

  Future<bool> _checkEmail() async {
    final response = await http.post(
      Uri.parse('http://10.1.1.1:19102/users/check-email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': _email
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get data.');
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      if (await _checkEmail()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adresse mail déjà utilisée !'))
        );
      } else {
        await http.post(
          Uri.parse('http://10.1.1.1:19102/users/create'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "firstname": _nickname!,
            "email": _email!,
            "password": _password!,
            "tel_number": _telNumber!
          }),
        ).then((response) => {
            if (response.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Utilisateur créé !'))
              ),
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              )
            }
        }).catchError((error) => {
          throw Exception(error)
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("S'inscrire"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Surnom',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer un surnom';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _nickname = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer un email';
                  } else if (!(value?.contains('@') ?? false)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  } else if (value.length < 8) {
                    return 'Le mot de passe doit avoir une longueur de 8 caractères minimum';
                  }

                  return null;
                }, 
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!value!.isEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Veuillez entrer un numéro de téléphone valide';
                  }
                  if (!value!.isEmpty && value.length < 4) {
                    return 'Veuillez entrer un numéro de téléphone valide';
                  }
                  if (!value!.isEmpty && value.length > 12) {
                    return 'Veuillez entrer un numéro de téléphone valide';
                  }

                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _telNumber = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submit,
                child: Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
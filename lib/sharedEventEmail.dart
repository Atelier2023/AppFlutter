import 'dart:convert';

import 'package:app_flutter/main.dart';
import 'package:app_flutter/sharedEvent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SharedEventEmail extends StatefulWidget {
  const SharedEventEmail({Key? key}) : super(key: key);

  @override
  _SharedEventEmailState createState() => _SharedEventEmailState();
}

class _SharedEventEmailState extends State<SharedEventEmail> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _email;
  int? id_participant;

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      await http.post(
        Uri.parse('http://localhost:19100/participants/get/email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          "email": _email!
        })
      ).then((response) => {
        setState(() {
          id_participant = jsonDecode(response.body)[0]['id_participant'];
        })
      });

      await http.post(
        Uri.parse('http://localhost:19100/events/shared/email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          "email": _email!
        })
      ).then((response) => {
        setState(() {
          _isLoading = false;
        }),
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vous avez rejoint le rendez-vous !'))
        ),
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SharedEvent(
            sharedUrl: jsonDecode(response.body)[0]["shared_url"],
            idParticipant: id_participant!
          )),
        )
      }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Une erreur est survenue.')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Ce champ ne peut pas être vide.';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Envoyer'),
              ),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

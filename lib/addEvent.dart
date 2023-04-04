import 'package:app_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstore/localstore.dart';

class AddEventForm extends StatefulWidget {
  @override
  _AddEventFormState createState() => _AddEventFormState();
}

class _AddEventFormState extends State<AddEventForm> {
  final _formKey = GlobalKey<FormState>();
  String? _title = '';
  DateTime? _date = DateTime.now();
  String? _address = '';

  bool _isLoading = false;

  void _submitForm() async {
    final db = Localstore.instance;
    final storeid = await db.collection('store').doc('store').get();
    final idUser = storeid!['id'];

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      await http
          .post(
            Uri.parse('http://localhost:19100/events/create'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              "title": _title!,
              "date_event": _date?.toIso8601String(),
              "address": _address!,
              "id_user": idUser,
            }),
          )
          .then((response) => {
            setState(() {
              _isLoading = false;
            }),
                if (response.statusCode == 201)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Evénement créé !'))),
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    )
                  }
              })
          .catchError((error) => {throw Exception(error)});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un événement'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Titre',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le titre est requis';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _title = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _date!,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _date = selectedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_date!.day}/${_date!.month}/${_date!.year}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Adresse',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'adresse est requise';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _address = value;
                      });
                    },
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Ajouter'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

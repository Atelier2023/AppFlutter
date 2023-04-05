// import 'dart:convert';

// import 'package:app_flutter/main.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class SharedEvent extends StatefulWidget {
//   const SharedEvent({Key? key}) : super(key: key);

//   @override
//   _SharedEventState createState() => _SharedEventState();
// }

// class _SharedEventState extends State<SharedEvent> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   String? _email;

//   void _submit() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() {
//         _isLoading = true;
//       });

//       await http
//         .get(
//           Uri.parse('http://localhost:19100/events/shared/email/' + _email),
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//           },
//         )
//         .then((response) => {
//               http.post(
//                 Uri.parse('http://localhost:19100/participants/create'),
//                 headers: <String, String>{
//                   'Content-Type': 'application/json; charset=UTF-8',
//                 },
//                 body: jsonEncode(<String, dynamic>{
//                   "name": _name,
//                   "firstname": _firstname,
//                   "tel_number": _telNumber,
//                   "state": _selected.toString().split('.').last,
//                   "id_event": jsonDecode(response.body)['id_event']
//                 }),
//               ),

//               setState(() {
//                 _isLoading = false;
//               }),
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Vous avez rejoint le rendez-vous !'))
//               ),
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => MyApp()),
//               )
//             })
//         .catchError((error) {
//           ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Une erreur est survenue.')));
//         });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: <Widget>[
//               TextFormField(
//                 decoration: const InputDecoration(
//                   hintText: 'Nom',
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Ce champ ne peut pas être vide.';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     _name = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 decoration: const InputDecoration(
//                   hintText: 'Prénom',
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Ce champ ne peut pas être vide.';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     _firstname = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 decoration: const InputDecoration(
//                   hintText: 'Numéro de téléphone',
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Ce champ ne peut pas être vide.';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     _telNumber = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<Selection>(
//                 decoration: const InputDecoration(
//                   hintText: 'Sélectionnez une option',
//                 ),
//                 validator: (value) {
//                   if (value == null) {
//                     return 'Veuillez sélectionner une option.';
//                   }
//                   return null;
//                 },
//                 value: _selected,
//                 items: Selection.values.map((selection) {
//                   return DropdownMenuItem<Selection>(
//                     value: selection,
//                     child: Text(selection.toString().split('.').last),
//                   );
//                 }).toList(),
//                 onChanged: (selection) {
//                   setState(() {
//                     _selected = selection;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _submit,
//                 child: Text('Envoyer'),
//               ),
//               if (_isLoading) const CircularProgressIndicator(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum Selection {
//   present,
//   missing,
//   not_answered
// }
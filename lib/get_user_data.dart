// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetData extends StatelessWidget {
  final String DocumentId;

  const GetData({super.key, required this.DocumentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(DocumentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Text('${data['first name']}' +
              ' ' +
              '${data['last name']}' +
              ' ' +
              '${data['age']}' +
              '  years old');
        } else {
          return Text('Loading...');
        }
      },
    );
  }
}

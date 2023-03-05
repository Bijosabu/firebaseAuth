// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:firebaseauth/get_user_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  List<String> docIds = [];
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('age', descending: true)
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              // print(document.reference);
              docIds.add(document.reference.id);
            }));
  }

  void _deleteUser(String docId) async {
    // First, delete the user from Firebase Authentication
    showDialog(
      context: context,
      builder: (context) {
        // Show the dialog box
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Deleting User...'),
            ],
          ),
        );
      },
    );

// Wait for 3 seconds
    await Future.delayed(Duration(seconds: 3));

// Pop the dialog box
    Navigator.of(context).pop();

    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } catch (e) {
      print('Failed to delete user from Firebase Authentication: $e');
      return;
    }

    // If the user was deleted from Firebase Authentication successfully, delete the user from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(docId)
        .delete()
        .then((value) {
      // Update the state after deleting the user
      setState(() {
        docIds.remove(docId);
      });
      print("User deleted successfully");
    }).catchError((error) {
      print("Failed to delete user from Firestore: $error");
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        title: Text(
          user.email!,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          GestureDetector(
            child: Icon(Icons.logout),
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) {
                  // Show the dialog box
                  return AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Signing out...'),
                      ],
                    ),
                  );
                },
              );

// Wait for 3 seconds
              await Future.delayed(Duration(seconds: 3));

// Pop the dialog box
              Navigator.of(context).pop();
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Current Users',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: getDocId(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: docIds.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: GetData(DocumentId: docIds[index]),
                          tileColor: Colors.grey[200],
                          trailing: GestureDetector(
                            onTap: () {
                              _deleteUser(docIds[index]);
                            },
                            child: Icon(
                              Icons.delete,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class GetData extends StatelessWidget {
//   final String DocumentId;

//   const GetData({super.key, required this.DocumentId});

//   @override
//   Widget build(BuildContext context) {
//     CollectionReference users = FirebaseFirestore.instance.collection('users');
//     return FutureBuilder<DocumentSnapshot>(
//       future: users.doc(DocumentId).get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           Map<String, dynamic> data =
//               snapshot.data!.data() as Map<String, dynamic>;
//           return Text('${data['first name']}');
//         } else {
//           return Text('Loading...');
//         }
//       },
//     );
//   }
// }

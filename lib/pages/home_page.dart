import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

// firestore service
  final FirestoreService firestoreService = FirestoreService();

// text controller
  final TextEditingController _textEditingController = TextEditingController();

// open model
  void openModel({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 22, 33, 50),
        title: Text(
          docID == null ? "Add note" : "Update note",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _textEditingController,
          maxLines: 8,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (_textEditingController.text.trim().isNotEmpty) {
                if (docID == null) {
                  firestoreService.addNote(_textEditingController.text);
                } else {
                  firestoreService.updateNote(
                      docID, _textEditingController.text);
                }
              }
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text(docID == null ? "Add" : "Update"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 38, 45, 56),
      appBar: AppBar(
        title: Text("${user.displayName?.split(" ").first}'s Notes"),
        backgroundColor: const Color.fromARGB(255, 22, 33, 50),
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
              onTap: () async {
                HapticFeedback.heavyImpact();
                await GoogleSignIn().disconnect();
                await FirebaseAuth.instance.signOut();
              },
              child: const Icon(Icons.logout_rounded)),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.size > 0) {
            List notesList = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot = notesList[index];
                  String docID = documentSnapshot.id;

                  Map<String, dynamic> data =
                      documentSnapshot.data() as Map<String, dynamic>;

                  String note = data['note'];
                  String timestamp = DateFormat.yMMMd()
                      .add_jm()
                      .format(data['timestamp'].toDate());

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  timestamp,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  openModel(docID: docID);
                                },
                                child: const Icon(Icons.edit),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  HapticFeedback.mediumImpact();
                                  firestoreService.deleteNote(docID);
                                },
                                child: const Icon(Icons.delete),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text(
                "Add some notes!!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 22, 33, 50),
        onPressed: () {
          HapticFeedback.mediumImpact();
          openModel();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection("users");

  // add new note
  Future<void> addNote(String note) {
    final user = FirebaseAuth.instance.currentUser!;
    return notes.doc(user.email).collection("notes").doc().set({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // read
  Stream<QuerySnapshot> getNotes() {
    final user = FirebaseAuth.instance.currentUser!;
    return notes
        .doc(user.email)
        .collection("notes")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // update
  Future<void> updateNote(String docID, String note) {
    final user = FirebaseAuth.instance.currentUser!;
    return notes.doc(user.email).collection("notes").doc(docID).update({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // delete
  Future<void> deleteNote(String docID) {
    final user = FirebaseAuth.instance.currentUser!;
    return notes.doc(user.email).collection("notes").doc(docID).delete();
  }
}

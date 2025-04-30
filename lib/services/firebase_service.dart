import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth methods
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Firestore methods
  Future<void> addInvoice(Map<String, dynamic> invoiceData) async {
    try {
      await _firestore.collection('invoices').add(invoiceData);
    } catch (e) {
      throw Exception('Failed to add invoice: $e');
    }
  }

  Stream<QuerySnapshot> getInvoices() {
    return _firestore
        .collection('invoices')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> updateInvoice(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('invoices').doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await _firestore.collection('invoices').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }

  // Storage methods
  Future<String> uploadFile(String path, List<int> bytes) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
} 
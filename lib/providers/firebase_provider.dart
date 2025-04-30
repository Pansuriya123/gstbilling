import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class FirebaseProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firebaseService.signIn(email, password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firebaseService.signUp(email, password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _setError(null);
    try {
      await _firebaseService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addInvoice(Map<String, dynamic> invoiceData) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firebaseService.addInvoice(invoiceData);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Stream<QuerySnapshot> getInvoices() {
    return _firebaseService.getInvoices();
  }

  Future<void> updateInvoice(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firebaseService.updateInvoice(id, data);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteInvoice(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firebaseService.deleteInvoice(id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<String> uploadFile(String path, List<int> bytes) async {
    _setLoading(true);
    _setError(null);
    try {
      return await _firebaseService.uploadFile(path, bytes);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteFile(String path) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firebaseService.deleteFile(path);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
} 
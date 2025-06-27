// providers/loan_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _daftarPinjaman = [];
  List<Map<String, dynamic>> get daftarPinjaman => _daftarPinjaman;

  /// Load semua data dari Firestore
  Future<void> loadPinjaman() async {
    try {
      final snapshot = await _firestore.collection('peminjaman').get();
      _daftarPinjaman = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // simpan id dokumennya
        return data;
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadPinjaman: $e');
    }
  }

  /// Tambah data ke Firestore
  Future<void> tambahPinjaman(Map<String, dynamic> pinjaman) async {
    try {
      final docRef = await _firestore.collection('peminjaman').add(pinjaman);
      pinjaman['id'] = docRef.id;
      _daftarPinjaman.add(pinjaman);
      notifyListeners();
    } catch (e) {
      debugPrint('Error tambahPinjaman: $e');
    }
  }

  /// Edit status peminjaman
  Future<void> editStatus(String id, String newStatus) async {
    try {
      await _firestore.collection('peminjaman').doc(id).update({
        'status': newStatus,
      });

      final index = _daftarPinjaman.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _daftarPinjaman[index]['status'] = newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error editStatus: $e');
    }
  }

  /// Hapus pinjaman dari Firestore
  Future<void> deletePinjaman(String id) async {
    try {
      await _firestore.collection('peminjaman').doc(id).delete();
      _daftarPinjaman.removeWhere((item) => item['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deletePinjaman: $e');
    }
  }

  /// Clear semua list lokal (bukan Firestore)
  void clearLocalList() {
    _daftarPinjaman.clear();
    notifyListeners();
  }
}

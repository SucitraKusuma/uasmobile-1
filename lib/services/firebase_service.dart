import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get peminjamanCollection =>
      _firestore.collection('peminjaman');

  // Get all loans
  Future<List<Map<String, dynamic>>> getAllLoans() async {
    try {
      final snapshot = await peminjamanCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting loans: $e');
      return [];
    }
  }

  // Get loan by ID
  Future<Map<String, dynamic>?> getLoanById(String id) async {
    try {
      final doc = await peminjamanCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting loan by ID: $e');
      return null;
    }
  }

  // Add new loan
  Future<String?> addLoan(Map<String, dynamic> loanData) async {
    try {
      final docRef = await peminjamanCollection.add(loanData);
      return docRef.id;
    } catch (e) {
      print('Error adding loan: $e');
      return null;
    }
  }

  // Update loan
  Future<bool> updateLoan(String id, Map<String, dynamic> updates) async {
    try {
      await peminjamanCollection.doc(id).update(updates);
      return true;
    } catch (e) {
      print('Error updating loan: $e');
      return false;
    }
  }

  // Delete loan
  Future<bool> deleteLoan(String id) async {
    try {
      await peminjamanCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting loan: $e');
      return false;
    }
  }

  // Search loans by name
  Future<List<Map<String, dynamic>>> searchLoansByName(
      String searchTerm) async {
    try {
      final snapshot = await peminjamanCollection
          .where('namaBarang', isGreaterThanOrEqualTo: searchTerm)
          .where('namaBarang', isLessThan: searchTerm + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error searching loans: $e');
      return [];
    }
  }

  // Get loans by status
  Future<List<Map<String, dynamic>>> getLoansByStatus(String status) async {
    try {
      final snapshot =
          await peminjamanCollection.where('status', isEqualTo: status).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting loans by status: $e');
      return [];
    }
  }

  // Real-time listener
  Stream<List<Map<String, dynamic>>> getLoansStream() {
    return peminjamanCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}

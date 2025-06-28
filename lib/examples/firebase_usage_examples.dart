import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class FirebaseUsageExamples extends StatefulWidget {
  const FirebaseUsageExamples({super.key});

  @override
  State<FirebaseUsageExamples> createState() => _FirebaseUsageExamplesState();
}

class _FirebaseUsageExamplesState extends State<FirebaseUsageExamples> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _loans = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  // Contoh 1: Load semua data
  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    try {
      final loans = await _firebaseService.getAllLoans();
      setState(() {
        _loans = loans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Contoh 2: Tambah data baru
  Future<void> _addNewLoan() async {
    final newLoan = {
      'namaBarang': 'Laptop Dell',
      'dipinjamOleh': 'John Doe',
      'status': 'dipinjam',
      'tanggalPinjam': '15 Dec 2024',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final id = await _firebaseService.addLoan(newLoan);
      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil ditambahkan!')),
        );
        _loadLoans(); // Refresh data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Contoh 3: Update data
  Future<void> _updateLoan(String id) async {
    final updates = {
      'status': 'dikembalikan',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    try {
      final success = await _firebaseService.updateLoan(id, updates);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diupdate!')),
        );
        _loadLoans(); // Refresh data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Contoh 4: Hapus data
  Future<void> _deleteLoan(String id) async {
    try {
      final success = await _firebaseService.deleteLoan(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil dihapus!')),
        );
        _loadLoans(); // Refresh data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Contoh 5: Search data
  Future<void> _searchLoans(String searchTerm) async {
    try {
      final results = await _firebaseService.searchLoansByName(searchTerm);
      setState(() {
        _loans = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Contoh 6: Filter by status
  Future<void> _filterByStatus(String status) async {
    try {
      final results = await _firebaseService.getLoansByStatus(status);
      setState(() {
        _loans = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Usage Examples'),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _addNewLoan,
                  child: const Text('Tambah Data'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _filterByStatus('dipinjam'),
                  child: const Text('Filter Dipinjam'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _filterByStatus('dikembalikan'),
                  child: const Text('Filter Dikembalikan'),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  _loadLoans(); // Reset to all data
                } else {
                  _searchLoans(value);
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // Data list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _loans.length,
                    itemBuilder: (context, index) {
                      final loan = _loans[index];
                      return ListTile(
                        title: Text(loan['namaBarang'] ?? ''),
                        subtitle: Text('Oleh: ${loan['dipinjamOleh'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(loan['status'] ?? ''),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateLoan(loan['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteLoan(loan['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// menuUtama.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_loan_screen.dart';
import 'detail_screen.dart';
import 'providers/loan_provider.dart';
import 'profile.dart';

class MenuUtama extends StatefulWidget {
  const MenuUtama({super.key});

  @override
  State<MenuUtama> createState() => _MenuUtamaState();
}

class _MenuUtamaState extends State<MenuUtama> {
  int _selectedIndex = 1;

  // Tambahan untuk pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<LoanProvider>(context, listen: false).loadPinjaman());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildProfile() {
    return const Center(
      child: Text(
        'Profile User (akan diimplementasikan)',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProvider>(
      builder: (context, loanProvider, _) {
        final daftarPinjaman = loanProvider.daftarPinjaman;

        // Filter berdasarkan pencarian
        final filteredPinjaman = _searchQuery.isEmpty
            ? daftarPinjaman
            : daftarPinjaman.where((pinjaman) {
                final namaBarang =
                    (pinjaman['namaBarang'] ?? pinjaman['nama_barang'] ?? '')
                        .toString()
                        .toLowerCase();
                final peminjam =
                    (pinjaman['dipinjamOleh'] ?? pinjaman['peminjam'] ?? '')
                        .toString()
                        .toLowerCase();
                final query = _searchQuery.toLowerCase();
                return namaBarang.contains(query) || peminjam.contains(query);
              }).toList();

        final _pages = [
          const AddLoanScreen(),
          Scaffold(
            appBar: AppBar(
              title: const Text('Manajemen Peminjaman Barang',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue[900],
              automaticallyImplyLeading: false,
              centerTitle: true,
            ),
            body: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Widget pencarian
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama barang atau peminjam...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredPinjaman.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada data peminjaman.',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredPinjaman.length,
                            itemBuilder: (context, index) {
                              final pinjaman = filteredPinjaman[index];
                              return Card(
                                elevation: 2,
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(
                                    pinjaman['namaBarang'] ??
                                        pinjaman['nama_barang'] ??
                                        '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Oleh: ${pinjaman['dipinjamOleh'] ?? pinjaman['peminjam'] ?? ''}'),
                                  trailing: Text(
                                    pinjaman['status'],
                                    style: TextStyle(
                                      color: pinjaman['status'] == 'Dipinjam' ||
                                              pinjaman['status'] == 'dipinjam'
                                          ? Colors.orange
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetailScreen(loan: pinjaman),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const ProfilePage(),
        ];

        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box),
                label: 'Tambah',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Daftar Pinjam',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

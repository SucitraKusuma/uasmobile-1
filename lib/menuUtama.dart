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
              child: daftarPinjaman.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada data peminjaman.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: daftarPinjaman.length,
                      itemBuilder: (context, index) {
                        final pinjaman = daftarPinjaman[index];
                        return Card(
                          elevation: 2,
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              pinjaman['namaBarang'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Oleh: ${pinjaman['dipinjamOleh']}'),
                            trailing: Text(
                              pinjaman['status'],
                              style: TextStyle(
                                color: pinjaman['status'] == 'Dipinjam'
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(loan: pinjaman),
                                ),
                              );
                            },
                          ),
                        );
                      },
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

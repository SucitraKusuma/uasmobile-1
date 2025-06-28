// detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> loan;

  const DetailScreen({super.key, required this.loan});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.loan['status'];
  }

  void _showEditStatusDialog(BuildContext context) async {
    String? selectedStatus = status;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Status'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: const [
              DropdownMenuItem(value: 'dipinjam', child: Text('Dipinjam')),
              DropdownMenuItem(
                  value: 'dikembalikan', child: Text('Dikembalikan')),
            ],
            onChanged: (value) {
              selectedStatus = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus != null) {
                  await Provider.of<LoanProvider>(context, listen: false)
                      .editStatus(widget.loan['id'], selectedStatus!);
                  setState(() {
                    status = selectedStatus!;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Status berhasil diupdate!')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await Provider.of<LoanProvider>(context, listen: false)
          .deletePinjaman(widget.loan['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 2,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Detail Peminjaman',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama Barang: ${widget.loan['namaBarang']}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Dipinjam Oleh: ${widget.loan['dipinjamOleh']}'),
                        const SizedBox(height: 8),
                        Text(
                            'Tanggal Pinjam: ${widget.loan['tanggalPinjam'] ?? widget.loan['tanggal']}'),
                        const SizedBox(height: 8),
                        Text('Status: $status'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showEditStatusDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ubah Status'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _confirmDelete(context),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

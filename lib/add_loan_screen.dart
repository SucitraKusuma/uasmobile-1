// add_loan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/loan_provider.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _dipinjamOlehController = TextEditingController();
  DateTime? _tanggalPinjam;
  String _status = 'Dipinjam';

  final _formKey = GlobalKey<FormState>();

  void _simpanData() {
    if (_formKey.currentState!.validate() && _tanggalPinjam != null) {
      final data = {
        'namaBarang': _namaBarangController.text,
        'dipinjamOleh': _dipinjamOlehController.text,
        'tanggalPinjam': DateFormat('dd-MM-yyyy').format(_tanggalPinjam!),
        'status': _status,
      };

      Provider.of<LoanProvider>(context, listen: false)
          .tambahPinjaman(data)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan ke Firestore!')),
        );
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dulu.')),
      );
    }
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _dipinjamOlehController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _tanggalPinjam = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Peminjaman',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaBarangController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama barang wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dipinjamOlehController,
                decoration: const InputDecoration(
                  labelText: 'Dipinjam Oleh',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama peminjam wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _tanggalPinjam == null
                      ? 'Pilih Tanggal Pinjam'
                      : DateFormat('dd MMM yyyy').format(_tanggalPinjam!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Dipinjam', child: Text('Dipinjam')),
                  DropdownMenuItem(
                      value: 'Dikembalikan', child: Text('Dikembalikan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

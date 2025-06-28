// add_loan_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/loan_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Tambahan untuk foto barang
  File? _fotoBarang;

  Future<void> _ambilFoto() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _fotoBarang = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadToImgur(File imageFile) async {
    const clientId = 'f7fc1365b0f1c85'; // Client ID dari user
    final url = Uri.parse('https://api.imgur.com/3/image');
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Client-ID $clientId',
      },
      body: {
        'image': base64Image,
        'type': 'base64',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['link'];
    } else {
      print('Upload Imgur error: \\${response.body}');
      return null;
    }
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate() && _tanggalPinjam != null) {
      if (_fotoBarang == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Silakan ambil foto barang terlebih dahulu!')),
        );
        return;
      }

      // Upload ke Imgur
      final imgurUrl = await uploadToImgur(_fotoBarang!);
      if (imgurUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal upload foto ke Imgur')),
        );
        return;
      }

      final data = {
        'namaBarang': _namaBarangController.text,
        'dipinjamOleh': _dipinjamOlehController.text,
        'status': _status.toLowerCase(),
        'tanggalPinjam': DateFormat('dd MMM yyyy').format(_tanggalPinjam!),
        'createdAt': DateTime.now().toIso8601String(),
        'foto_barang': imgurUrl, // Simpan URL Imgur
      };

      try {
        // Gunakan LoanProvider untuk menyimpan data
        await Provider.of<LoanProvider>(context, listen: false)
            .tambahPinjaman(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan ke Firestore!')),
        );

        // Clear form
        _namaBarangController.clear();
        _dipinjamOlehController.clear();
        setState(() {
          _tanggalPinjam = null;
          _status = 'Dipinjam';
          _fotoBarang = null;
        });

        // Refresh data di halaman utama
        Provider.of<LoanProvider>(context, listen: false).loadPinjaman();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      }
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fotoBarang != null
                      ? Image.file(_fotoBarang!, height: 120)
                      : Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(child: Text('Belum ada foto')),
                        ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _ambilFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ambil Foto Barang'),
                  ),
                ],
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

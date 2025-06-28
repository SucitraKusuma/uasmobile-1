// login.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'menuUtama.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Print semua user untuk debug
    final allUsers = await FirebaseFirestore.instance.collection('user').get();
    for (var doc in allUsers.docs) {
      print('User Firestore: ' + doc.data().toString());
    }

    // Query ke Firestore (bisa pakai email atau nim)
    try {
      final queryByEmail = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();
      final queryByNim = await FirebaseFirestore.instance
          .collection('user')
          .where('nim', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      print('User ditemukan by email: ${queryByEmail.docs.length}');
      print('User ditemukan by nim: ${queryByNim.docs.length}');

      if (queryByEmail.docs.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString(
            'user_data', json.encode(queryByEmail.docs.first.data()));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuUtama()),
        );
      } else if (queryByNim.docs.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString(
            'user_data', json.encode(queryByNim.docs.first.data()));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuUtama()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Email/NIM atau Password salah')), // Lebih informatif
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: $e')),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      // Paksa sign out dulu agar selalu muncul account picker
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User batal login
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Simpan status login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);

      // Simpan data user ke local (opsional)
      final user = userCredential.user;
      if (user != null) {
        await prefs.setString('user_data',
            '{"email": "${user.email}", "nama": "${user.displayName}"}');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuUtama()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Google gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue[900],
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Center(
                child: Text(
                  'Manajemen Peminjaman Barang',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/logo_login.jpg', // Logo utama aplikasi
              height: 150,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Belum punya akun? Register'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: Icon(
                        Icons.login), // Ganti dengan logo Google jika ada asset
                    label: const Text('Login dengan Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: Colors.blue),
                    ),
                    onPressed: _loginWithGoogle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

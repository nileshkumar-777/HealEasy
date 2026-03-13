import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("HealEasy"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 80, color: Colors.pinkAccent),

            const SizedBox(height: 20),

            const Text(
              "Welcome to HealEasy",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              user?.email ?? "No user logged in",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User signed out")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text("Logout", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

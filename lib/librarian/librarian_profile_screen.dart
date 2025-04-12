import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main menu/auth_screen.dart';

class LibrarianProfileScreen extends StatelessWidget {
  const LibrarianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user?.email)
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Librarian data not found.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final librarian = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: (librarian['photoUrl'] ?? "").isNotEmpty
                        ? NetworkImage(librarian['photoUrl'])
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: (librarian['photoUrl'] ?? "").isEmpty
                        ? Text(
                      (librarian['firstName'] ?? "L")[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40, color: Colors.black),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Name: ${librarian['firstName']} ${librarian['lastName']}",
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  "Email: ${librarian['email']}",
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock_reset),
                  label: const Text("Reset Password"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final shouldProceed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Reset Password?"),
                        content: const Text(
                            "Are you sure you want to send a password reset email to your registered email address?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Confirm"),
                          ),
                        ],
                      ),
                    );

                    if (shouldProceed == true) {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: user!.email!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password reset email sent.")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero);
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
                          return SlideTransition(
                            position: tween.animate(curvedAnimation),
                            child: child,
                          );
                        },
                      ),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

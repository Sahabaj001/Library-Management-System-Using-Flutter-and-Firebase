import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main menu/auth_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('students')
            .where('email', isEqualTo: user?.email)
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: (student['photoUrl'] ?? "").isNotEmpty
                        ? NetworkImage(student['photoUrl'])
                        : null,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: (student['photoUrl'] ?? "").isEmpty
                        ? Text(
                      (student['firstName'] ?? "S")[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40, color: Colors.deepPurple),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text("Name: ${student['firstName']} ${student['lastName']}", style: const TextStyle(fontSize: 18)),
                Text("ID: ${student['id']}", style: const TextStyle(fontSize: 18)),
                Text("Department: ${student['department']}", style: const TextStyle(fontSize: 18)),
                Text("Passout Year: ${student['passoutYear']}", style: const TextStyle(fontSize: 18)),
                Text("Email: ${student['email']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock_reset),
                  label: const Text("Reset Password"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password reset email sent.")),
                    );
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
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
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

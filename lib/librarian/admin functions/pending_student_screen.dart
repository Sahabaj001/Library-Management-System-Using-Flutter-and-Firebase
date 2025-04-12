import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PendingApprovalsScreen extends StatelessWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Pending Approvals", style: TextStyle(color: Colors.white), ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('approved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingStudents = snapshot.data!.docs;

          if (pendingStudents.isEmpty) {
            return const Center(
              child: Text(
                'No pending student approvals.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: pendingStudents.length,
            itemBuilder: (context, index) {
              final student = pendingStudents[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text("${student['firstName']} ${student['lastName']}"),
                subtitle: Text(
                  "ID: ${student['id'] ?? "N/A"}\n"
                      "Email: ${student['email'] ?? "N/A"}\n"
                      "Department: ${student['department'] ?? "N/A"}\n"
                      "Passout Year: ${student['passoutYear'] ?? "N/A"}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('students')
                        .doc(pendingStudents[index].id)
                        .update({'approved': true});
                  },
                ),
              );
            },
          );
        },
      ),

    );
  }
}

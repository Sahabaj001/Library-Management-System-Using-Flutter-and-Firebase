import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library01/librarian/admin%20functions/pending_student_screen.dart';
import 'librarian_student_profile.dart';

class LibrarianStudentsScreen extends StatefulWidget {
  const LibrarianStudentsScreen({super.key});

  @override
  LibrarianStudentsScreenState createState() => LibrarianStudentsScreenState();
}

class LibrarianStudentsScreenState extends State<LibrarianStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Students",style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search by ID, Name or Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('students').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".toLowerCase();
                  final id = (data['id'] ?? "").toLowerCase();
                  final email = (data['email'] ?? "").toLowerCase();
                  return name.contains(searchQuery) || id.contains(searchQuery) || email.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index].data() as Map<String, dynamic>;

                    final fullName = "${student['firstName'] ?? ''} ${student['lastName'] ?? ''}";
                    final profileImageUrl = student['photoUrl'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl == null || profileImageUrl.isEmpty
                            ? Text(fullName.isNotEmpty ? fullName[0] : '?')
                            : null,
                      ),
                      title: Text(fullName),
                      subtitle: Text("ID: ${student['id'] ?? "N/A"}\nEmail: ${student['email'] ?? "N/A"}"),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LibrarianStudentProfile(studentId: students[index].id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PendingApprovalsScreen(),
            ),
          );
        },
        child: const Icon(Icons.pending_actions),
      ),
    );
  }
}

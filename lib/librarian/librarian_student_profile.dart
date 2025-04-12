import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibrarianStudentProfile extends StatelessWidget {
  final String studentId;

  const LibrarianStudentProfile({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Student Profile",style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('students').doc(studentId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var studentData = snapshot.data!.data() as Map<String, dynamic>;
          final fullName = "${studentData['firstName']} ${studentData['lastName']}";
          final photoUrl = studentData['photoUrl'] ?? "";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    backgroundColor: Colors.purpleAccent,
                    child: photoUrl.isEmpty
                        ? Text(
                      studentData['firstName']?.isNotEmpty == true
                          ? studentData['firstName'][0].toUpperCase()
                          : "?",
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 30),
                Text("ID: ${studentData['id']}", style: const TextStyle(fontSize: 16)),
                Text("Department: ${studentData['department']}", style: const TextStyle(fontSize: 16)),
                Text("Passout Year: ${studentData['passoutYear']}", style: const TextStyle(fontSize: 16)),
                Text("Email: ${studentData['email']}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                const Text("Borrowed Books:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('borrowed_books')
                        .where('studentId', isEqualTo: studentId)
                        .snapshots(),
                    builder: (context, bookSnapshot) {
                      if (!bookSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var books = bookSnapshot.data!.docs;
                      if (books.isEmpty) {
                        return const Text("No books borrowed.");
                      }
                      return ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          var bookData = books[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(bookData['title']),
                            subtitle: Text("Author: ${bookData['author']} | Issued on: ${bookData['issueDate']}"),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Bookshelf", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Awaiting Approval Section
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('borrow_requests')
                  .where('email', isEqualTo: user?.email)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final pendingRequests = snapshot.data!.docs;

                if (pendingRequests.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Awaiting Approval",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pendingRequests.length,
                      itemBuilder: (context, index) {
                        final request = pendingRequests[index].data() as Map<String, dynamic>;
                        final title = request['title'] ?? 'Untitled';
                        final isbn = request['isbn'] ?? '';
                        final coverImage = isbn.isNotEmpty
                            ? 'assets/book_covers/isbn_$isbn.jpg'
                            : 'assets/book_covers/default_cover.jpg';

                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                coverImage,
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Image.asset('assets/book_covers/default_cover.jpg'),
                              ),
                            ),
                            title: Text(title, style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                              "Status: Pending Approval",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Borrowed Books Section
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('borrowed_books')
                  .where('userId', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final borrowedBooks = snapshot.data!.docs;

                if (borrowedBooks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "No borrowed books yet.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: borrowedBooks.length,
                  itemBuilder: (context, index) {
                    final book = borrowedBooks[index].data() as Map<String, dynamic>;
                    final issueDate = (book['issueDate'] as Timestamp).toDate();
                    final dueDate = issueDate.add(const Duration(days: 30));
                    final now = DateTime.now();
                    final isOverdue = now.isAfter(dueDate);
                    final coverImage = book['isbn'] != null
                        ? 'assets/book_covers/isbn_${book['isbn']}.jpg'
                        : 'assets/book_covers/default_cover.jpg';

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            coverImage,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Image.asset('assets/book_covers/default_cover.jpg'),
                          ),
                        ),
                        title: Text(book['title'] ?? 'Untitled', style: TextStyle(color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Author: ${book['author'] ?? 'Unknown'}",
                                style: const TextStyle(color: Colors.grey)),
                            Text("ISBN: ${book['isbn'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.grey)),
                            Text("Issued: ${DateFormat('dd-MM-yyyy').format(issueDate)}",
                                style: const TextStyle(color: Colors.grey)),
                            Text("Due: ${DateFormat('dd-MM-yyyy').format(dueDate)}",
                                style: const TextStyle(color: Colors.grey)),
                            Text(
                              isOverdue ? "Status: Overdue" : "Status: On Time",
                              style: TextStyle(
                                color: isOverdue ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

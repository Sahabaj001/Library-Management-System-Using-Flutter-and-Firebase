import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewIssuedBooksPage extends StatelessWidget {
  const ViewIssuedBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text("All Issued Books", style: TextStyle(color: Colors.white),),
          iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrowed_books')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final borrowedBooks = snapshot.data!.docs;

          if (borrowedBooks.isEmpty) {
            return const Center(child: Text("No books currently issued."));
          }

          return ListView.builder(
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
                  title: Text(book['title'] ?? 'Untitled'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Author: ${book['author'] ?? 'Unknown'}"),
                      Text("ISBN: ${book['isbn'] ?? 'N/A'}"),
                      Text("Borrowed by: ${book['userEmail'] ?? 'Unknown'}"),
                      Text("Issued: ${DateFormat('dd-MM-yyyy').format(issueDate)}"),
                      Text("Due: ${DateFormat('dd-MM-yyyy').format(dueDate)}"),
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
    );
  }
}

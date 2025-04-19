import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BorrowRequestsScreen extends StatelessWidget {
  const BorrowRequestsScreen({super.key});

  Future<void> _approveRequest(DocumentSnapshot request) async {
    try {
      final data = request.data() as Map<String, dynamic>;
      final bookId = data['id'];
      final email = data['email'];
      final title = data['title'];
      final isbn = data['isbn'];

      // Fetching userId
      final userSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('Student not found for email $email');
      }

      final userId = userSnapshot.docs.first.id;

      // Fetching author from books collection
      final bookSnapshot = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      final bookData = bookSnapshot.data();
      final author = bookData?['author'] ?? 'Unknown';

      final now = Timestamp.now();
      final dueDate = Timestamp.fromDate(now.toDate().add(const Duration(days: 30)));

      // Add to borrowed_books with author
      await FirebaseFirestore.instance.collection('borrowed_books').add({
        'userId': userId,
        'userEmail': email,
        'bookId': bookId,
        'title': title,
        'author': author,
        'isbn': isbn,
        'issueDate': now,
        'dueDate': dueDate,
        'status': 'issued',
        'coverImage': 'isbn_$isbn.jpg',
      });

      // Update book availability
      await FirebaseFirestore.instance.collection('books').doc(bookId).update({
        'available': FieldValue.increment(-1),
      });

      // Delete the request after approval
      await request.reference.delete();
    } catch (e) {
      debugPrint('Error approving request: $e');
    }
  }



  Future<void> _rejectRequest(DocumentSnapshot request) async {
    try {
      await request.reference.delete();
    } catch (e) {
      debugPrint('Error rejecting request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text("Issue Books", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrow_requests')
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No borrow requests."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data() as Map<String, dynamic>;

              final status = data['status'];
              final requestedAt = (data['requestedAt'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd-MM-yyyy').format(requestedAt);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Image.asset(
                    'assets/book_covers/isbn_${data['isbn']}.jpg',
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/book_covers/default_cover.jpg'),
                  ),
                  title: Text(data['title'] ?? 'Untitled'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Requested by: ${data['email']}"),
                      Text("Requested on: $formattedDate"),
                      Text("Status: $status"),
                    ],
                  ),
                  trailing: status == 'pending'
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveRequest(request),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectRequest(request),
                      ),
                    ],
                  )
                      : Text(status.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == 'approved'
                              ? Colors.green
                              : Colors.red)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

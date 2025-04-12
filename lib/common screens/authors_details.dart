import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utility screens/book_card.dart';

class AuthorDetailsPage extends StatelessWidget {
  final String authorId;

  const AuthorDetailsPage({super.key, required this.authorId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Author Details',style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        ),
      ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('authors')
            .doc(authorId)
            .get(),
        builder: (context, authorSnapshot) {
          if (!authorSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final author = authorSnapshot.data!;
          final storedAuthorId = author['authorId'] ?? author.id; // Use Firestore-stored authorId

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        'assets/author_pics/${author['photoUrl'] ?? 'default.jpg'}',
                      ),
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint("Failed to load detail image: ${author['photoUrl']}");
                      },
                      child: author['photoUrl'] == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            author['name'] ?? 'Unknown Author',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(author['bio'] ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Author's Books
                const Text(
                  'Published Books',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildBooksList(storedAuthorId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooksList(String storedAuthorId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('authorId', isEqualTo: storedAuthorId.trim())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Text(
                'No books found for this author',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        final books = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return BookCard(book: book);
          },
        );
      },
    );
  }
}

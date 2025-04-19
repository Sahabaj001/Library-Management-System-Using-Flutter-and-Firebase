import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../librarian/admin functions/add_author_page.dart';
import 'authors_details.dart';

class AuthorsPage extends StatefulWidget {
  const AuthorsPage({super.key});

  @override
  State<AuthorsPage> createState() => _AuthorsPageState();
}

class _AuthorsPageState extends State<AuthorsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isUser = false;

  @override
  void initState() {
    super.initState();
    _checkIfUser();
  }

  Future<void> _checkIfUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _isUser = userDoc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Authors',
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.purple),
              decoration: InputDecoration(
                hintText: 'Search authors...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                filled: true,
                fillColor: Colors.purple.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('authors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading authors',
                style: TextStyle(color: Colors.purple),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No authors found',
                style: TextStyle(color: Colors.purple),
              ),
            );
          }

          final authors = snapshot.data!.docs.where((doc) {
            final authorData = doc.data() as Map<String, dynamic>? ?? {};
            final name = authorData['name']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery);
          }).toList();

          if (authors.isEmpty) {
            return const Center(
              child: Text(
                'No matching authors found',
                style: TextStyle(color: Colors.purple),
              ),
            );
          }

          return ListView.builder(
            itemCount: authors.length,
            itemBuilder: (context, index) {
              final author = authors[index];
              final authorData = author.data() as Map<String, dynamic>? ?? {};
              final authorName = authorData['name']?.toString() ?? 'Unknown Author';

              return FutureBuilder<QuerySnapshot>(
                future: _getAuthorsBooks(author),
                builder: (context, bookSnapshot) {
                  final bookCount = bookSnapshot.data?.docs.length ?? 0;

                  return ListTile(
                    leading: _buildAuthorAvatar(author),
                    title: Text(
                      authorName,
                      style: const TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      '$bookCount ${bookCount == 1 ? 'book' : 'books'}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthorDetailsPage(authorId: author.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: _isUser
          ? FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAuthorPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Future<QuerySnapshot> _getAuthorsBooks(DocumentSnapshot author) {
    final authorData = author.data() as Map<String, dynamic>;
    final storedAuthorId = authorData['authorId'] ?? '';

    return FirebaseFirestore.instance
        .collection('books')
        .where('authorId', isEqualTo: storedAuthorId)
        .get();
  }

  Widget _buildAuthorAvatar(DocumentSnapshot author) {
    final authorData = author.data() as Map<String, dynamic>;
    final imageName = authorData['photoUrl']?.toString() ?? 'default.jpg';

    return CircleAvatar(
      backgroundImage: AssetImage('assets/author_pics/$imageName'),
      backgroundColor: Colors.grey.shade300,
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint("Failed to load image: $imageName");
      },
      child: imageName == 'default.jpg'
          ? const Icon(Icons.person, color: Colors.purple)
          : null,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _bookResults = [];
  List<DocumentSnapshot> _authorResults = [];

  Future<void> _performSearch(String query) async {
    final booksSnapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('searchKeywords', arrayContains: query.toLowerCase()) // optional indexing
        .get();

    final authorsSnapshot = await FirebaseFirestore.instance
        .collection('authors')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      _bookResults = booksSnapshot.docs;
      _authorResults = authorsSnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Search", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search books or authors...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () => _performSearch(_searchController.text.trim()),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => _performSearch(value.trim()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (_bookResults.isNotEmpty) ...[
                    const Text(
                      "Books",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ..._bookResults.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['title'] ?? 'Unknown Title', style: const TextStyle(color: Colors.white)),
                        subtitle: Text(data['author'] ?? 'Unknown Author', style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          Navigator.pushNamed(context, '/bookDetails', arguments: doc.id);
                        },
                      );
                    }).toList(),
                  ],
                  if (_authorResults.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Authors",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ..._authorResults.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? 'Unknown Author', style: const TextStyle(color: Colors.white)),
                        subtitle: Text(data['bio'] ?? '', style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          Navigator.pushNamed(context, '/authorDetails', arguments: doc.id);
                        },
                      );
                    }).toList(),
                  ],
                  if (_bookResults.isEmpty && _authorResults.isEmpty && _searchController.text.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text("No results found.", style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

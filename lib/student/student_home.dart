import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utility screens/search_screen.dart';
import '../common screens/book_screen.dart';
import '../utility screens/notices.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool hasNewNotice = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Library Home", style: TextStyle(color: Colors.white, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NoticesPage()),
                  );
                },
              ),
              if (hasNewNotice)
                const Positioned(
                  right: 12,
                  top: 12,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildCategorySection("top", "Top Picks"),
                  _buildCategorySection("new", "New Arrivals"),
                  _buildCategorySection("popular", "Popular"),
                  _buildCategorySection("novels", "Novels"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: "Search books...",
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIcon: const Icon(Icons.search, color: Colors.purple),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.purple),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildCategorySection(String genreKey, String displayTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            displayTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('books')
                .where('genre', arrayContains: genreKey)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No books found',
                    style: TextStyle(color: Colors.black54),
                  ),
                );
              }

              final bookDocs = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bookDocs.length,
                itemBuilder: (context, index) {
                  final bookDoc = bookDocs[index];
                  return _buildBookCard(bookDoc);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBookCard(DocumentSnapshot bookDoc) {
    final data = bookDoc.data() as Map<String, dynamic>;
    final coverPath = 'assets/book_covers/${data['coverImage'] ?? 'default_cover.jpg'}';

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => BookDetailsPage(
                      book: data,
                      bookId: bookDoc.id,
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.ease));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  coverPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/book_covers/default_cover.jpg'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data['title'] ?? 'Untitled',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            data['author'] ?? 'Unknown Author',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'book_screen.dart';
import 'genre_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _allGenres = [];
  List<String> _filteredGenres = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _allGenres = [
      "Science", "Mathematics", "History", "Engineering", "Geography", "Law",
      "Fantasy", "Mystery", "Romance", "Science Fiction", "Thriller", "Drama",
      "Medical", "Technology", "Research", "Social Science", "Business", "Art",
    ];
    _filteredGenres = _allGenres;
    _searchController.addListener(_onSearchChanged);
  }
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredGenres = _allGenres;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredGenres = _allGenres
          .where((genre) => genre.toLowerCase().contains(query))
          .toList();
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Browse",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Educational"),
            Tab(text: "Novels"),
            Tab(text: "Journals"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search for subjects or books",
                hintStyle: TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.purple, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.purple, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),

          ),

          if (_isSearching)
            Container(
              height: 200, // limit height
              child: ListView.builder(
                itemCount: _filteredGenres.length,
                itemBuilder: (context, index) {
                  final genre = _filteredGenres[index];
                  return ListTile(
                    title: Text(genre),
                    leading: const Icon(Icons.search, color: Colors.deepPurple),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GenrePage(genreName: genre),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGenreGrid(["Science", "Mathematics", "History", "Engineering", "Geography", "Law"]),
                _buildGenreGrid(["Fantasy", "Mystery", "Romance", "Science Fiction", "Thriller", "Drama"]),
                _buildGenreGrid(["Medical", "Technology", "Research", "Social Science", "Business", "Art"]),
              ],
            ),
          ),
        ],

      ),
    );
  }

  Widget _buildGenreGrid(List<String> genres) {
    final Map<String, IconData> genreIcons = {
      "Science": Icons.science,
      "Mathematics": Icons.calculate,
      "History": Icons.history_edu,
      "Engineering": Icons.engineering,
      "Geography": Icons.map,
      "Law": Icons.gavel,
      "Fantasy": Icons.auto_awesome,
      "Mystery": Icons.help_outline,
      "Romance": Icons.favorite,
      "Science Fiction": Icons.rocket_launch,
      "Thriller": Icons.theater_comedy,
      "Drama": Icons.theaters,
      "Medical": Icons.local_hospital,
      "Technology": Icons.computer,
      "Research": Icons.search,
      "Social Science": Icons.people,
      "Business": Icons.business,
      "Art": Icons.palette,
    };

    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final icon = genreIcons[genre] ?? Icons.book;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, animation, __) => GenrePage(genreName: genre),
                  transitionsBuilder: (_, animation, __, child) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ));
                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              );
            },
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.purple, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      genre,
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
Widget _buildSearchResults(String query) {
  final allGenres = [
    "Science", "Mathematics", "History", "Engineering", "Geography", "Law",
    "Fantasy", "Mystery", "Romance", "Science Fiction", "Thriller", "Drama",
    "Medical", "Technology", "Research", "Social Science", "Business", "Art"
  ];

  final matchingGenres = allGenres
      .where((genre) => genre.toLowerCase().contains(query.toLowerCase()))
      .toList();

  return Expanded(
    child: FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('books')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
        }

        final bookDocs = snapshot.hasData ? snapshot.data!.docs : [];

        return ListView(
          children: [
            if (matchingGenres.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Matching Genres", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...matchingGenres.map((genre) => ListTile(
                leading: const Icon(Icons.category, color: Colors.deepPurple),
                title: Text(genre),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GenrePage(genreName: genre)),
                  );
                },
              )),
            ],
            if (bookDocs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Matching Books", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...bookDocs.map((doc) {
                final book = doc.data() as Map<String, dynamic>;
                return ListTile(
                  leading: const Icon(Icons.book, color: Colors.purple),
                  title: Text(book['title'] ?? 'Untitled'),
                  subtitle: Text("By: ${book['author'] ?? 'Unknown'}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailsPage(book: book, bookId: doc.id),
                      ),
                    );
                  },
                );
              }),
            ],
            if (matchingGenres.isEmpty && bookDocs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("No results found.")),
              ),
          ],
        );
      },
    ),
  );
}

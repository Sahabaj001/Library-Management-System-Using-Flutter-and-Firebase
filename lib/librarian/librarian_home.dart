import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library01/librarian/admin%20functions/pending_student_screen.dart';
import 'package:library01/librarian/admin%20functions/return_books_page.dart';
import 'package:library01/librarian/admin%20functions/view_issued_books_page.dart';
import 'admin functions/Borrow_Requests_Screen.dart';
import 'admin functions/add_author_page.dart';
import 'admin functions/add_books.dart';
import 'librarian_students.dart';
import 'admin functions/notice_screen.dart';

class LibrarianHome extends StatefulWidget {
  final String librarianName;

  const LibrarianHome({super.key, required this.librarianName});

  @override
  State<LibrarianHome> createState() => _LibrarianHomeState();
}

class _LibrarianHomeState extends State<LibrarianHome> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot>? searchResults;
  bool isLoading = false;

  void search(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = null);
      return;
    }
    setState(() => isLoading = true);

    final lowerQuery = query.toLowerCase();

    final studentResults = await FirebaseFirestore.instance
        .collection('students')
        .where('fullName', isGreaterThanOrEqualTo: lowerQuery)
        .where('fullName', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
        .get();

    final bookResults = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    final authorResults = await FirebaseFirestore.instance
        .collection('authors')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      searchResults = [
        ...studentResults.docs,
        ...bookResults.docs,
        ...authorResults.docs
      ];
      isLoading = false;
    });
  }


  void _navigateWithFade(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildOutlinedButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Colors.purpleAccent),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Colors.purpleAccent),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.purpleAccent)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Librarian Home",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, Mr. ${widget.librarianName}",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.deepPurple[800],
                labelText: "Search students, books, or authors",
                labelStyle: const TextStyle(color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.purpleAccent),
                  onPressed: () => search(_searchController.text.trim()),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.purpleAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.purpleAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
              ),
              onChanged: (value) => search(value.trim()),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                buildOutlinedButton(
                  icon: Icons.campaign_outlined,
                  label: "Issue Notice",
                  onPressed: () => _navigateWithFade(context, const PostNoticePage()),
                ),
                buildOutlinedButton(
                  icon: Icons.person_add_alt_1_outlined,
                  label: "Approve Student",
                  onPressed: () => _navigateWithFade(context, const PendingApprovalsScreen()),
                ),
                buildOutlinedButton(
                  icon: Icons.library_add_outlined,
                  label: "Add Book",
                  onPressed: () => _navigateWithFade(context, const AddBookPage()),
                ),
                buildOutlinedButton(
                  icon: Icons.person_add_outlined,
                  label: "Add Author",
                  onPressed: () => _navigateWithFade(context, const AddAuthorPage()),
                ),
                buildOutlinedButton(
                  icon: Icons.person_outline_outlined,
                  label: "View Students",
                  onPressed: () => _navigateWithFade(context, const LibrarianStudentsScreen()),
                ),
                buildOutlinedButton(
                  icon: Icons.bookmark_added_outlined,
                  label: "Issue Books",
                  onPressed: () => _navigateWithFade(context, const BorrowRequestsScreen()),
                ),
                buildOutlinedButton(
                  icon: Icons.bookmark_remove_outlined,
                  label: "Return Books",
                  onPressed: () => _navigateWithFade(context, const ReturnBooksPage()),
                ),
                buildOutlinedButton(
                  icon: Icons.bookmarks_outlined,
                  label: "View Issued Books",
                  onPressed: () => _navigateWithFade(context, const ViewIssuedBooksPage()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
            if (searchResults != null && searchResults!.isEmpty)
              const Center(child: Text("No results found.", style: TextStyle(color: Colors.white))),
            if (searchResults != null && searchResults!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchResults!.length,
                itemBuilder: (context, index) {
                  final result = searchResults![index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      result['name'] ?? result['title'] ?? "Unknown",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: result.containsKey('author')
                        ? Text("Author: ${result['author']}", style: const TextStyle(color: Colors.white70))
                        : null,
                    leading: const Icon(Icons.library_books, color: Colors.purpleAccent),
                  );
                },
              ),
          ],
        ),
      ),

    );
  }
}

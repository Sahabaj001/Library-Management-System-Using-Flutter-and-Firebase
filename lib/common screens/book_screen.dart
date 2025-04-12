import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;
  final String bookId;

  const BookDetailsPage({
    super.key,
    required this.book,
    required this.bookId,
  });

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool isStudent = false;
  bool isLoading = true;
  int copiesToAdd = 1;
  bool hasAlreadyBorrowed = false;
  int activeBorrowCount = 0;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEmail = user.email;

    final studentSnap = await FirebaseFirestore.instance
        .collection('students')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (studentSnap.docs.isNotEmpty) {
      final studentData = studentSnap.docs.first.data();
      final borrowedBooks = List<String>.from(studentData['borrowedBooks'] ?? []);

      setState(() {
        isStudent = true;
        hasAlreadyBorrowed = borrowedBooks.contains(widget.bookId);
        activeBorrowCount = borrowedBooks.length;
        isLoading = false;
      });
    } else {
      setState(() {
        isStudent = false;
        isLoading = false;
      });
    }
  }


  Future<void> _sendBorrowRequest(
      BuildContext context, String id, String isbn, String title) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEmail = user.email;

    final request = {
      'email': userEmail,
      'id': id,
      'isbn': isbn,
      'title': title,
      'requestedAt': Timestamp.now(),
      'status': 'pending',
    };

    await FirebaseFirestore.instance.collection('borrow_requests').add(request);

    // Optimistically update UI
    setState(() {
      hasAlreadyBorrowed = true;
      activeBorrowCount += 1;
    });

    // Update borrowedBooks list in student document
    final studentDocs = await FirebaseFirestore.instance
        .collection('students')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (studentDocs.docs.isNotEmpty) {
      final docRef = studentDocs.docs.first.reference;
      await docRef.update({
        'borrowedBooks': FieldValue.arrayUnion([id]),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Borrow request sent')),
    );
  }


  Future<void> _addCopies(int count) async {
    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .update({'totalQuantity': FieldValue.increment(count)});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count copies added.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding copies: $e')),
      );
    }
  }

  Future<void> _deleteBook() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book deleted successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    final formattedDate = book['publishDate'] != null
        ? DateFormat('dd-MM-yyyy')
        .format((book['publishDate'] as Timestamp).toDate())
        : 'Date not available';

    final rating = double.tryParse(book['rating'] ?? '0') ?? 0;
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 300,
              width: 200,
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/book_covers/${book['coverImage'] ?? 'default_cover.jpg'}',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/book_covers/default_cover.jpg',
                    fit: BoxFit.contain,
                  ),
                ),

              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                book['title']?.toUpperCase() ?? 'UNTITLED',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              book['author']?.toUpperCase() ?? 'UNKNOWN AUTHOR',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Published at $formattedDate',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  Icon(
                    i <= fullStars
                        ? Icons.star
                        : (hasHalfStar && i == fullStars + 1)
                        ? Icons.star_half
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                const SizedBox(width: 10),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: (book['genre'] as List<dynamic>?)
                  ?.map((genre) => Chip(
                label: Text(genre.toString()),
                backgroundColor:
                Colors.deepPurple.withOpacity(0.1),
              ))
                  .toList() ??
                  [const Chip(label: Text('Unknown'))],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                book['summary'] ?? 'No summary available',
                style:
                const TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            if (isStudent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: (hasAlreadyBorrowed ||
                        activeBorrowCount >= 5)
                        ? null
                        : () => _sendBorrowRequest(
                      context,
                      widget.bookId,
                      book['isbn'],
                      book['title'],
                    ),
                    child: Text(
                      hasAlreadyBorrowed
                          ? 'BORROWED'
                          : (activeBorrowCount >= 5
                          ? 'LIMIT REACHED'
                          : 'BORROW THIS BOOK'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  const Text(
                    "Librarian Actions",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 50,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                          Border.all(color: Colors.deepPurple),
                        ),
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: copiesToAdd,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                copiesToAdd = value;
                              });
                            }
                          },
                          dropdownColor: Colors.white,
                          underline: const SizedBox(),
                          iconEnabledColor: Colors.deepPurple,
                          items: List.generate(
                            10,
                                (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        height: 70,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _addCopies(copiesToAdd),
                          child: const Text(
                            "Add Copies",
                            style: TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _deleteBook,
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.red),
                    child: const Text(
                      "Delete Book",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

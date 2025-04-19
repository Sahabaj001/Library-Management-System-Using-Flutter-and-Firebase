import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReturnBooksPage extends StatefulWidget {
  const ReturnBooksPage({super.key});

  @override
  State<ReturnBooksPage> createState() => _ReturnBooksPageState();
}

class _ReturnBooksPageState extends State<ReturnBooksPage> {
  final _isbnController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  Future<void> _returnBook() async {
    if (!_formKey.currentState!.validate()) return;

    final isbn = _isbnController.text.trim();
    final email = _emailController.text.trim();
    setState(() => _isProcessing = true);

    try {
      // Find the student's UID from their email
      final studentQuery = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (studentQuery.docs.isEmpty) {
        throw Exception("Student not found.");
      }

      final studentDoc = studentQuery.docs.first;
      final studentId = studentDoc.id;

      // Find the book by ISBN to get its document ID
      final bookQuery = await FirebaseFirestore.instance
          .collection('books')
          .where('isbn', isEqualTo: isbn)
          .limit(1)
          .get();

      if (bookQuery.docs.isEmpty) {
        throw Exception("Book not found.");
      }

      final bookDoc = bookQuery.docs.first;
      final bookDocId = bookDoc.id;

      // Find the borrowed book record
      final borrowQuery = await FirebaseFirestore.instance
          .collection('borrowed_books')
          .where('userId', isEqualTo: studentId)
          .where('isbn', isEqualTo: isbn)
          .limit(1)
          .get();

      if (borrowQuery.docs.isEmpty) {
        throw Exception("Borrowed book not found.");
      }

      final borrowedDocId = borrowQuery.docs.first.id;

      // Remove the borrowed_books entry
      await FirebaseFirestore.instance
          .collection('borrowed_books')
          .doc(borrowedDocId)
          .delete();

      // Update the book's availability
      await FirebaseFirestore.instance
          .collection('books')
          .doc(bookDocId)
          .update({
        'available': FieldValue.increment(1),
      });

      // Update the student's borrowedBooks array and booksBorrowed count
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({
        'borrowedBooks': FieldValue.arrayRemove([bookDocId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book returned successfully.')),
      );

      _isbnController.clear();
      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }



  @override
  void dispose() {
    _isbnController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Return Book", style: TextStyle(color: Colors.white),),
          iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'Book ISBN',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter ISBN' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Student Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _returnBook,
                  icon: const Icon(Icons.assignment_return,color: Colors.white,),
                  label: Text(_isProcessing ? 'Processing...' : 'Return Book',style: TextStyle(color:Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

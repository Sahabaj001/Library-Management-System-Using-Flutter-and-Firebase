import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({Key? key}) : super(key: key);

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _authorIdController = TextEditingController();
  final TextEditingController _coverImageController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _genreController = TextEditingController(); // comma-separated
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _totalQuantityController = TextEditingController();
  final TextEditingController _availableController = TextEditingController();
  DateTime? _publishDate;

  Future<void> _submitBook() async {
    if (_formKey.currentState!.validate() && _publishDate != null) {
      final bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'authorId': _authorIdController.text.trim(),
        'coverImage': _coverImageController.text.trim(),
        'isbn': _isbnController.text.trim(),
        'genre': _genreController.text.split(',').map((e) => e.trim()).toList(),
        'rating': _ratingController.text.trim(),
        'totalQuantity': int.parse(_totalQuantityController.text.trim()),
        'available': int.parse(_availableController.text.trim()),
        'publishDate': Timestamp.fromDate(_publishDate!),
        'borrowedBy': <String>[],
      };

      try {
        await FirebaseFirestore.instance.collection('books').add(bookData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully')),
        );
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add book: $e')),
        );
      }
    } else if (_publishDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a publish date')),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _authorController.clear();
    _authorIdController.clear();
    _coverImageController.clear();
    _isbnController.clear();
    _genreController.clear();
    _ratingController.clear();
    _totalQuantityController.clear();
    _availableController.clear();
    setState(() {
      _publishDate = null;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1500),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _publishDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Add Book',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(_titleController, 'Title'),
                _buildTextField(_authorController, 'Author'),
                _buildTextField(_authorIdController, 'Author ID'),
                _buildTextField(_coverImageController, 'Cover Image URL'),
                _buildTextField(_isbnController, 'ISBN'),
                _buildTextField(_genreController, 'Genres (comma separated)'),
                _buildTextField(_ratingController, 'Rating'),
                _buildTextField(_totalQuantityController, 'Total Quantity', isNumber: true),
                _buildTextField(_availableController, 'Available Quantity', isNumber: true),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    _publishDate == null
                        ? 'Pick Publish Date'
                        : 'Publish Date: ${DateFormat('yyyy-MM-dd').format(_publishDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitBook,
                  child: const Text('Add Book'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostNoticePage extends StatefulWidget {
  const PostNoticePage({super.key});

  @override
  State<PostNoticePage> createState() => _PostNoticePageState();
}

class _PostNoticePageState extends State<PostNoticePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  Future<void> _postNotice() async {
    if (_titleController.text.isEmpty || _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    final noticeData = {
      'title': _titleController.text.trim(),
      'text': _textController.text.trim(),
      'timestamp': Timestamp.now(),
      'createdBy': FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
    };

    await FirebaseFirestore.instance.collection('notices').add(noticeData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notice posted successfully.")),
    );

    _titleController.clear();
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Post Notice",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Notice Title",
                labelStyle: TextStyle(color: Colors.black54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 5,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Notice Text",
                labelStyle: TextStyle(color: Colors.black54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _postNotice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text(
                "Post Notice",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

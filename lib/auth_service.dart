import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Check if the user exists in the students collection
        DocumentSnapshot studentDoc =
        await _firestore.collection('students').doc(user.uid).get();

        if (studentDoc.exists) {
          bool isApproved = studentDoc['approved'] ?? false;
          if (!isApproved) {
            throw FirebaseAuthException(
              code: "account-pending",
              message: "Your account is pending approval.",
            );
          }
          return user; // Student login successful
        }

        // If not found in students, check in users (librarians)
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          return user; // Librarian login successful
        }

        // If user is not found in either collection, sign them out
        await _auth.signOut();
        throw FirebaseAuthException(
          code: "user-not-found",
          message: "User does not exist.",
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print("Sign-in error: ${e.code} - ${e.message}");
      rethrow;
    }
  }


  Future<User?> signUp({
     required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String department,
    required String passoutYear,
    required String id,
  }) async {
    try {
      // user creation
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // saving user
        await _firestore.collection('students').doc(user.uid).set({
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'department': department,
          'passoutYear': passoutYear,
          'id': id,
          'approved': false, //approval for students
          'borrowedBooks': [],
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;
      } else {
        throw Exception("User creation failed.");
      }
    } on FirebaseAuthException catch (e) {
      print("Sign-up error: \${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error: \$e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Sign-out error: \$e");
      rethrow;
    }
  }


  Future<bool> isUserApproved(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('students').doc(uid).get();
      if (doc.exists) {
        return doc['approved'] ?? false;
      } else {
        throw Exception("User not found in Firestore.");
      }
    } catch (e) {
      print("Error checking approval status: \$e");
      rethrow;
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }
}

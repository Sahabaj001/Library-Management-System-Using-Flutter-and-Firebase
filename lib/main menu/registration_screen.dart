import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController passoutYearController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String id = idController.text.trim();
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String department = departmentController.text.trim();
    String passoutYear = passoutYearController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    try {
      User? user = await _authService.signUp(
        email: email,
        password: password,
        id: id,
        firstName: firstName,
        lastName: lastName,
        department: department,
        passoutYear: passoutYear,
      );
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful! Awaiting approval.")),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple, Colors.purpleAccent],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
                          TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
                          TextField(controller: confirmPasswordController, decoration: const InputDecoration(labelText: "Confirm Password"), obscureText: true),
                          TextField(controller: idController, decoration: const InputDecoration(labelText: "ID")),
                          TextField(controller: firstNameController, decoration: const InputDecoration(labelText: "First Name")),
                          TextField(controller: lastNameController, decoration: const InputDecoration(labelText: "Last Name")),
                          TextField(controller: departmentController, decoration: const InputDecoration(labelText: "Department")),
                          TextField(controller: passoutYearController, decoration: const InputDecoration(labelText: "Passout Year"), keyboardType: TextInputType.number),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: register,
                            child: const Text("Register"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Already have an account? Log in"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_screen.dart';
import 'librarian_screen.dart';
import '../auth_service.dart';
import 'registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  void showLoadingDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Center(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 200,
              height: 120,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Logging in..."),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  void loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final savedRememberMe = prefs.getBool('rememberMe') ?? false;

    if (savedRememberMe) {
      setState(() {
        rememberMe = true;
        emailController.text = savedEmail ?? '';
        passwordController.text = savedPassword ?? '';
      });
    }
  }

  void authenticate() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    showLoadingDialog();
    // Saving Credentials
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }

    try {
      User? user = await _authService.signIn(email, password);
      if (user != null) {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();

        if (mounted) Navigator.pop(context); // Close loading popup

        if (studentDoc.exists) {
          bool isApproved = studentDoc['approved'] ?? false;
          if (!isApproved) {
            showSnackBar("Your account is pending approval.");
            return;
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, animation, __) => StudentScreen(userEmail: user.email!),
              transitionsBuilder: (_, animation, __, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ));
                final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: fadeAnimation, child: child),
                );
              },
            ),
          );
          return;
        }

        DocumentSnapshot librarianDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (librarianDoc.exists) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, animation, __) => LibrarianScreen(librarianEmail: user.email!),
              transitionsBuilder: (_, animation, __, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ));
                final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: fadeAnimation, child: child),
                );
              },
            ),
          );
          return;
        }

        showSnackBar("Invalid login. User not recognized.");
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      showSnackBar("Error: ${e.message}");
    } catch (e) {
      if (mounted) Navigator.pop(context);
      showSnackBar("An unexpected error occurred.");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: Stack(
        children: [
          Container(

            foregroundDecoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple,
                  Colors.purpleAccent,
                ],
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),



          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 100,
                      height: 100,
                    ),
                    const Text(
                      "BOOKTECH",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                    ),
                    const Text(
                      "DIGITAL LIBRARY",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                    ),
                    const SizedBox(height: 40),
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: "Username",
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                           // const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          rememberMe = value ?? false;
                                        });
                                      },
                                    ),
                                    Text("Remember Me",style: TextStyle(color: Colors.grey[600]),),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                  await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Password reset email sent.")),
                                  );
                                },child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                ),
                              ],
                            ),


                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                              ),
                              onPressed: authenticate,
                              child: const Text("LOG IN", style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 400),
                                    pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      final offsetAnimation = Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                      ));

                                      final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(animation);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: FadeTransition(opacity: fadeAnimation, child: child),
                                      );
                                    },
                                  ),
                                );
                              },

                              child: const Text(
                                "REGISTER",
                                style: TextStyle(color: Colors.purple),
                              ),
                            ),
                          ],

                        ),

                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

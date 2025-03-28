import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:echoseal/auth.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';

class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final User? user = Auth().currentUser;
  bool _isKeyboardVisible = false;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void updateKeyboardVisibility(bool isVisible) {
    setState(() {
      _isKeyboardVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 600,
                  height: 450,
                  child: Lottie.asset(
                    'assets/lottie/login_gradient.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 500,
                  height: 630,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(70),
                    ),
                  ),
                  child: LoginForm(
                    updateKeyboardVisibility: updateKeyboardVisibility,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _isKeyboardVisible ? 0.0 : 1.0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 630,
                    child: Lottie.asset('assets/lottie/login_animation.json'),
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

class LoginForm extends StatefulWidget {
  final Function(bool) updateKeyboardVisibility;

  LoginForm({required this.updateKeyboardVisibility});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
      widget.updateKeyboardVisibility(true);
    } else {
      if (!_emailFocusNode.hasFocus && !_passwordFocusNode.hasFocus) {
        widget.updateKeyboardVisibility(false);
      }
    }
  }

  Future<void> handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Successful")));

      Future.delayed(Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );

        Future.delayed(Duration(seconds: 4), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Text(
      "Revealing truth in every voice",
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 20),
    TextField(
    focusNode: _emailFocusNode,
    controller: emailController,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
    labelText: "Email",
    labelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(),
    ),
    ),
    SizedBox(height: 20),
    TextField(
    focusNode: _passwordFocusNode,
    controller: passwordController,
    obscureText: true,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
    labelText: "Password",
    labelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(),
    ),
    ),
    SizedBox(height: 30),
    ElevatedButton(
    onPressed: handleLogin,
    child: Text("Login"),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
    ),
    ),
    SizedBox(height: 20),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    "Don't have an account? ",
    style: TextStyle(color: Colors.white),
    ),
    GestureDetector(
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SignupScreen()),
    );
    },
    child: Text(
    "Create account here",
    style: TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ],
    ),
    ],
    );
   }
}
// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobidit_m1_iot/src/pages/login.dart';


class Register extends StatelessWidget {
   const Register({super.key});

  static const routeName = '/register';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Registration Form'),
        ),
        body: const SingleChildScrollView(
          child: Center(
            child: RegistrationForm(),
          ),
        ),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      //padding: const EdgeInsets.all(8.0),
      child: Container(
         color: Colors.grey[200],
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                  'Register to your account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 60.0,
                  width: 300.0,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 60.0,
                  width: 300.0,
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 60.0,
                  width: 300.0,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                        
                      );
                                          try {
   await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _emailController.text,
    password: _passwordController.text,
  );
} on FirebaseAuthException catch (e) {
  if (e.code == 'weak-password') {
    print('The password provided is too weak.');
  } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.');
  }
} catch (e) {
  print(e);
}
//redirect to login page
Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
                
                      
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Register'),
                ),
              ),
                   TextButton(
              child: const Text('You already have an account? Login here.'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}
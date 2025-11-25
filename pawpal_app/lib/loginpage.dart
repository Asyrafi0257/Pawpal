import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pawpal_app/home.dart';
import 'package:pawpal_app/model/user.dart';
import "package:pawpal_app/registerpage.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawpal_app/myconfig.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool visible = true;
  bool isChecked = false;

  late User user;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 280,
          child: Column(
            children: [
              SizedBox(height: 80),
              Text(
                "Login Page",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
              ),
              SizedBox(height: 50),

              //user email
              TextField(
                controller: emailController,
                // TextInputType => flutter memudahkan user dengan menyediakan jenis keyboard like keyboard email.
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              //user password
              TextField(
                controller: passwordController,
                //nak buat user boleh tengok password atau tidak
                obscureText: visible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (visible) {
                        visible = false;
                      } else {
                        visible = true;
                      }
                      //flutter akan update ui untk menjadi ui yang latest
                      setState(() {});
                    },
                    //nak buat icon mata untuk tengok password atau sembunyikan
                    icon: Icon(Icons.visibility),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),

              //forgot password
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(height: 10),

              //remember me
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  children: [
                    Text('Remember Me'),
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        isChecked = value!; //nak bagitahu value tu bukan null
                        setState(() {});
                        if (isChecked) {
                          if (emailController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            prefUpdate(isChecked);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Preferences Stored"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please fill your email and password",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            isChecked = false;
                            setState(() {});
                          }
                        } else {
                          prefUpdate(isChecked);
                          if (emailController.text.isEmpty &&
                              passwordController.text.isEmpty) {
                            return;
                            // do nothing
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Preferences Removed"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          emailController.clear();
                          passwordController.clear();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              //button login
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 20),

              //another to login
              SizedBox(
                child: Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(60, 5, 5, 0),
                  child: Row(
                    children: [
                      Text("Or Login with"),
                      SizedBox(width: 10),

                      Image.asset(
                        "assets/images/google_logo.png",
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(width: 10),

                      Image.asset(
                        "assets/images/facebook.png",
                        height: 25,
                        width: 25,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              Text("Don't have an account?"),

              //go to register page
              TextButton(
                onPressed: () {
                  //Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
                child: Text(
                  "Sign Up.",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.red[300],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //function for remember me either store or remove
  void prefUpdate(bool isChecked) async {
    //sharedPredferences ni macam mini database untuk simpan data simple or ringkas dalam app
    //getInstance ialah connect to storage
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isChecked) {
      prefs.setString('email', emailController.text);
      prefs.setString('password', passwordController.text);
      prefs.setBool('rememberMe', isChecked);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.remove('rememberMe');
    }
  }

  //function to load preferences
  void loadPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberMe = prefs.getBool('rememberMe');
      if (rememberMe != null && rememberMe) {
        String? email = prefs.getString('email');
        String? password = prefs.getString('password');
        emailController.text = email ?? '';
        passwordController.text = password ?? '';
        isChecked = true;
        setState(() {});
      }
    });
  }

  //function login
  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in email and password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    http
        .post(
          Uri.parse('${MyConfig.baseUrl}/pawpal/api/login_user.php'),
          body: {'email': email, 'password': password},
        )
        .then((response) {
          log(response.body); // tengok apa actual response dari server

          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            // print(jsonResponse);
            var resarray = jsonDecode(jsonResponse);
            if (resarray['status'] == 'success') {
              //print(resarray['data'][0]);
              user = User.fromJson(resarray['data'][0]);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Login successful"),
                  backgroundColor: Colors.green,
                ),
              );
              //Navigator.pop(context);
              // Navigate to home page or dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home(user: user)),
              );
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Handle successful login here
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login failed: ${response.statusCode}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }
}

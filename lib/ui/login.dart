import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'home.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  final Box _boxLogin = Hive.box("login");
  final Box _boxAccounts = Hive.box("accounts");

  @override
  Widget build(BuildContext context) {
    if (_boxLogin.get("loginStatus") ?? false) {
      return Home();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                './assets/logo.png', // Update with your company logo path
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey,",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6ACBEA), // Changed text color to #6ACBEA
                        ),
                      ),
                      const SizedBox(width: 5), // Added SizedBox for spacing
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back !",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6ACBEA), // Changed text color to #6ACBEA
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _controllerUsername,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color.fromARGB(255, 47, 47, 47)), // Changed border color to #6ACBEA
                  ),
                ),
                onEditingComplete: () =>
                    _focusNodePassword.requestFocus(),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter username.";
                  } else if (!_boxAccounts.containsKey(value)) {
                    return "Username is not registered.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controllerPassword,
                focusNode: _focusNodePassword,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: _obscurePassword
                        ? const Icon(Icons.visibility_outlined)
                        : const Icon(Icons.visibility_off_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color.fromARGB(255, 47, 47, 47)), // Changed border color to #6ACBEA
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password.";
                  } else if (value !=
                      _boxAccounts.get(_controllerUsername.text)) {
                    return "Wrong password.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Color(0xFF6ACBEA), // Changed button color to #6ACBEA
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(
                          Colors.white), // Overlay color
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _boxLogin.put("loginStatus", true);
                        _boxLogin.put(
                            "userName", _controllerUsername.text);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Home();
                            },
                          ),
                        );
                      }
                    },
                    child: const Text("Login", style: TextStyle(color: Colors.white)), // Changed text color to white
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Changed text color to #6ACBEA
                      ),
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Signup();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                            color: Color(0xFF6ACBEA), // Changed text color to #6ACBEA
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}

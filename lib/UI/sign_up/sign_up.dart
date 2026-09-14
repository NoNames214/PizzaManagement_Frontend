import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/data/repository/auth_repository.dart';
import '../login/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool isLoading = false;

  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final log = Logger();

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final userName = _userController.text.trim();
    final email = _emailController.text.trim();
    final passWord = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final confirm = _confirmController.text.trim();

    if (userName.isEmpty || email.isEmpty ||
        passWord.isEmpty || fullName.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return;
    }
    if (passWord != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password does not match",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await _authRepository.register(userName, passWord, email, fullName);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Register success",
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
        Navigator.pop(context);
        log.i("Register success: $success");
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                "Register failed",
                style: TextStyle(color: Colors.red),
              ),
          ),
        );
      }
    }
    catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
      log.e("Error: $e");
    }
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildMainButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null :  _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Create Account",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B6B),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Hook Pizza",
                  style: TextStyle(
                    color: Colors.white.withAlpha(70),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(80),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),
                      _buildInputField(
                        label: "Username",
                        icon: Icons.person_outline,
                        controller: _userController,
                      ),

                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Email",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),

                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Password",
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                        obscurePassword: _obscurePassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Full Name",
                        icon: Icons.person_outline,
                        controller: _fullNameController,
                      ),

                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Confirm Password",
                        icon: Icons.lock_outline,
                        controller: _confirmController,
                        isPassword: true,
                        obscurePassword: _obscureConfirm,
                        onTogglePassword: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),

                      const SizedBox(height: 35),
                      _buildMainButton(),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withAlpha(50),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Or",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withAlpha(50),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),
                      _buildSocialButton(),
                      const SizedBox(height: 25),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Login()
                                ),
                            );
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInputField({
  required String label,
  required IconData icon,
  required TextEditingController controller,
  bool isPassword = false,
  bool obscurePassword = false,
  VoidCallback? onTogglePassword,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: controller,
        obscureText: obscurePassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
          )
              : null,
          filled: true,
          fillColor: Colors.white.withAlpha(80),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}

Widget _buildSocialButton() {
  return Row(
    children: [
      Expanded(
        child: _socialTile(
          label: "Google",
          path: "assets/images/google.png",
          color: Colors.red.withAlpha(80),
        ),
      ),
      const SizedBox(width: 15),
      Expanded(
        child: _socialTile(
          label: "Facebook",
          path: "assets/images/facebook.png",
          color: Colors.blue.withAlpha(80),
        ),
      ),
    ],
  );
}

Widget _socialTile({
  required String label,
  required Color color,
  required String path,
}) {
  return Container(
    height: 55,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withAlpha(80)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(path, width: 28, height: 28),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
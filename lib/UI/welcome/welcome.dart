import 'package:flutter/material.dart';
import 'package:pizza_management/UI/login/login.dart';
import '../sign_up/sign_up.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildColorBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  _buildLogo(),
                  const Spacer(),
                  _buildCenterImage(),
                  const Text(
                    'Pizza delivered straight to you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildGetStartedButton(context),
                  const SizedBox(height: 20),
                  _buildSignup(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCenterImage() {
  final List<String> images = [
    'assets/images/pizza1.png',
    'assets/images/pizza2.png',
    'assets/images/pizza3.png',
  ];
  return SizedBox(
    height: 330,
    child: PageView.builder(
      controller: PageController(viewportFraction: 0.8),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: PageController(viewportFraction: 0.7),
          builder: (context, child) {
            return _imageCard(images[index]);
          },
        );
      },
    ),
  );
}

Widget _imageCard(String path) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.asset(path, height: 350, width: 250, fit: BoxFit.cover),
    ),
  );
}

Widget _buildGetStartedButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE57351),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      },
      child: const Text(
        "Get Started",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget _buildLogo() {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.local_pizza_sharp, color: Colors.white70, size: 60),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          "Pizza premium",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true,
          maxLines: 2,
        ),
      ),
      SizedBox(width: 10),
      Icon(Icons.local_pizza_sharp, color: Colors.white70, size: 60),
    ],
  );
}

Widget _buildSignup(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE57351),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUp()),
        );
      },
      child: const Text(
        "Don't have an account?",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget _buildColorBackground() {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF7A082), Color(0xFFFF6B6B)],
      ),
    ),
  );
}

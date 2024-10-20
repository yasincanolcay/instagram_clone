// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/auth/login_screen.dart';

class SignOutAlert extends StatelessWidget {
  const SignOutAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Hesabınızdan Çıkış Yapılsın mı?"),
      content: const Text("Bu hesaptan çıkış yapılacak"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "İptal",
          ),
        ),
        TextButton(
          onPressed: () async {
            await AuthMethods().signOutUser();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false);
          },
          child: const Text(
            "Çıkış",
          ),
        ),
      ],
    );
  }
}

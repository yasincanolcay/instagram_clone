import 'package:flutter/material.dart';
import 'package:instagram_clone/layouts/mobile_layout.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/auth/sign_in_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool isVisiblePassword = false;
  void loginUser() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      bool response = await AuthMethods()
          .loginUser(_emailController.text, _passwordController.text);
      if (mounted) {
        if (response) {
          Utils().showSnackBar(
            "Giriş yaptınız",
            context,
            backgroundColor,
          );
          //burada ana sayfaya git
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MobileLayout(),
            ),
            (route) => false,
          );
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      Utils().showSnackBar(
        "Lütfen gerekli alanları doldurunuz, boş alanlar var!",
        context,
        backgroundColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 16.0,
                ),
                Image.asset(
                  "assets/images/logo.png",
                  width: 50,
                  height: 50,
                ),
                const Text(
                  "Instagram",
                  style: generalStyle,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email Adresi",
                      prefixIcon: Icon(
                        Icons.mail,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: !isVisiblePassword,
                    decoration:  InputDecoration(
                      border: InputBorder.none,
                      hintText: "Şifreniz",
                      prefixIcon: const Icon(
                        Icons.lock,
                      ),
                      suffixIcon: IconButton(
                        onPressed: (){
                          setState(() {
                            isVisiblePassword = !isVisiblePassword;
                          });
                        },
                        icon:Icon(!isVisiblePassword?Icons.remove_red_eye_rounded:Icons.password,),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.blue),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        loginUser();
                      },
                      child: !isLoading
                          ? const Text(
                              "Giriş Yap",
                              style: style,
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Şifremi Unuttum",
                    style: style,
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabın Yok Mu? "),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                            (route) => false);
                      },
                      child: const Text("Kayıt Ol"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

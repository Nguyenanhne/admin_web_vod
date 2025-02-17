import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/sign_in_viewmodel.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignInViewModel>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: viewModel.emailController,
              decoration: InputDecoration(
                labelText: "Email admin",
                border: OutlineInputBorder()
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: viewModel.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder()
              ),
            ),
          ),
          Consumer<SignInViewModel>(
            builder: (context, loginVM, child) {
              return TextButton(
                onPressed: (){
                  loginVM.loginOnTap(context);
                },
                child: Text("Đăng nhập"),
              );
            }
          )
        ],
      ),
    );
  }
}

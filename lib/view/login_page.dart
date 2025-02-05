import 'package:admin/viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
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
          Consumer<LoginViewModel>(
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

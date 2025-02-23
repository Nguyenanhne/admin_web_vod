import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/routes_name.dart';
import '../service/auth_service.dart';

class SignInViewModel extends ChangeNotifier{

  final dialogTitleStyle = TextStyle(
      fontSize: 16,
      fontFamily: GoogleFonts.roboto().fontFamily,
      fontWeight: FontWeight.bold
  );
  final dialogContentStyle = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.roboto().fontFamily,
  );

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginOnTap(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    User? user = await Auth().signInAdmin(
      email: emailController.text,
      password: passwordController.text,
    );
    if(context.mounted){
      context.pop();
    }
   // Đóng loading dialog
    if (user != null) {
      if(context.mounted) {
        showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Thành công",
              style: dialogTitleStyle.copyWith(color: Colors.green),
            ),
            content: Text("Đăng nhập thành công!", style: dialogContentStyle),
          );
        },
      );
      }
      // Thêm `Future.delayed` để đảm bảo Dialog hiển thị trước khi chuyển trang
      await Future.delayed(const Duration(seconds: 1));

      if(context.mounted){
        context.pop();
        context.go(RoutesName.MENU_FILM);
      }
    } else {
      if(context.mounted) {
        showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Thất bại",
              style: dialogTitleStyle.copyWith(color: Colors.red),
            ),
            content: Text(
              "Email hoặc mật khẩu sai, vui lòng thử lại",
              style: dialogContentStyle,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (context.mounted) context.pop();
                },
                child: Text("Đóng", style: dialogContentStyle),
              ),
            ],
          );
        },
      );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/routes_name.dart';
import '../service/auth_service.dart';

class LoginViewModel extends ChangeNotifier{

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

  Future<void> loginOnTap(BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    User? user = await Auth().signInAdmin(email: emailController.text, password: passwordController.text);
    Navigator.pop(context);
    if(user != null){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text("Thành công", style: dialogTitleStyle.copyWith(color: Colors.green),),
          content: Text("Đăng nhập thành công!", style: dialogContentStyle,),
        );
      });
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
      // Navigator.pushNamed(context, RoutesName.MENU_FILM);
      context.go(RoutesName.MENU_FILM);
    }else{
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text("Thất bại", style: dialogTitleStyle.copyWith(color: Colors.red),),
          content: Text("Email hoặc mật khẩu sai, vui lòng thử lại", style: dialogContentStyle,),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("Đóng", style: dialogContentStyle))
          ],
        );
      });
    }
  }
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
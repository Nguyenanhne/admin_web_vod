import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/routes_name.dart';
import '../service/auth_service.dart';

class SignOutViewModel extends  ChangeNotifier{
  final dialogTitleStyle = TextStyle(
      fontSize: 16,
      fontFamily: GoogleFonts.roboto().fontFamily,
      fontWeight: FontWeight.bold
  );
  final dialogContentStyle = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.roboto().fontFamily,
  );
  Future<void> signOutOnTap(BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Auth().signOut();
    if(context.mounted){
      context.pop();
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Người dùng chưa đăng nhập");
    } else {
      print("Người dùng đã đăng nhập: ${user.email}");
    }

    if (user == null) {
      if(context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Thành công",
                style: dialogTitleStyle.copyWith(color: Colors.green),
              ),
              content: Text("Đăng xuất thành công!", style: dialogContentStyle),
            );
          },
        );
      }
      // Thêm `Future.delayed` để đảm bảo Dialog hiển thị trước khi chuyển trang
      await Future.delayed(const Duration(seconds: 1));

      if(context.mounted){
        context.pop();
        context.go(RoutesName.LOGIN); // Chuyển màn hình
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
                "Đăng xuất thất bại",
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
}
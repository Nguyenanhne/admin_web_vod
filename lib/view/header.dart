import 'package:admin/routes/routes_name.dart';
import 'package:admin/viewmodel/menu_app_viewmodel.dart';
import 'package:admin/viewmodel/sign_out_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../responsive.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    return isLoggedIn ? Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppViewModel>().controlMenu,
          ),
        Spacer(),
         Container(
          padding: EdgeInsets.symmetric(
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Image.asset(
                "profile.png",
                height: 38,
              ),
              Text("Admin"),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        )
      ],
    ) : SizedBox.shrink();
  }
}

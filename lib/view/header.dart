import 'package:admin/routes/routes_name.dart';
import 'package:admin/viewmodel/sign_out_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final signOutVM = Provider.of<SignOutViewModel>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth  < 1100;
        return Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Row(
            children: <Widget>[
              Image.asset('assets/logo.png', width: 100),
              Spacer(),
              if (isSmallScreen)
                PopupMenuButton<String>(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onSelected: (value) {
                    switch (value) {
                      case 'home':
                        // context.go(RoutesName.HOME);
                        break;
                      case 'movies':
                        context.go(RoutesName.MENU_FILM);
                        break;
                      case 'ffmpeg':
                        context.go(RoutesName.FFMPEG);
                        break;
                      case 'login':
                        context.go(RoutesName.LOGIN);
                        break;
                      case 'add':
                        context.go(RoutesName.ADD_NEW_FILM);
                      case 'logout':
                        signOutVM.signOutOnTap(context);
                        break;
                      case 'search':
                        context.go(RoutesName.SEARCH);
                    }
                  },
                  itemBuilder: (context) {
                    final user = FirebaseAuth.instance.currentUser; // Lấy thông tin user
                    return [
                      PopupMenuItem(value: 'home', child: Text('Trang chủ')),
                      PopupMenuItem(value: 'movies', child: Text('Phim')),
                      PopupMenuItem(value: 'ffmpeg', child: Text('FFmpeg')),
                      PopupMenuItem(value: 'add', child: Text('Thêm phim')),
                      PopupMenuItem(value: 'search', child: Text('Tìm kiếm')),
                      if (user == null) PopupMenuItem(value: 'login', child: Text('Đăng nhập')), // Ẩn khi đã đăng nhập
                      if (user != null) PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
                    ];
                  }
                )
              else ...[
                NavItem(title: 'Trang chủ', tapEvent: () {}),
                NavItem(title: 'Phim', tapEvent: () {context.go(RoutesName.MENU_FILM);}),
                NavItem(title: "FFmpeg", tapEvent: (){context.go(RoutesName.FFMPEG);}),
                NavItem(title: "Thêm phim", tapEvent: (){context.go(RoutesName.ADD_NEW_FILM);}),
                NavItem(title: "Tìm kiếm", tapEvent: (){context.go(RoutesName.SEARCH);}),
                if (user == null) NavItem(title: 'Đăng nhập', tapEvent: () { context.go(RoutesName.LOGIN); }), // Chỉ hiển thị khi chưa đăng nhập
                if (user != null) NavItem(title: "Đăng xuất", tapEvent: () { signOutVM.signOutOnTap(context); }), // Chỉ hiển thị khi đã đăng nhập
              ]
            ],
          ),
        );
      },
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({super.key, required this.title, required this.tapEvent});

  final String title;
  final GestureTapCallback tapEvent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tapEvent,
      hoverColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}

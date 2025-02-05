import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600;

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
                    // Xử lý sự kiện click vào menu item
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'home', child: Text('Trang chủ')),
                    PopupMenuItem(value: 'movies', child: Text('Phim')),
                    PopupMenuItem(value: 'login', child: Text('Đăng nhập')),
                    PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
                  ],
                )
              else ...[
                NavItem(title: 'Trang chủ', tapEvent: () {}),
                NavItem(title: 'Phim', tapEvent: () {}),
                NavItem(title: 'Đăng nhập', tapEvent: () {}),
                NavItem(title: "Đăng xuất", tapEvent: () {}),
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

import 'package:admin/routes/routes_name.dart';
import 'package:admin/viewmodel/sign_out_viewmodel.dart';
import 'package:admin/widget/add_type_dialog.dart';
import 'package:admin/widget/search_film_delegate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final signOutVM = Provider.of<SignOutViewModel>(context, listen: false);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("logo.png"),
          ),
          ExpansionTile(
            childrenPadding: EdgeInsets.symmetric(horizontal: 20),
            iconColor: Colors.white54,
            collapsedIconColor: Colors.white54,
            shape: Border(),
            title: Text("Quản lý phim", style: TextStyle(color: Colors.white54)),
            children: [
              DrawerListTile(
                title: "Tất cả phim",
                press: () => context.go(RoutesName.MENU_FILM),
              ),
              DrawerListTile(
                title: "Thêm phim",
                press: () => context.go(RoutesName.ADD_NEW_FILM),
              ),
              DrawerListTile(
                title: "Thêm thể loại",
                press: () => showDialog(context: context, builder: (context) => AddTypeDialog()),
              ),
              DrawerListTile(
                title: "Tìm kiếm",
                press: () {
                  showSearch(context: context, delegate: CustomSearchFilmDelegate());
                },
              ),
            ],
          ),
          DrawerListTile(
            title: "Quản lý user",
            press: () {
              context.go(RoutesName.USER);
            },
          ),

          DrawerListTile(
            title: "Ffmpeg",
            press: () {
              context.go(RoutesName.FFMPEG);
            },
          ),
          DrawerListTile(
            title: "Đăng xuất",
            press: () {
              signOutVM.signOutOnTap(context);
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.press,
  });

  final String title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}

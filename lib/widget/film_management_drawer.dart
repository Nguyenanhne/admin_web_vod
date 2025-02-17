import 'package:admin/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class FilmManagementDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("Quản lý phim", style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            title: Text("Danh sách phim"),
            onTap: () {
              context.go(RoutesName.MENU_FILM);
            },
          ),
          ListTile(
            title: Text("Thêm phim mới"),
            onTap: () {
              context.go(RoutesName.ADD_NEW_FILM);
            },
          ),
          ListTile(
            title: Text("Tìm kiếm phim"),
            onTap: () {
              context.go(RoutesName.SEARCH);
            },
          ),
          // ListTile(
          //   title: Text("Thêm phim mới"),
          //   onTap: () {
          //     context.go(RoutesName.ADD_NEW_FILM);
          //   },
          // ),
        ],
      ),
    );
  }
}

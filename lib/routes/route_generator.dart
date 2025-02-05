import 'package:admin/model/film_model.dart';
import 'package:admin/view/add_new_film.dart';
import 'package:admin/view/film_detail_page.dart';
import 'package:admin/view/login_page.dart';
import 'package:admin/view/menu_film_page.dart';
import 'package:flutter/material.dart';
import 'package:admin/routes/routes_name.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.MENU_FILM:
        return _GeneratePageRoute(
            widget: MenuFilmPage(),
            routeName: settings.name!
        );
      case RoutesName.DETAILED_FILM:
        return _GeneratePageRoute(
            widget: DetailedFilmPage(),
            routeName: settings.name!
        );
      case RoutesName.ADD_NEW_FILM:
        return _GeneratePageRoute(
            widget: AddNewFilmPage(),
            routeName: settings.name!
        );
      case RoutesName.LOGIN:
        return _GeneratePageRoute(widget: LoginPage(), routeName: settings.name!);
      default:
        return _GeneratePageRoute(
            widget: MenuFilmPage(), routeName: settings.name ?? "Unknown"
        );
    }
  }
}

class _GeneratePageRoute extends PageRouteBuilder {
  final Widget widget;
  final String routeName;

  _GeneratePageRoute({required this.widget, required this.routeName})
      : super(
    settings: RouteSettings(name: routeName),
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child) {
      return SlideTransition(
        textDirection: TextDirection.rtl,
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
class ErrorPage extends StatelessWidget {
  final String message;
  const ErrorPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Error")),
      body: Center(child: Text(message)),
    );
  }
}
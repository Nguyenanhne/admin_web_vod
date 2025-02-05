import 'package:admin/routes/route_generator.dart';
import 'package:admin/routes/routes_name.dart';
import 'package:admin/view/add_new_film.dart';
import 'package:admin/view/film_detail_page.dart';
import 'package:admin/view/login_page.dart';
import 'package:admin/view/menu_film_page.dart';
import 'package:admin/viewmodel/add_new_film_viewmodel.dart';
import 'package:admin/viewmodel/detailed_film_viewmodel.dart';
import 'package:admin/viewmodel/login_viewmodel.dart';
import 'package:admin/viewmodel/menu_film_viewmodel.dart';
import 'package:admin/viewmodel/type_dropdown_button_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'model/film_model.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuFilmViewModel()),
        ChangeNotifierProvider(create: (_) => DetailedFilmViewModel()),
        ChangeNotifierProvider(create: (_) => TypeDropdownButtonViewModel()),
        ChangeNotifierProvider(create: (_) => AddNewFilmViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel())
      ],
      child: MyApp(router: router),
    ),
  );
}
final GoRouter router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isGoingToLogin = state.uri.toString() == RoutesName.LOGIN;

    // Nếu chưa đăng nhập và không phải trang login, chuyển hướng về LOGIN
    if (!isLoggedIn && !isGoingToLogin) {
      return RoutesName.LOGIN;
    }

    // Nếu đã đăng nhập mà đang ở LOGIN, chuyển về MENU
    if (isLoggedIn && isGoingToLogin) {
      return RoutesName.MENU_FILM;
    }

    return null; // Không thay đổi điều hướng
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => LoginPage()),
    GoRoute(
      path: RoutesName.LOGIN,
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: RoutesName.MENU_FILM,
      builder: (context, state) => MenuFilmPage(),
    ),
    GoRoute(
      path: RoutesName.DETAILED_FILM,
      builder: (context, state) => DetailedFilmPage(),
    ),
    GoRoute(
      path: RoutesName.ADD_NEW_FILM,
      builder: (context, state) => AddNewFilmPage(),
    ),
  ],
);
class MyApp extends StatelessWidget {
  final router;
  MyApp({super.key, this.router});
  FilmModel film = FilmModel(
    id: '1',
    actors: 'Actor 1, Actor 2',
    age: 13,
    description: 'A thrilling action movie.',
    director: 'Director Name',
    name: 'Movie Title',
    upperName: "MOVIE TITLE",
    year: 2025,
    viewTotal: 1000,
    type: ['Gia đình', 'Hành động'],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'Flutter Demo',
    //   theme: ThemeData.dark(),
    //   home: Container(),
    //   initialRoute: RoutesName.LOGIN,
    //   onGenerateRoute: RouteGenerator.generateRoute,
    // );
  }
}


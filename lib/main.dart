import 'package:admin/responsive.dart';
import 'package:admin/routes/routes_name.dart';
import 'package:admin/slide_menu.dart';
import 'package:admin/view/add_new_film.dart';
import 'package:admin/view/add_type_viewmodel.dart';
import 'package:admin/view/ffmpeg.dart';
import 'package:admin/view/film_detail_page.dart';
import 'package:admin/view/header.dart';
import 'package:admin/view/menu_film_page.dart';
import 'package:admin/view/search_page.dart';
import 'package:admin/view/sign_in_page.dart';
import 'package:admin/view/user_management_page.dart';
import 'package:admin/viewmodel/add_new_film_viewmodel.dart';
import 'package:admin/viewmodel/detailed_film_viewmodel.dart';
import 'package:admin/viewmodel/ffmpeg_viewmodel.dart';
import 'package:admin/viewmodel/menu_app_viewmodel.dart';
import 'package:admin/viewmodel/menu_film_viewmodel.dart';
import 'package:admin/viewmodel/search_vm.dart';
import 'package:admin/viewmodel/sign_in_viewmodel.dart';
import 'package:admin/viewmodel/sign_out_viewmodel.dart';
import 'package:admin/viewmodel/type_dropdown_button_viewmodel.dart';
import 'package:admin/viewmodel/user_management_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'service/firebase_options.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProvider(create: (_) => SignInViewModel()),
        ChangeNotifierProvider(create: (_) => FfmpegViewModel()),
        ChangeNotifierProvider(create: (_) => SignOutViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => UserManagementViewModel()),
        ChangeNotifierProvider(create: (_) => AddTypeViewModel()),
        ChangeNotifierProvider(create: (_) => MenuAppViewModel()),

      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
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
      return null;
    },
    routes: [
      ShellRoute(
          builder: (context, state, child){
            final isLoggedIn = FirebaseAuth.instance.currentUser != null;
            return Scaffold(
              key:  context.read<MenuAppViewModel>().scaffoldKey,
              drawer: SideMenu(),
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // We want this side menu only for large screen
                  if(isLoggedIn)
                    if (Responsive.isDesktop(context))
                      Expanded(
                        child: SideMenu(),
                      ),
                  Expanded(
                    flex: 6,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: Header()),
                        SliverFillRemaining(
                          child: child,
                        )
                      ]
                    )
                  ),
                ],
              ),
            );
          },
          routes: [
            GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) => MenuFilmPage()),
            GoRoute(
              path: RoutesName.LOGIN,
              builder: (context, state) => SignInPage(),
            ),
            GoRoute(
              path: RoutesName.USER,
              builder: (context, state) => UserManagementPage(),
            ),
            GoRoute(
              path: RoutesName.SEARCH,
              builder: (context, state) => SearchPage(),
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
            GoRoute(
              path: RoutesName.FFMPEG,
              builder: (context, state) => FFMPEGPAGE(),
            ),
          ]
      ),
    ],
  );
}


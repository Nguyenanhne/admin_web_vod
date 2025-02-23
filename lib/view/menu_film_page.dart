import 'package:admin/view/film_detail_page.dart';
import 'package:admin/view/header.dart';
import 'package:admin/viewmodel/menu_film_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../responsive.dart';
import '../widget/search_film_delegate.dart';

class MenuFilmPage extends StatefulWidget {
  const MenuFilmPage({super.key});

  @override
  State<MenuFilmPage> createState() => _MenuFilmPageState();
}

class _MenuFilmPageState extends State<MenuFilmPage> {

  late Future<void> initListFilms;

  final contentStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: GoogleFonts.roboto().fontFamily
  );

  @override
  void initState() {
    super.initState();
    final homeVM = Provider.of<MenuFilmViewModel>(context, listen: false);
    initListFilms = homeVM.fetchFilms();
  }
  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<MenuFilmViewModel>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = Responsive.isMobile(context);
        bool isMediumScreen = Responsive.isDesktop(context);
        int crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 5 : 5);
        return Scaffold(
          body: CustomScrollView(
            controller: homeVM.scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Danh sách phim", style: contentStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                ),
                actions: [
                  InkWell(
                    onTap: (){
                      showSearch(context: context, delegate: CustomSearchFilmDelegate());
                    },
                    child: Row(
                      children: [
                        Text("Tìm kiếm", style: contentStyle.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(width: 20),
                        Icon(
                          Icons.search
                        )
                      ],
                    ),
                  ),
                ],
              ),
              FutureBuilder(
                  future: initListFilms,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting){
                      return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    }else if(snapshot.hasError){
                      return SliverToBoxAdapter(child:  Center(child: Text('Lỗi: ${snapshot.error}', style: contentStyle)));
                    }
                    return Consumer<MenuFilmViewModel>(
                      builder: (context, menuViewModel, child) {
                        // Check if there are films to display
                        if (menuViewModel.films.isEmpty) {
                          return SliverToBoxAdapter(child: Center(child: Text('Không có phim nao!', style: contentStyle)));
                        }
                        return SliverPadding(
                          padding: EdgeInsets.all(10),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (ctx, index) {
                                if (index == menuViewModel.films.length) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final film = menuViewModel.films[index];
                                return InkWell(
                                  onTap: () {
                                    menuViewModel.filmOnTap(context, film);
                                  },
                                  child: Card(
                                    elevation: 5,
                                    child: GridTile(
                                      child: Image.network(
                                        film.url,
                                        fit: BoxFit.cover,
                                      ),
                                      footer: GridTileBar(
                                        backgroundColor: Colors.black54,
                                        title: Text(
                                          film.name,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: menuViewModel.films.length + (menuViewModel.isLoading ? 1 : 0),
                            ),
                          ),
                        );
                        // return LayoutBuilder(
                        //   builder: (context, constraints) {
                        //     return
                        //     // return GridView.builder(
                        //     //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //     //     crossAxisCount: crossAxisCount,
                        //     //     crossAxisSpacing: 10,
                        //     //     mainAxisSpacing: 10,
                        //     //     childAspectRatio: 0.7,
                        //     //   ),
                        //     //   itemCount: menuViewModel.films.length + (menuViewModel.isLoading ? 1 : 0),
                        //     //   itemBuilder: (ctx, index) {
                        //     //     if (index == menuViewModel.films.length) {
                        //     //       return Align(
                        //     //         alignment: Alignment.center,
                        //     //         child: CircularProgressIndicator(),
                        //     //       );
                        //     //     }
                        //     //     final film = menuViewModel.films[index];
                        //     //     return InkWell(
                        //     //       onTap: (){
                        //     //         menuViewModel.filmOnTap(context, film);
                        //     //       },
                        //     //       child: Card(
                        //     //         elevation: 5,
                        //     //         child: GridTile(
                        //     //           child: Image.network(
                        //     //             film.url,
                        //     //             fit: BoxFit.cover,
                        //     //           ),
                        //     //           footer: GridTileBar(
                        //     //             backgroundColor: Colors.black54,
                        //     //             title: Text(
                        //     //               film.name,
                        //     //               textAlign: TextAlign.center,
                        //     //             ),
                        //     //           ),
                        //     //         ),
                        //     //       ),
                        //     //     );
                        //     //   },
                        //     // );
                        //   }
                        // );
                      },
                    );
                  }
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              homeVM.fetchMoreFilms();
            },
            child: const Icon(Icons.add),
          ),
        );
      }
    );
  }
}

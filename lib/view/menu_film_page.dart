import 'package:admin/view/film_detail_page.dart';
import 'package:admin/view/header.dart';
import 'package:admin/viewmodel/menu_film_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      body: SizedBox(
        child: Column(
          children: [
            FutureBuilder(
              future: initListFilms,
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting){
                  return LinearProgressIndicator();
                }else{
                  return SizedBox.shrink();
                }
              }
            ),
            Header(),
            Expanded(
              child: FutureBuilder(
                future: initListFilms,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return SizedBox();
                  }else if(snapshot.hasError){
                    return Scaffold(body: Text('Lỗi: ${snapshot.error}', style: contentStyle));
                  }
                  return Consumer<MenuFilmViewModel>(
                    builder: (context, menuViewModel, child) {
                      // Check if there are films to display
                      if (menuViewModel.films.isEmpty) {
                        return Scaffold(body: Text('No movies found', style: contentStyle));
                      }
                      // Display films in a GridView
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: menuViewModel.films.length + (menuViewModel.isLoading ? 1 : 0),
                        itemBuilder: (ctx, index) {
                          if (index == menuViewModel.films.length) {
                            return Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            );
                          }
                          final film = menuViewModel.films[index];
                          return InkWell(
                            onTap: (){
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
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Call fetchFilms to load more films
      //     Provider.of<HomeViewModel>(context, listen: false).fetchMoreFilms();
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

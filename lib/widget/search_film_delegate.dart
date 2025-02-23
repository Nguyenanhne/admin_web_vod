import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../model/film_model.dart';
import '../service/film_service.dart';
import '../viewmodel/search_vm.dart';

class CustomSearchFilmDelegate extends SearchDelegate {
  final FilmService filmService = FilmService();

  final contentStyle = TextStyle(
      fontFamily: GoogleFonts.roboto().fontFamily,
      color: Colors.white
  );
  @override

  String? get searchFieldLabel => "Tìm kiếm";

  TextStyle? get searchFieldStyle => contentStyle;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.black),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black,),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Vui lòng nhập tên', style: contentStyle,));
    }
    return FutureBuilder<List<FilmModel>>(
      future: filmService.searchFilmNamesByName(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không có phim phù hợp', style: contentStyle));
        }
        final  searchVM = Provider.of<SearchViewModel>(context, listen: false);
        final films = snapshot.data!;
        return ListView.builder(
          itemCount: films.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(films[index].name, style: contentStyle),
              onTap: () {
                searchVM.searchOnTap(context, films[index]);
              },
            );
          },
        );
      },
    );
  }
}

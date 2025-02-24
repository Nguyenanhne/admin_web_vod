import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widget/search_film_delegate.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final contentStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: GoogleFonts.roboto().fontFamily
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Tìm kiếm phim", style: contentStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
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
        ],
      ),
    );
  }
}

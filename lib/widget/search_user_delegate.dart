import 'package:admin/widget/user_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/user_model.dart';
import '../service/user_service.dart';
class CustomSearchUserDelegate extends SearchDelegate {
  final UserService userService = UserService();
  //
  final contentStyle = TextStyle(
      fontFamily: GoogleFonts.roboto().fontFamily,
      fontSize: 14
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
      return Center(child: Text('Vui lòng nhập email', style: contentStyle,));
    }
    return FutureBuilder<List<UserModel>>(
      future: userService.searchUserByEmail(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không có email phù hợp', style: contentStyle));
        }
        // final  searchVM = Provider.of<SearchViewModel>(context, listen: false);
        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final email = users[index].email;
            final name = users[index].name;
            final isActivated = users[index].isActivated;
            final uid  = users[index].id;
            return userItem(contentStyle: contentStyle, email: email, name: name, isActivated: isActivated, index: index, uid: uid);
          },
        );
      },
    );
  }
}

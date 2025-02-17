import 'package:admin/service/user_service.dart';
import 'package:admin/viewmodel/user_management_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final contentStyle = TextStyle(
    fontFamily: GoogleFonts.roboto().fontFamily,
    fontSize: 14
  );
  late Future<void> loadUsers;
  @override
  void initState() {
    super.initState();
    final userVM = Provider.of<UserManagementViewModel>(context, listen: false);
    loadUsers = userVM.fetchUsers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (){
                showSearch(context: context, delegate: CustomSearchUserDelegate());
              },
              icon: Icon(Icons.search)
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Danh sách người dùng", style: contentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),),
            ),
          ),
          FutureBuilder(
            future: loadUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting){
                return SliverToBoxAdapter(child:  Center(child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Đang tải danh sách", style: contentStyle,),
                    )
                  ],
                )));
              }
              else if(snapshot.hasError){
                return SliverToBoxAdapter(child: Center(child: Text("Lỗi", style: contentStyle,)));
              }
              return Consumer<UserManagementViewModel>(
                builder: (context , userVM, child) {
                  if(userVM.users.isEmpty){
                    return SliverToBoxAdapter(child: Center(child: Text("Không có user nào", style: contentStyle)));
                  }
                  return SliverList.separated(
                    itemCount: userVM.users.length,
                    itemBuilder: (context, index){
                      final email = userVM.users[index].email;
                      final name = userVM.users[index].name;
                      final isActivated = userVM.users[index].isActivated;
                      return userItem(contentStyle: contentStyle, email: email, name: name, isActivated: isActivated);
                    },
                    separatorBuilder: (context, index){
                      return SizedBox(height: 10);
                    }
                  );
                }
              );
            }
          )
        ],
      ),
    );
  }
}
class CustomSearchUserDelegate extends SearchDelegate {
  final UserService userService = UserService();
  //
  final contentStyle = TextStyle(
      fontFamily: GoogleFonts.roboto().fontFamily,
      fontSize: 14
  );
  @override
  String? get searchFieldLabel => "Tìm kiếm";
  @override
  TextStyle? get searchFieldStyle => super.searchFieldStyle;

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
            return userItem(contentStyle: contentStyle, email: email, name: name, isActivated: isActivated);
          },
        );
      },
    );
  }
}

class userItem extends StatelessWidget {
  const userItem({
    super.key,
    required this.contentStyle,
    required this.email,
    required this.name,
    required this.isActivated,
  });

  final TextStyle contentStyle;
  final String email;
  final String name;
  final bool isActivated;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text("Email: ", style: contentStyle.copyWith(fontWeight: FontWeight.bold),),
          Text(email, style: contentStyle,),
        ],
      ),
      subtitle: Row(
        children: [
          Text("Tên hiển thị: ", style: contentStyle.copyWith(fontWeight: FontWeight.bold)),
          Text(name, style: contentStyle),
        ],
      ),
      leading: CircleAvatar(child: Icon(Icons.person), backgroundColor: isActivated ? Colors.green : Colors.red),
      trailing: PopupMenuButton(
          icon: Icon(Icons.settings),
          itemBuilder: (context){
            return [
              (isActivated) ? PopupMenuItem(child: Text("Khóa tài khoản"), value: "block") : PopupMenuItem(child: Text("Mở khóa tài khoản"), value: "unblock")
            ];
          }
      ),
    );
  }
}

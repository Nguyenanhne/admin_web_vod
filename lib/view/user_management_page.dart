import 'package:admin/viewmodel/user_management_viewmodel.dart';
import 'package:admin/widget/search_user_delegate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widget/user_item.dart';
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
    final userVM = Provider.of<UserManagementViewModel>(context, listen: false);
    return Scaffold(
      body: CustomScrollView(
        controller: userVM.scrollController,
        slivers: [
          SliverAppBar(
            title: Text("Danh sách người dùng", style: contentStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),),
            actions: [
              IconButton(
                  onPressed: (){
                    showSearch(context: context, delegate: CustomSearchUserDelegate());
                  },
                  icon: Icon(Icons.search)
              )
            ],
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
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
                    return SliverToBoxAdapter(child: Center(child: Text("Không có người dùng nào", style: contentStyle)));
                  }
                  return SliverList.separated(
                    itemCount: userVM.users.length + (userVM.isLoading ? 1 : 0),
                    itemBuilder: (context, index){
                      if (index == userVM.users.length) {
                        return Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        );
                      }
                      final email = userVM.users[index].email;
                      final name = userVM.users[index].name;
                      final isActivated = userVM.users[index].isActivated;
                      final uid  = userVM.users[index].id;
                      return userItem(contentStyle: contentStyle, uid: uid, email: email, name: name, isActivated: isActivated, index: index);
                    },
                    separatorBuilder: (context, index){
                      return SizedBox(height: 50);
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

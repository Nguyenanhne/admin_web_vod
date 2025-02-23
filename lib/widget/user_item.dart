import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/user_management_viewmodel.dart';

class userItem extends StatelessWidget {
  const userItem({
    super.key,
    required this.uid,
    required this.index,
    required this.contentStyle,
    required this.email,
    required this.name,
    required this.isActivated,
  });

  final TextStyle contentStyle;
  final String email;
  final String name;
  final bool isActivated;
  final String uid;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementViewModel>(
        builder: (context, userVM, child) {
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
                    (isActivated)
                        ? PopupMenuItem(child: Text("Khóa tài khoản"), value: "block", onTap: () => userVM.blockOnTap(uid, index, context))
                        : PopupMenuItem(child: Text("Mở khóa tài khoản"), value: "unblock", onTap: () => userVM.unBlockOnTap(uid, index, context))
                  ];
                }
            ),
          );
        }
    );
  }
}

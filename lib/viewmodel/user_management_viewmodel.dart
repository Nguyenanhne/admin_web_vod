import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:admin/model/user_model.dart';
import 'package:admin/service/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../utils/utils.dart';

class UserManagementViewModel extends ChangeNotifier{
  final UserService userService = UserService();
  final _limit = 10;
  List<UserModel> _users = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  DocumentSnapshot? get lastDocument => _lastDocument;

  Future<void> fetchUsers() async {
    reset();
    try {
      final result = await userService.fetchListUser(
        limit: _limit,
        lastDocument: _lastDocument,
      );
      _users.addAll(result['users']);
      _lastDocument = result['lastDocument'];
    } catch (e) {
      print('Error fetching users: $e');
    }
  }
  Future<bool> unBlock(String uid) async{
    final url = Uri.parse(UNBLOCK);
    User? user = FirebaseAuth.instance.currentUser;
    String? idToken = await user?.getIdToken();
    if (idToken == null) {
      print("Không có token để gửi");
      return false;
    }
    try {
      // Gửi yêu cầu POST tới server
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',  // Đảm bảo token hợp lệ
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'uid': uid}),  // Truyền dữ liệu (uid của user cần block)
      );

      if (response.statusCode == 200) {
        print("Mở khóa tài khoản thành công");
        return true;
      } else {
        print('Mở khóa không thành công. Status code: ${response.statusCode}');
        final data = json.decode(response.body);
        print('${data['message']}');
        return false;
      }
    } catch (e) {
      print('Lỗi mở khóa tài khoản: $e');
      return false;
    }
  }
  Future<void> unBlockOnTap(String uid, int index, BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    print("unBlock OnTap");
    bool isActivated = await unBlock(uid);
    if (isActivated){
      users[index].isActivated = true;
      notifyListeners();
    }
    if(context.mounted){
      context.pop();
    }
  }
  Future<bool> block(String uid) async {
    final url = Uri.parse(BLOCK);
    User? user = FirebaseAuth.instance.currentUser;
    String? idToken = await user?.getIdToken();
    if (idToken == null) {
      print("Không có token để gửi");
      return false;
    }
    try {
      // Gửi yêu cầu POST tới server
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',  // Đảm bảo token hợp lệ
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'uid': uid}),  // Truyền dữ liệu (uid của user cần block)
      );

      if (response.statusCode == 200) {
        print("Khóa tài khoản thành công");
        return true;
      } else {
        print('Khóa không thành công. Status code: ${response.statusCode}');
        final data = json.decode(response.body);
        print('${data['message']}');
        return false;
      }
    } catch (e) {
      print('Lỗi khóa tài khoản: $e');
      return false;
    }
  }

  Future<void> blockOnTap(String uid, int index, BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    print("block OnTap");
    bool isActivated = await block(uid);
    if (isActivated){
      users[index].isActivated = false;
      notifyListeners();
    }
    if(context.mounted){
      context.pop();
    }
  }
  void reset(){
    _users.clear();
    _lastDocument = null;
  }
}
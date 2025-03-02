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
  bool _hasMore = true;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  DocumentSnapshot? get lastDocument => _lastDocument;

  ScrollController scrollController = ScrollController();


  UserManagementViewModel(){
    scrollController.addListener((){
      onScroll();
    });
  }
  void onScroll(){
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLoading && _hasMore) {
      fetchMoreUsers();
    }
  }
  Future<void> fetchUsers() async {
    reset();
    try {
      final result = await userService.fetchListUser(
        limit: _limit,
        lastDocument: _lastDocument,
      );
      _users.addAll(result['users']);
      _lastDocument = result['lastDocument'];
      _hasMore = _users.length == _limit;

    } catch (e) {
      print('Error fetching users: $e');
    }
  }
  Future<void> fetchMoreUsers() async{
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    try {
      final result = await userService.fetchListUser(
        limit: _limit,
        lastDocument: _lastDocument,
      );
      final List<UserModel> users = result['users'] as List<UserModel>;
      final DocumentSnapshot? lastDocument = result['lastDocument'] as DocumentSnapshot?;
      if (users.isNotEmpty) {
        _users.addAll(users);

        _lastDocument = lastDocument;

        _hasMore = users.length == _limit;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('Error fetching users: $e');
    }finally {
      _isLoading = false;
      notifyListeners();
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

  Future<void> unBlockOnTap(String uid, int index, BuildContext context) async{
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    bool isActivated = await unBlock(uid);
    if (isActivated){
      print("setState");
      users[index].isActivated = true;
      notifyListeners();
    }
    if(context.mounted){
      print("pop");
      context.pop();
    }
  }

  Future<void> blockOnTap(String uid, int index, BuildContext context) async{
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    bool isActivated = await block(uid);
    if (isActivated){
      print("setState");
      users[index].isActivated = false;
      notifyListeners();
    }
    if(context.mounted){
      print("pop");
      context.pop();
    }
  }

  void reset(){
    _users.clear();
    _lastDocument = null;
  }

}
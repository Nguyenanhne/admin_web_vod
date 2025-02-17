import 'package:admin/model/user_model.dart';
import 'package:admin/service/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
  void reset(){
    _users.clear();
    _lastDocument = null;
  }
}
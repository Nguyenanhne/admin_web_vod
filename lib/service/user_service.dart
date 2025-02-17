import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user_model.dart';

class UserService{
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchListUser({
    required int limit,
    required DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = firestore.collection('User').where("role", isEqualTo: "user").limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      List<UserModel> users = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
      }).toList();
      print(users.length);
      return {
        'users': users,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      print('Error fetching users: $e');
      return {};
    }
  }
  Future<List<UserModel>> searchUserByEmail(String nameQuery) async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('User')
          .where('email', isGreaterThanOrEqualTo: nameQuery)
          .where('email', isLessThanOrEqualTo: nameQuery + '\uf8ff')
          .get();

      List<UserModel> users = querySnapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      return users;

    } catch (e) {
      print('Error searching user: $e');
      return [];
    }
  }


}
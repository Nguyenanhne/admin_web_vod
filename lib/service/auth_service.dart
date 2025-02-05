import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User?> signInAdmin({required String email, required String password}) async {
    try {
      // Đăng nhập bằng email và password
      final cred = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final User? user = cred.user;

      if (user == null) return null;

      // Truy vấn Firestore để lấy role
      final userDoc = await firestore.collection('User').doc(user.uid).get();

      if (userDoc.exists) {
        String? role = userDoc.data()?['role'];
        if (role == "admin") {
          print("Đăng nhập thành công với quyền admin.");
          return user;
        } else {
          print("Tài khoản không có quyền admin.");
          await firebaseAuth.signOut(); // Đăng xuất nếu không phải admin
          return null;
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Tên đăng nhập hoặc mật khẩu không hợp lệ: $e");
    } catch (e) {
      print("Lỗi đăng nhập: $e");
    }
    return null;
  }
}

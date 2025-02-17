import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/utils.dart';

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
          // await sendTokenToServer();
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


  Future<bool> sendTokenToServer() async {
    try {
      // Lấy Firebase ID Token
      User? user = FirebaseAuth.instance.currentUser;
      String? idToken = await user?.getIdToken();
      print(idToken);
      if (idToken == null) {
        print("Không có token để gửi");
        return false;
      }

      // URL của API server (thay bằng URL của bạn)
      String url = CHECK_TOKEN;

      // Gửi yêu cầu HTTP POST với token trong header Authorization
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      // Kiểm tra kết quả từ server
      if (response.statusCode == 200) {
        print('Token hợp lệ. Dữ liệu đã được gửi thành công!');
        return true;
      } else {
        print('Lỗi: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Có lỗi xảy ra: $e');
      return false;
    }
  }

  Future<void> pingServer() async {
    try {
      // URL của server mà bạn muốn ping (thay thế bằng URL của bạn)
      String url = PING;

      // Gửi yêu cầu GET tới server
      final response = await http.get(Uri.parse(url));

      // Kiểm tra mã trạng thái HTTP trả về
      if (response.statusCode == 200) {
        print('Server hoạt động bình thường');
      } else {
        print('Lỗi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Không thể kết nối đến server: $e');
    }
  }
  Future<void> signOut() async{
    await FirebaseAuth.instance.signOut();
  }

}

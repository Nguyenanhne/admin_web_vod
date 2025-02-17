import 'package:http/http.dart' as http;

import '../utils/utils.dart';


class VideoService{
  Future<void> pingServer() async {
    try {
      final response = await http.get(Uri.parse(PING));
      if (response.statusCode == 200) {
        print("✅ Server trả lời: ${response.body}"); // Đọc body trực tiếp
      } else {
        print("⚠ Server trả về lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Không thể kết nối server: $e");
    }
  }
}
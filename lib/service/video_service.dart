import 'package:http/http.dart' as http;
import 'dart:convert';


class VideoService{
  final String baseUrl = "http://localhost:3000";
  Future<void> pingServer() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/ping"));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("✅ Server trả lời: ${data['message']}");
      } else {
        print("⚠️ Server trả về lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Không thể kết nối server: $e");
    }
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../utils/utils.dart';

class FfmpegViewModel extends ChangeNotifier {
  final dialogTitleStyle = TextStyle(
      fontSize: 16,
      fontFamily: GoogleFonts.roboto().fontFamily,
      fontWeight: FontWeight.bold
  );
  final dialogContentStyle = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.roboto().fontFamily,
  );

  TextEditingController pathController = TextEditingController();
  bool _isProcess = false;
  bool _isTrailer = false;
  bool _isVideo = false;
  List<int> _selectedResolutions = [];
  html.File? _selectedFiles;
  List<int> _resolutions = [144, 240, 360, 480, 720, 1080];

  bool get isVideo => _isVideo;
  bool get isTrailer => _isTrailer;
  bool get isProcess => _isProcess;
  html.File? get selectedFiles => _selectedFiles;
  List<int> get selectedResolutions => _selectedResolutions;
  List<int> get resolutions => _resolutions;

  void reset(){
     _isProcess = false;
     _isTrailer = false;
     _isVideo = false;
     _selectedFiles = null;
     pathController.clear();
     _selectedResolutions.clear();
  }

  void toggleResolution(int resolution) {
    if (_selectedResolutions.contains(resolution)) {
      _selectedResolutions.remove(resolution);
    } else {
      _selectedResolutions.add(resolution);
    }
    notifyListeners();
    print(_selectedResolutions.toString());
  }

  void trailerOnTap(){
     _isTrailer = true;
     _isVideo = false;
     notifyListeners();
   }

  void videoOnTap(){
    _isTrailer = false;
    _isVideo = true;
    notifyListeners();
  }

  Future<void> uploadToServerOnTap(BuildContext context) async {
     if(!_isVideo && !_isTrailer){
       showDialog(context: context, builder: (context){
         return AlertDialog(
           title: Text("Lỗi", style: dialogTitleStyle.copyWith(color: Colors.red),),
           content: Text("Vui lòng chọn Video hoặc Trailer!", style: dialogContentStyle,),
           actions: [
             TextButton(onPressed: () { context.pop(); },
                 child: Text("Xác nhận", style: dialogContentStyle))
           ],
         );
       });
       return;
     }
     else if(_selectedFiles == null){
       showDialog(context: context, builder: (context){
         return AlertDialog(
           title: Text("Lỗi tệp", style: dialogTitleStyle.copyWith(color: Colors.red),),
           content: Text("Vui lòng chọn tệp!", style: dialogContentStyle,),
           actions: [
             TextButton(onPressed: () { context.pop(); },
                 child: Text("Xác nhận", style: dialogContentStyle))
           ],
         );
       });
       return;
     }
     else if(_isVideo && _selectedResolutions.isEmpty){
       showDialog(context: context, builder: (context){
         return AlertDialog(
           title: Text("Lỗi độ phân giải", style: dialogTitleStyle.copyWith(color: Colors.red),),
           content: Text("Vui lòng chọn độ phân giải!", style: dialogContentStyle,),
           actions: [
             TextButton(onPressed: () { context.pop(); },
                 child: Text("Xác nhận", style: dialogContentStyle))
           ],
         );
       });

       return;
     }
    
    _isProcess = true;
    notifyListeners();

    bool clear = false;
    bool upload = false;
    bool hlsProcess = false;
    
    clear = await clearUploadFolder();
    if (!clear){
      if(context.mounted){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Lỗi xóa video cũ ", style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Lỗi xóa video cũ, thử lại sau!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () { context.pop(); },
                  child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
      _isProcess = false;
      notifyListeners();
      return;
    }

    upload  = await uploadFileInChunks(_selectedFiles!);
    if (upload){
      print("Upload phim thành công");
      hlsProcess = await processHLS("video.mp4");
    } else{
      if(context.mounted){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Lỗi upload phim", style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Đã có lỗi, vui lòng thử lại!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () { context.pop(); },
                  child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
      _isProcess = false;
      notifyListeners();
      return;
    }
    if(hlsProcess){
      print("Cắt phim thành công");
      if(context.mounted){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Thành công", style: dialogTitleStyle.copyWith(color: Colors.green),),
            content: Text("Đã xử lý video thành công!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () { context.pop(); },
                  child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
    }
    _isProcess = false;
    reset();
    notifyListeners();
  }

  Future<void> pickFileOnTap() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement()..accept = 'video/mp4';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      if (uploadInput.files!.isNotEmpty) {
        _selectedFiles = uploadInput.files!.first;
        pathController.text = "Tệp đã chọn: ${_selectedFiles!.name}";
        print("Đã chọn file: ${_selectedFiles!.name} (${_selectedFiles!.size} bytes)");
        notifyListeners(); // Cập nhật UI
      }
    });
  }

  Future<bool> clearUploadFolder() async {
    Uri uri = _isTrailer
        ? Uri.parse(CLEAR_UPLOAD_TRAILER)
        : Uri.parse(CLEAR_UPLOAD_VIDEO);    try {

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(" Success: ${data['message']}");
        return true;
      } else {
        print("Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }

  Future<bool> uploadFileInChunks(html.File file) async {
    final int chunkSize = 5 * 1024 * 1024; // 5 MB

    int totalChunks = (file.size / chunkSize).ceil();
    int uploadedChunks = 0;

    for (int i = 0; i < totalChunks; i++) {
      int start = i * chunkSize;
      int end = (start + chunkSize > file.size) ? file.size : start + chunkSize;

      Uint8List chunkData = await readFileChunk(file, start, end);

      bool success = await uploadChunk(file.name, i, totalChunks, chunkData);

      if (success) {
        uploadedChunks++;
        print("Chunk $i uploaded successfully");
      } else {
        print("Chunk $i failed to upload");
        return false;
      }
    }
    if (uploadedChunks == totalChunks) {
      print("Upload hoàn tất!");
      return true;
    }
    return false;
  }

  Future<Uint8List> readFileChunk(html.File file, int start, int end) async {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.readAsArrayBuffer(file.slice(start, end));
    reader.onLoadEnd.listen((_) {
      completer.complete(reader.result as Uint8List);
    });

    return completer.future;
  }

  Future<bool> uploadChunk(String fileName, int index, int totalChunks, Uint8List chunkData) async {
      Uri uri = _isTrailer
          ? Uri.parse(UPLOAD_TRAILER_TO_SERVER)
          : Uri.parse(UPLOAD_VIDEO_TO_SERVER);
    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['fileName'] = fileName
        ..fields['chunkIndex'] = index.toString()
        ..fields['totalChunks'] = totalChunks.toString()
        ..files.add(http.MultipartFile.fromBytes('file', chunkData, filename: "$fileName.part$index"));
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi khi upload chunk: $e");
      return false;
    }
  }

  Future<bool> processHLS(String fileName) async{
    Uri uri;
    if(_isTrailer){
      uri = Uri.parse(CUT_TRAILER_HLS);
    }else{
      uri = Uri.parse(CUT_VIDEO_HLS);
    }
    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          "fileName": fileName,
          "resolutions": _selectedResolutions
        }
      ),
    );
     if (response.statusCode == 200) {
      print("Cắt phim thành công!");
      return true;
    } else {
      print("Cắt phim thất bại!");
      return false;
    }
  }


}

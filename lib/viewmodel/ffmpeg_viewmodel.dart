import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
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

    bool upload = false;
    bool hlsProcess = false;

    upload = await uploadFile();

    if (upload){
      print("Upload phim thành công");
      hlsProcess = await processHLS("video.mp4");
    } else{
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
      _isProcess = false;
      notifyListeners();
      return;
    }
    if(hlsProcess){
      print("Cắt phim thành công");
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text("Thành công", style: dialogTitleStyle.copyWith(color: Colors.red),),
          content: Text("Đã xử lý video thành công!", style: dialogContentStyle,),
          actions: [
            TextButton(onPressed: () { context.pop(); },
                child: Text("Xác nhận", style: dialogContentStyle))
          ],
        );
      });
    }
    _isProcess = false;
    reset();
    notifyListeners();
    // return _success;
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

  Future<bool> uploadFile() async {
    if (_selectedFiles == null) {
      print("Chưa chọn file!");
      return false;
    }

    Uri uri = _isTrailer
        ? Uri.parse(UPLOAD_TRAILER_TO_SERVER)
        : Uri.parse(UPLOAD_VIDEO_TO_SERVER);

    final formData = html.FormData();
    formData.appendBlob('file', _selectedFiles!, "video.mp4");

    final request = html.HttpRequest();
    final completer = Completer<bool>();

    request.open('POST', uri.toString(), async: true);
    request.send(formData);

    request.onLoadEnd.listen((event) {
      if (request.status == 200) {
        print("Upload phim thành công!");
        completer.complete(true);
      } else {
        print("Lỗi khi upload phim : ${request.status} - ${request.responseText}");
        completer.complete(false);
      }
    });
    return completer.future;
  }

  Future<bool> processHLS(String fileName) async{
     print("Tiến hành cắt phim");
    var uri = null;
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

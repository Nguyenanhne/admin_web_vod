import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:admin/routes/routes_name.dart';
import 'package:admin/service/film_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../model/film_model.dart';
import 'package:http/http.dart' as http;
import '../service/auth_service.dart';
import '../service/type_service.dart';
import '../service/video_service.dart';
import '../utils/utils.dart';

class DetailedFilmViewModel extends ChangeNotifier{

  final dialogTitleStyle = TextStyle(
    fontSize: 16,
    fontFamily: GoogleFonts.roboto().fontFamily,
    fontWeight: FontWeight.bold
  );
  final dialogContentStyle = TextStyle(
      fontSize: 14,
      fontFamily: GoogleFonts.roboto().fontFamily,
  );


  final maxTypeSelected = 3;
  final maxAgeSelected = 1;
  final maxYearSelected = 1;

  final TypeService _typeService = TypeService();
  final FilmService _filmService = FilmService();

  final formKey = GlobalKey<FormState>();

  List<DropdownItem<int>> _ageItems = [];
  List<DropdownItem<int>> _yearItems = [];
  List<DropdownItem<String>> _typeItems = [];
  bool _isEdited = false;
  bool _isSaving = false;
  FilmModel? _film;
  FilmModel? _originalFilm;
  List<String> _types = [];
  List<String> _selectedTypes = [];
  int _selectedAge = 18;
  int _selectedYear = 2025;

  FilmModel? get film => _film;
  bool get isEdited => _isEdited;
  bool get isSaving => _isSaving;
  List<DropdownItem<int>> get ageItems => _ageItems;
  List<DropdownItem<int>> get yearItems => _yearItems;
  List<DropdownItem<String>> get typeItems => _typeItems;

  PlatformFile? _selectedImage;
  PlatformFile? get selectedImage => _selectedImage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController actorsController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final MultiSelectController<int> ageSelectController = MultiSelectController<int>();
  final MultiSelectController<String> typeSelectController = MultiSelectController<String>();
  final MultiSelectController<int> yearSelectController = MultiSelectController<int>();


  Future<void> initState() async {
    reset();
    final filmID = html.window.sessionStorage['filmID'];
    if (filmID != null) {
      await getFilmDetailed(filmID);
      if (_film != null){
        _types = await _typeService.getAllTypes();
        Future.wait([
          initTypeItems(),
          initAgeItems(),
          initYearItems(),
        ]);
      }
    }else{
      _film = null;
    }
  }

  Future<void> getFilmDetailed(String filmID) async {
    _film = await _filmService.getFilmByFilmID(filmID: filmID);
    if(_film != null){
      // Lưu bản sao gốc
      _originalFilm = FilmModel.fromMap(_film!.toMap(),_film!.id);
      _originalFilm!.setUrl(_film!.url);

      nameController.text = _film!.name;
      descriptionController.text = _film!.description;
      actorsController.text = _film!.actors;
      directorController.text = _film!.director;
    }
  }

  Future<void> initTypeItems() async {
    _selectedTypes = _film!.type;
    //generate list type option
    _typeItems = _types.map((type) => DropdownItem<String>(label: type, value: type, selected: _selectedTypes.contains(type))).toList();
    // set list item DropdownButton
    typeSelectController.setItems(_typeItems);
    }

  Future<void> initAgeItems() async {
    _selectedAge = _film!.age;
    final buffer = List.generate(20, (index) => (index + 6));
    //generate list age option
    _ageItems = buffer.map((age) => DropdownItem<int>(label: "$age +", value: age, selected: _selectedAge == age)).toList();
    // set list item DropdownButton
    ageSelectController.setItems(_ageItems);
  }

  Future<void> initYearItems() async {
    _selectedYear = _film!.year;
    final buffer = List.generate(25, (index) => (index + 2001));
    //generate list year option
    _yearItems = buffer.map((year) => DropdownItem<int>(label: "$year", value: year, selected: _selectedYear == year)).toList();
    yearSelectController.setItems(_yearItems);
  }

  Future<void> editOnTap(BuildContext context) async {
    if (!_isEdited) {
      _isEdited = true;
      notifyListeners();
      return;
    }
    if (!formKey.currentState!.validate()) {
      print('Lỗi khi lưu phim: Form không hợp lệ.');
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final verifyToken = await Auth().sendTokenToServer();
    if (context.mounted) {
      context.pop();
    }
    if(!verifyToken){
      if (context.mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text("Lỗi xác thực",
              style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Token không hợp lệ!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {
                context.pop();
              },
                  child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
      return;
    }

    _isSaving = true;
    _isEdited = false;

    notifyListeners();

    bool isFilmUpdated = true;
    bool isImageUpdated = true;

    if (_film != null) {
      isFilmUpdated = await updateFilm();
    }

    if (_film != null && _selectedImage != null) {
      isImageUpdated = await updateImage();
    }

    if (isFilmUpdated || isImageUpdated) {
      print("Cập nhật thành công!");
      _isEdited = false; // Hoàn tất chỉnh sửa nếu có ít nhất 1 thành công
      if(context.mounted){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.info, color: Colors.green),
                Text("Thành công", style: dialogTitleStyle.copyWith(color: Colors.green),),
              ],
            ),
            content: Text("Cập nhật thành công!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
    } else {
      print("Cập nhật không thành công!");
      _isEdited = true; // Giữ chế độ chỉnh sửa nếu không có cập nhật nào thành công
      if (context.mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red),
                Text("Thất bại",
                  style: dialogTitleStyle.copyWith(color: Colors.red),),
              ],
            ),
            content: Text("Cập nhật thất bại, vui lòng thử lại sau",
              style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
    }
    _isSaving = false;
    await initState();
    notifyListeners();
  }

  Future<bool> updateFilm() async {
    if(_film != null){
      FilmModel newFilm = FilmModel(
        type: typeSelectController.selectedItems.map((item) => item.value).toList(),
        id: _film!.id,
        actors: actorsController.text,
        age: ageSelectController.selectedItems.map((item) => item.value).first,
        description: descriptionController.text,
        director: directorController.text,
        name: nameController.text,
        upperName: nameController.text.toUpperCase(),
        year: yearSelectController.selectedItems.map((item) => item.value).first,
        viewTotal: _film!.viewTotal
      );
      debugPrint(newFilm.toMap().toString());
      return await _filmService.updateFilm(newFilm);
    }else{
      return false;
    }
  }

  Future<bool> updateImage() async{
    if (_film != null && _selectedImage != null){
      await _filmService.addNewImage(_selectedImage!, _film!.id);
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteTrailer() async{
    try {
      final response = await http.post(
        Uri.parse(DELETE_VIDEO),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"folderPath": "trailer/${_film!.id}"}),
      );
      if (response.statusCode == 200) {
        print("✅  Xóa trailer ${_film!.id} lên thành công!");
        return true;
      } else {
        print ("❌ Lỗi xóa: ${response.body}");
        return false;
      }
    } catch (e) {
      print ("❌ Lỗi xóa: ");
      return false;
    }
  }

  Future<bool> deleteVideo() async{
    try {
      final response = await http.post(
        Uri.parse(DELETE_VIDEO),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"folderPath": "video/${_film!.id}"}),
      );
      if (response.statusCode == 200) {
        print("✅  Xóa Video ${_film!.id} lên thành công!");
        return true;
      } else {
        print ("❌ Lỗi xóa: ${response.body}");
        return false;
      }
    } catch (e) {
      print ("❌ Lỗi xóa: ");
      return false;
    }
  }

  Future<bool> deleteFilm() async{
    if(_film != null){
      return _filmService.deleteFilm(_film!.id);
    }
    return false;
  }

  Future<bool> deleteImage() async{
    if(_film != null){
      return _filmService.deleteImage(_film!.id);
    }
    return false;
  }

  Future<bool> uploadTrailer() async{
    try {
      final response = await http.post(
        Uri.parse(UPLOAD_TRAILER_TO_R2),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": _film!.id}),
      );
      if (response.statusCode == 200) {
        print("✅ Tải trailer lên thành công!");
        return true;
      } else {
        print ("❌ Lỗi tải lên: ${response.body}");
        return false;
      }
    } catch (e) {
      print ("❌ Lỗi tải lên: ");
      return false;
    }
  }

  Future<bool> uploadVideo() async{
    try {
      final response = await http.post(
        Uri.parse(UPLOAD_VIDEO_TO_R2),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": _film!.id}),
      );
      if (response.statusCode == 200) {
        print("✅ Tải video lên thành công!");
        return true;
      } else {
        print ("❌ Lỗi tải lên: ${response.body}");
        return false;
      }
    } catch (e) {
      print ("❌ Lỗi tải lên: ");
      return false;
    }
  }

  Future<bool> checkTrailerUpload() async{
    try {
      final response = await http.post(
        Uri.parse(CHECK_TRAILER_UPLOAD),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": _film!.id}),
      );
      if (response.statusCode == 200) {
        print("✅ Sãn sàng tải lên");
        return true;
      } else {
        print ("❌ Lỗi tải lên: ${response.body}");
        return false;
      }
    } catch (e) {
      print ("❌ Lỗi tải lên: ");
      return false;
    }
  }

  Future<bool> checkVideoUpload() async{
    try {
      final response = await http.post(
        Uri.parse(CHECK_VIDEO_UPLOAD),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": _film!.id}),
      );
      if (response.statusCode == 200) {
        print("✅ Sãn sàng tải lên");
        return true;
      } else {
        print ("❌ Lỗi tải lên: ${response.body}");
        return false;
      }
    } catch (e) {
      print ("❌ Lỗi tải lên: ");
      return false;
    }
  }

  Future<bool> checkTrailerR2() async{
    try {
      final response = await http.post(
        Uri.parse(CHECK_TRAILER_R2),
        headers: {"film-id": _film!.id},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['trailerUrl'] != null) {
          print("Trailer đã tồn tại");
          return true;
        } else {
          print("Trailer không tồn tại");
          return false;
        }
      } else if (response.statusCode == 400) {
        print ("Thiếu id ${response.body}");
        return false;
      }
      else  if (response.statusCode == 500) {
        print ("Lỗi server ${response.body}");
        return false;
      }
    } catch (e) {
      print ("Lỗi lấy trailer: ");
      return false;
    }
    return false;
  }

  Future<bool> checkVideoR2() async{
    try {
      final response = await http.post(
        Uri.parse(CHECK_VIDEO_R2),
        headers: {"film-id" : _film!.id},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['videoUrl'] != null) {
          print("Video đã tồn tại");
          return true;
        } else {
          print("Video không tồn tại");
          return false;
        }
      } else if (response.statusCode == 400) {
        print ("Thiếu id ${response.body}");
        return false;
      }
      else  if (response.statusCode == 500) {
        print ("Lỗi server ${response.body}");
        return false;
      }
    } catch (e) {
      print ("❌ Lỗi lấy video: ");
      return false;
    }
    return false;
  }

  Future<void> uploadTrailerOnTap(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    bool next = false;
    bool isAlready = false;

    //Kiểm tra đã upload chưa?
    isAlready = await checkTrailerR2();

    if(context.mounted){
      context.pop();
    }

    if(isAlready){
      if(context.mounted){
        next = await showDialog<bool>(context: context, builder: (context) {
          return AlertDialog(
            title: Text("Cảnh báo",
              style: dialogTitleStyle.copyWith(color: Colors.yellow),),
            content: Text("Đã tồn tại trailer, bạn có muốn thay thế?", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {
                context.pop(true);
              },
                  child: Text("Xác nhận", style: dialogContentStyle)
              ),
              TextButton(onPressed: () {
                context.pop(false);
                return;
              },
                  child: Text("Hủy", style: dialogContentStyle)
              )
            ],
          );
        }) ?? false;
      }
      if (next == false) {
        return;
      }
    }

    if(context.mounted){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    final verifyToken = await Auth().sendTokenToServer();

    if (context.mounted){
      context.pop();
    }

    if(!verifyToken){
      if (context.mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text("Lỗi xác thực",
              style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Token không hợp lệ!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {
                context.pop();
              },
                  child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
      return;
    }

    _isSaving = true;
    _isEdited = false;

    notifyListeners();

    bool isTrailerUpdated = false;
    isAlready = false;

    if (_film != null) {
      isAlready = await checkTrailerUpload();
    }

    if (isAlready){
      isTrailerUpdated = await uploadTrailer();
      if (isTrailerUpdated) {
        print("Upload trailer thành công!");
        _isEdited = false; // Hoàn tất chỉnh sửa nếu có ít nhất 1 thành công
        if (context.mounted) {
          showDialog(context: context, builder: (context) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info, color: Colors.green),
                  Text("Thành công",
                    style: dialogTitleStyle.copyWith(color: Colors.green),),
                ],
              ),
              content: Text("Cập nhật thành công!", style: dialogContentStyle,),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text("Xác nhận", style: dialogContentStyle))
              ],
            );
          });
        }
      } else {
        print("Upload trailer không thành công!");
        _isEdited = true; // Giữ chế độ chỉnh sửa nếu không có cập nhật nào thành công
        if (context.mounted) {
          showDialog(context: context, builder: (context) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red),
                  Text("Thất bại",
                    style: dialogTitleStyle.copyWith(color: Colors.red),),
                ],
              ),
              content: Text("Cập nhật thất bại, vui lòng thử lại sau",
                style: dialogContentStyle,),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text("Xác nhận", style: dialogContentStyle))
              ],
            );
          });
        }
      }
    } else{
      print("Không có trailer nào để upload");
      if (context.mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red),
                Text("Thất bại",
                  style: dialogTitleStyle.copyWith(color: Colors.red),),
              ],
            ),
            content: Text(
              "Không có trailer nào để upload ", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
    }

    _isSaving = false;
    notifyListeners();
  }

  Future<void> uploadVideoOnTap(BuildContext context) async{
    //loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    bool next = false;
    bool isAlready = false;
    //Kiểm tra đã upload chưa?
    isAlready = await checkVideoR2();

    if(context.mounted){
      context.pop();
    }

    if(isAlready){
      if(context.mounted){
        next = await showDialog<bool>(context: context, builder: (context) {
          return AlertDialog(
            title: Text("Cảnh báo",
              style: dialogTitleStyle.copyWith(color: Colors.yellow),),
            content: Text("Đã tồn tại trailer, bạn có muốn thay thế?", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {
                context.pop(true);
              },
                child: Text("Xác nhận", style: dialogContentStyle)
              ),
              TextButton(onPressed: () {
                context.pop(false);
                return;
              },
                child: Text("Hủy", style: dialogContentStyle)
              )
            ],
          );
        }) ?? false;
      }
      if (next == false) {
        return;
      }
    }

    if(context.mounted){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    //Kiểm tra token
    final verifyToken = await Auth().sendTokenToServer();

    if(context.mounted){
      context.pop();
    }

    if(!verifyToken){
      if(context.mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text("Lỗi xác thực",
              style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Token không hợp lệ!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {
                context.pop();
              },
                  child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
      return;
    }

    //Tiến hành upload
    _isSaving = true;
    _isEdited = false;
    notifyListeners();

    bool isVideoUpdated = false;
    isAlready = false;

    if (_film != null) {
      //Kiểm tra source
      isAlready = await checkVideoUpload();
    }

    if (isAlready){
      isVideoUpdated = await uploadVideo();
      if (isVideoUpdated) {
        print("Upload trailer thành công!");
        _isEdited = false; // Hoàn tất chỉnh sửa nếu có ít nhất 1 thành công
        if (context.mounted) {
          showDialog(context: context, builder: (context) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info, color: Colors.green),
                  Text("Thành công",
                    style: dialogTitleStyle.copyWith(color: Colors.green),),
                ],
              ),
              content: Text("Cập nhật thành công!", style: dialogContentStyle,),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text("Xác nhận", style: dialogContentStyle))
              ],
            );
          });
        }
      } else {
        print("Upload video không thành công!");
        _isEdited = true; // Giữ chế độ chỉnh sửa nếu không có cập nhật nào thành công
        if(context.mounted) {
          showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red),
                Text("Thất bại", style: dialogTitleStyle.copyWith(color: Colors.red),),
              ],
            ),
            content: Text("Cập nhật thất bại, vui lòng thử lại sau", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
        }
      }
    } else {
      print("Không có video nào để upload");
      if (context.mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red),
                Text("Thất bại",
                  style: dialogTitleStyle.copyWith(color: Colors.red),),
              ],
            ),
            content: Text(
              "Không có video nào để upload ", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
    }

    _isSaving = false;
    notifyListeners();
  }

  void deleteOnTap(BuildContext context) async {
    BuildContext newContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final verifyToken = await Auth().sendTokenToServer();
    if (context.mounted) {
      context.pop();
    }
    if(!verifyToken){
      if (context.mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text("Lỗi xác thực",
              style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Token không hợp lệ!", style: dialogContentStyle,),
            actions: [
              TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text("Xác nhận", style: dialogContentStyle)
              )
            ],
          );
        });
        return;
      }
    }

    if(_film != null) {
      if (context.mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.warning, color: Colors.yellow),
                Text("Thông báo",
                  style: dialogTitleStyle.copyWith(color: Colors.amberAccent),),
              ],
            ),
            content: Text(
              "Bạn có muốn xóa phim này không?", style: dialogContentStyle,),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text("Hủy", style: dialogContentStyle)),
              TextButton(
                  onPressed: () async {
                    context.pop();
                    showDialog(
                      context: newContext,
                      barrierDismissible: false,
                      builder: (context) =>
                          Center(child: CircularProgressIndicator()),
                    );

                    newContext.pop();
                    bool isImageDeleted = await deleteImage();
                    bool isFilmDeleted = await deleteFilm();
                    bool isTrailerDeleted = await deleteTrailer();
                    bool isVideoDeleted = await deleteVideo();

                    if (isImageDeleted && isFilmDeleted && isTrailerDeleted && isVideoDeleted) {
                      if(context.mounted){
                        showDialog(context: newContext, builder: (context) {
                          return AlertDialog(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green,),
                                Text("Thành công", style: dialogTitleStyle),
                              ],
                            ),
                            content: Text("Phim đã được xóa thành công!",
                                style: dialogContentStyle),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Navigator.pop(newContext);
                                  newContext.pop();
                                  context.go(RoutesName.MENU_FILM);
                                  // Navigator.popAndPushNamed(context, RoutesName.MENU_FILM);
                                },
                                child: Text("Đóng", style: dialogContentStyle),
                              ),
                            ],
                          );
                        });
                      }
                    }
                    else{
                      if(context.mounted){
                        showDialog(context: newContext, builder: (context) {
                            return AlertDialog(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  Text("Thất bại", style: dialogTitleStyle),
                                ],
                              ),
                              content: Text("Xóa phim thất bại!",
                                  style: dialogContentStyle),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Navigator.pop(newContext);
                                    newContext.pop();
                                  },
                                  child: Text("Đóng", style: dialogContentStyle),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text("Xác nhận", style: dialogContentStyle)
              )
            ],
          );
        });
      }
    }
  }

  void cancelEditOnTap() {
    initState();
    notifyListeners();
  }

  Future<void> pickImage() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      final path = result.files.first;
      _selectedImage = path;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    actorsController.dispose();
    directorController.dispose();
    ageSelectController.dispose();
    typeSelectController.dispose();
    yearSelectController.dispose();
    super.dispose();
  }

  void ping(BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    VideoService videoService = VideoService();
    await videoService.pingServer();
    if(context.mounted){
      context.pop();
    }
  }

  void reset() {
    _typeItems = [];
    _ageItems = [];
    _yearItems = [];
    _selectedTypes = [];
    _selectedAge = 18;
    _selectedYear = 2025;
    nameController.clear();
    descriptionController.clear();
    actorsController.clear();
    directorController.clear();
    ageSelectController.clearAll();
    typeSelectController.clearAll();
    yearSelectController.clearAll();
    _isEdited = false;
    _isSaving = false;
    _selectedImage = null;
  }
}
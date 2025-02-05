import 'dart:html' as html;
import 'package:admin/routes/routes_name.dart';
import 'package:admin/service/film_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../model/film_model.dart';
import 'dart:io' as io;

import '../service/type_service.dart';
import '../service/video_service.dart';

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
    } else {
      print("Cập nhật không thành công!");
      _isEdited = true; // Giữ chế độ chỉnh sửa nếu không có cập nhật nào thành công
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

  void deleteOnTap(BuildContext context){
    BuildContext newContext = context;
    if(_film != null){
      bool isFilmUpdated = true;
      bool isImageUpdated = true;
      showDialog(context: newContext, builder: (context){
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.yellow),
              Text("Thông báo", style: dialogTitleStyle.copyWith(color: Colors.amberAccent),),
            ],
          ),
          content: Text("Bạn có muốn xóa phim này không?", style: dialogContentStyle,),
          actions: [
            TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Hủy", style: dialogContentStyle)),
            TextButton(
              onPressed: () async{
                Navigator.pop(context);

                showDialog(
                  context: newContext,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );

                Navigator.pop(newContext);

                bool isImageDeleted = await deleteImage();
                bool isFilmDeleted = await deleteFilm();

                if (isImageDeleted && isFilmDeleted){
                  showDialog(
                    context: newContext,
                    builder: (context) {
                      return AlertDialog(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green,),
                            Text("Thành công", style: dialogTitleStyle),
                          ],
                        ),
                        content: Text("Phim đã được xóa thành công!", style: dialogContentStyle),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(newContext);
                              Navigator.popAndPushNamed(context, RoutesName.MENU_FILM);
                            },
                            child: Text("Đóng", style: dialogContentStyle),
                          ),
                        ],
                      );
                    },
                  );
                  showDialog(
                    context: newContext,
                    builder: (context) {
                      return AlertDialog(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            Text("Thất bại", style: dialogTitleStyle),
                          ],
                        ),
                        content: Text("Xóa phim thất bại!", style: dialogContentStyle),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(newContext);
                            },
                            child: Text("Đóng", style: dialogContentStyle),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("Xác nhận", style: dialogContentStyle)
            )
          ],
        );
      });
    }
  }
  void cancelEditOnTap() {
    initState();
    notifyListeners();
    // if (_originalFilm != null) {
    //   // Khôi phục dữ liệu gốc
    //   _film = FilmModel.fromMap(_originalFilm!.toMap(), _originalFilm!.id);
    //   _film!.setUrl(_originalFilm!.url);
    //   nameController.text = _film!.name;
    //   descriptionController.text = _film!.description;
    //   actorsController.text = _film!.actors;
    //   directorController.text = _film!.director;
    //   Future.wait([
    //     initTypeItems(),
    //     initAgeItems(),
    //     initYearItems(),
    //   ]);
    //   _isEdited = false;
    //   _selectedImage = null;
    //   notifyListeners();
    // }
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

  void ping() async{
    VideoService videoService = VideoService();
    await videoService.pingServer();
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
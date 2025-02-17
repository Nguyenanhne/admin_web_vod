import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'dart:html';
import '../model/film_model.dart';
import '../routes/routes_name.dart';
import '../service/auth_service.dart';
import '../service/film_service.dart';
import '../service/type_service.dart';

class AddNewFilmViewModel extends ChangeNotifier{
  final dialogTitleStyle = TextStyle(
      fontSize: 16,
      fontFamily: GoogleFonts.roboto().fontFamily,
      fontWeight: FontWeight.bold
  );
  final dialogContentStyle = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.roboto().fontFamily,
  );

  final formKey = GlobalKey<FormState>();
  final TypeService _typeService = TypeService();
  final FilmService _filmService = FilmService();

  final maxTypeSelected = 3;
  final maxAgeSelected = 1;
  final maxYearSelected = 1;

  bool _selectedImageState = true;
  bool get selectedImageState => _selectedImageState;

  PlatformFile? _selectedImage;
  PlatformFile? get selectedImage => _selectedImage;

  List<DropdownItem<int>> _ageItems = [];
  List<DropdownItem<int>> _yearItems = [];
  List<DropdownItem<String>> _typeItems = [];
  bool _isSaving = false;
  FilmModel? _film;
  List<String> _types = [];

  FilmModel? get film => _film;
  bool get isSaving => _isSaving;
  List<DropdownItem<int>> get ageItems => _ageItems;
  List<DropdownItem<int>> get yearItems => _yearItems;
  List<DropdownItem<String>> get typeItems => _typeItems;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController actorsController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final MultiSelectController<int> ageSelectController = MultiSelectController<int>();
  final MultiSelectController<String> typeSelectController = MultiSelectController<String>();
  final MultiSelectController<int> yearSelectController = MultiSelectController<int>();

  Future<void> initState() async{
    reset();
    _types = await _typeService.getAllTypes();
    if(_types.isNotEmpty){
      Future.wait([
        initTypeItems(),
        initAgeItems(),
        initYearItems()
      ]);
    }
  }
  Future<void> initTypeItems() async {
    //generate list type option
    _typeItems = _types.map((type) => DropdownItem<String>(label: type, value: type, selected: false)).toList();
    // set list item DropdownButton
    typeSelectController.setItems(_typeItems);
    }
  Future<void> initAgeItems() async {
    final buffer = List.generate(20, (index) => (index + 6));
    //generate list age option
    _ageItems = buffer.map((age) => DropdownItem<int>(label: "$age +", value: age, selected: false)).toList();
    // set list item DropdownButton
    ageSelectController.setItems(_ageItems);
  }
  Future<void> initYearItems() async {
    final buffer = List.generate(25, (index) => (index + 2001));
    //generate list year option
    _yearItems = buffer.map((year) => DropdownItem<int>(label: "$year", value: year, selected: false)).toList();
    yearSelectController.setItems(_yearItems);
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
  Future<void> saveOnTap(BuildContext context) async{
    if(formKey.currentState!.validate() && _selectedImage != null){
      //check token
      final verifyToken = await Auth().sendTokenToServer();
      if(!verifyToken){
        if (!context.mounted) return;
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Lỗi xác thực", style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Token không hợp lệ!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () { context.pop(); },
              child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
        return;
      }

      _isSaving = true;
      notifyListeners();
      bool isFilmUpdated = false;
      bool isImageUpdated = false;
      String? newID = await uploadFilm();
      if(newID != null){
        isImageUpdated = await uploadImage(newID);
      }
      if(newID != null){
        isFilmUpdated = true;
      }
      if (isFilmUpdated && isImageUpdated) {
        print("Thêm phim thành công!");
        if (!context.mounted) return;
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Thành công", style: dialogTitleStyle.copyWith(color: Colors.green),),
            content: Text("Thêm phim thành công!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: (){
                window.sessionStorage['filmID'] = newID!;
                context.go(RoutesName.DETAILED_FILM);
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      } else {
        print("Thêm phim không thành công!");
        if (!context.mounted) return;
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Thất bại", style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Thêm phim thất bại, vui lòng thử lại sau", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: (){
                context.pop();
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
      _isSaving = false;
      notifyListeners();
    }
    if(_selectedImage == null){
      _selectedImageState = false;
      notifyListeners();
    }
  }
  void newOnTap() async{
    reset();
    notifyListeners();
  }
  Future<String?> uploadFilm() async {
    FilmModel newFilm = FilmModel(
        type: typeSelectController.selectedItems.map((item) => item.value)
            .toList(),
        id: "",
        actors: actorsController.text,
        age: ageSelectController.selectedItems
            .map((item) => item.value)
            .first,
        description: descriptionController.text,
        director: directorController.text,
        name: nameController.text,
        upperName: nameController.text.toUpperCase(),
        year: yearSelectController.selectedItems
            .map((item) => item.value)
            .first,
        viewTotal: 0
    );
    debugPrint(newFilm.toMap().toString());
    String? newID;
    return newID = await _filmService.addNewFilm(newFilm);
  }
  Future<bool> uploadImage(String newID) async{
    if(_selectedImage != null){
      return await _filmService.addNewImage(_selectedImage!, newID);
    }
    return false;
  }
  void reset() {
    _typeItems = [];
    _ageItems = [];
    _yearItems = [];
    nameController.clear();
    descriptionController.clear();
    actorsController.clear();
    directorController.clear();
    ageSelectController.clearAll();
    typeSelectController.clearAll();
    yearSelectController.clearAll();
    _isSaving = false;
    _selectedImage = null;
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
}
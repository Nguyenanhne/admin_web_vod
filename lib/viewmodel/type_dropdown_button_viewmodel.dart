import 'package:flutter/cupertino.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../model/film_model.dart';
import '../service/type_service.dart';

class TypeDropdownButtonViewModel extends ChangeNotifier{
  final TypeService _typeService = TypeService();

  MultiSelectController<String> multiSelectController = MultiSelectController<String>();
  List<String> _types = [];
  List<String> get types => _types;
  List<String> _selectedTypes = [];

  List<DropdownItem<String>> get dropdownItems {
    return _types.map((type) => DropdownItem<String>(
      label: type,
      value: type,
      selected: _selectedTypes.contains(type)
    )).toList();
  }

  Future<void> initTypes(FilmModel film) async {
    _types = await _typeService.getAllTypes();
    _selectedTypes = film.type;
    notifyListeners();
  }

}
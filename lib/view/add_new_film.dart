import 'package:admin/viewmodel/add_new_film_viewmodel.dart';
import 'package:admin/widget/add_type_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';

import '../widget/film_management_drawer.dart';
class AddNewFilmPage extends StatefulWidget {
  const AddNewFilmPage({super.key});
  @override
  State<AddNewFilmPage> createState() => _AddNewFilmPageState();
}

class _AddNewFilmPageState extends State<AddNewFilmPage> {
  final contentStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: GoogleFonts.roboto().fontFamily
  );
  final labelStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    fontFamily: GoogleFonts.roboto().fontFamily
  );
  final titleStyle = TextStyle(
    fontSize: 25,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: GoogleFonts.roboto().fontFamily
  );
  final widthImage = 300.0;
  final heightImage = 450.0;

  late Future<void> init;
  @override
  void initState() {
    super.initState();
    final addNewFilmVM = Provider.of<AddNewFilmViewModel>(context, listen: false);
    init = addNewFilmVM.initState();
  }
  @override
  Widget build(BuildContext context) {
    final addNewFilmVM  = Provider.of<AddNewFilmViewModel>(context, listen: false);
    return Scaffold(
      body: FutureBuilder(
        future: init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child:  CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Lỗi: ${snapshot.error}', style: contentStyle);
          }else if(addNewFilmVM.typeItems.isEmpty){
            return Center(child: Text("Lỗi khi tải", style: contentStyle));
          }else{
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth  < 1100;
              return Consumer<AddNewFilmViewModel>(
                  builder: (context,addNewFilmVM, child ) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          (addNewFilmVM.isSaving) ? LinearProgressIndicator() : SizedBox.shrink(),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "THÊM PHIM MỚI",
                                  style: titleStyle,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(),
                              ),
                              Consumer<AddNewFilmViewModel>(
                                builder: (context, addNewFilmVM, child) {
                                  return Tooltip(
                                    message: "Làm mới",
                                    child: IconButton(
                                      icon: Icon(
                                          Icons.add
                                      ),
                                      onPressed: () {
                                        addNewFilmVM.newOnTap();
                                      },
                                    ),
                                  );
                                }
                              ),
                              Consumer<AddNewFilmViewModel>(
                                builder: (context, addNewFilmVM, child) {
                                  return Tooltip(
                                    message: "Thêm phim mới",
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.save,
                                      ),
                                      onPressed: () {
                                        addNewFilmVM.saveOnTap(context);
                                      },
                                    ),
                                  );
                                }
                              ),
                              Tooltip(
                                message: "Thêm thể loại",
                                child: IconButton(onPressed: (){
                                  showDialog(context: context, builder:(context) => AddTypeDialog());
                                }, icon: Icon(Icons.type_specimen)),
                              )
                            ],
                          ),
                          (!isSmallScreen) ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Consumer<AddNewFilmViewModel>(
                                      builder: (context, addNewFilmVM, child) {
                                        return (addNewFilmVM.selectedImage != null)
                                          ? SizedBox(width: widthImage, height: heightImage, child: Image.memory(addNewFilmVM.selectedImage!.bytes!))
                                          : Container(width: widthImage, height: heightImage, color: Colors.grey);
                                      }
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          onPressed: (){
                                            addNewFilmVM.pickImage();
                                          },
                                          icon: Icon(
                                            Icons.upload,
                                            color: Colors.black.withValues(alpha: 0.8),
                                            size: 100,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Consumer<AddNewFilmViewModel>(
                                      builder: (context, addNewFilmVM, child){
                                        return (addNewFilmVM.selectedImageState == false)
                                          ? Positioned(bottom: 0, left: 0, right: 0, child: Align(alignment:Alignment.center, child: Text("Vui lòng chọn hình ảnh", style: contentStyle.copyWith(color: Colors.red))))
                                          : SizedBox.shrink();
                                      },
                                    )
                                  ]
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Form(
                                    key: addNewFilmVM.formKey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        buildTextFormField("Tên phim", addNewFilmVM.nameController),
                                        buildTextFormField("Mô tả", addNewFilmVM.descriptionController),
                                        buildTextFormField("Diễn viên", addNewFilmVM.actorsController),
                                        buildTextFormField("Đạo diễn", addNewFilmVM.directorController),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildDropdownButton(
                                                "Thể loại",
                                                addNewFilmVM.typeSelectController,
                                                addNewFilmVM.typeItems,
                                                "Thể loại",
                                                addNewFilmVM.maxTypeSelected
                                              ),
                                            ),
                                            Expanded(
                                              child: buildDropdownButton(
                                                  "Độ tuổi",
                                                  addNewFilmVM.ageSelectController,
                                                  addNewFilmVM.ageItems,
                                                  "Tuổi",
                                                  addNewFilmVM.maxAgeSelected
                                              ),
                                            ),
                                            Expanded(
                                              child: buildDropdownButton(
                                                  "Năm phát hành",
                                                  addNewFilmVM.yearSelectController,
                                                  addNewFilmVM.yearItems,
                                                  "Năm",
                                                  addNewFilmVM.maxYearSelected
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ) :Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                      children: [
                                        Consumer<AddNewFilmViewModel>(
                                            builder: (context, addNewFilmVM, child) {
                                              return (addNewFilmVM.selectedImage != null)
                                                  ? SizedBox(width: widthImage, height: heightImage, child: Image.memory(addNewFilmVM.selectedImage!.bytes!))
                                                  : Container(width: widthImage, height: heightImage, color: Colors.grey);
                                            }
                                        ),
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: IconButton(
                                              onPressed: (){
                                                addNewFilmVM.pickImage();
                                              },
                                              icon: Icon(
                                                Icons.upload,
                                                color: Colors.black.withValues(alpha: 0.8),
                                                size: 100,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Consumer<AddNewFilmViewModel>(
                                          builder: (context, addNewFilmVM, child){
                                            return (addNewFilmVM.selectedImageState == false)
                                                ? Positioned(bottom: 0, left: 0, right: 0, child: Align(alignment:Alignment.center, child: Text("Vui lòng chọn hình ảnh", style: contentStyle.copyWith(color: Colors.red))))
                                                : SizedBox.shrink();
                                          },
                                        )
                                      ]
                                  ),
                                  SizedBox(width: 20),
                                  Form(
                                    key: addNewFilmVM.formKey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        buildTextFormField("Tên phim", addNewFilmVM.nameController),
                                        buildTextFormField("Mô tả", addNewFilmVM.descriptionController),
                                        buildTextFormField("Diễn viên", addNewFilmVM.actorsController),
                                        buildTextFormField("Đạo diễn", addNewFilmVM.directorController),
                                        buildDropdownButton(
                                            "Thể loại",
                                            addNewFilmVM.typeSelectController,
                                            addNewFilmVM.typeItems,
                                            "Thể loại",
                                            addNewFilmVM.maxTypeSelected
                                        ),
                                        buildDropdownButton(
                                            "Độ tuổi",
                                            addNewFilmVM.ageSelectController,
                                            addNewFilmVM.ageItems,
                                            "Tuổi",
                                            addNewFilmVM.maxAgeSelected
                                        ),
                                        buildDropdownButton(
                                            "Năm phát hành",
                                            addNewFilmVM.yearSelectController,
                                            addNewFilmVM.yearItems,
                                            "Năm",
                                            addNewFilmVM.maxYearSelected
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          ) ,
                        ],
                      ),
                    );
                  }
                );
            }
          );
        }
        }
      ),
    );
  }
  Widget buildTextFormField(String label, TextEditingController controller){
    return Consumer<AddNewFilmViewModel>(
      builder: (context, detailedFilmVM, child) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: TextFormField(
            controller: controller,
            enabled: !detailedFilmVM.isSaving,
            maxLines: null,
            style: contentStyle,
            decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 10)
                ),
                labelStyle: labelStyle,
            ),
            validator: (value){
              if (value == null || value.trim().isEmpty){
                return 'Vui lòng nhập $label';
              }
              return null;
            },
          ),
        );
      }
    );
  }
  Widget buildDropdownButton<T extends Object>(String label, MultiSelectController<T> controller, List<DropdownItem<T>> items, String header, int maxSelection) {
    return Consumer<AddNewFilmViewModel>(
      builder: (context, addNewFilmVM , child) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: MultiDropdown<T>(
            controller: controller,
            items: items,
            enabled: !addNewFilmVM.isSaving,
            chipDecoration: ChipDecoration(
              backgroundColor: Colors.black54,
              wrap: true,
            ),
            dropdownDecoration: DropdownDecoration(
              backgroundColor: Colors.black,
              marginTop: 2,
              maxHeight: 500,
              header: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  header,
                  textAlign: TextAlign.start,
                  style: contentStyle,
                ),
              ),
            ),
            fieldDecoration: FieldDecoration(
              padding: EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
              labelText: label,
              labelStyle: labelStyle,
              showClearIcon: false,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            dropdownItemDecoration: DropdownItemDecoration(
              backgroundColor: Colors.black,
              selectedBackgroundColor: Colors.black,
              selectedIcon: const Icon(Icons.check_box, color: Colors.green),
              disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
            ),
            maxSelections: maxSelection,
            onSelectionChange: (value){},
            validator: (value){
              if (value == null || value.isEmpty){
                return "Vui lòng chọn $label";
              }
              return null;
            },
          )
        );
      }
    );
  }
}

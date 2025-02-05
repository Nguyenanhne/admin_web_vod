import 'package:admin/viewmodel/detailed_film_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';

class DetailedFilmPage extends StatefulWidget {
  const DetailedFilmPage({super.key});

  @override
  State<DetailedFilmPage> createState() => _DetailedFilmPageState();
}

class _DetailedFilmPageState extends State<DetailedFilmPage> {

  late Future<void> initFilm;
  @override
  void initState() {
    super.initState();
    final detailedFilmVM  = Provider.of<DetailedFilmViewModel>(context, listen: false);
    initFilm = detailedFilmVM.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
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
  @override
  Widget build(BuildContext context) {
    final detailedFilmVM  = Provider.of<DetailedFilmViewModel>(context, listen: false);

    return FutureBuilder(
      future: initFilm,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child:  CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Lỗi: ${snapshot.error}', style: contentStyle);
        }else if(detailedFilmVM.film == null){
          return Scaffold(body: Center(child: Text("Lỗi khi tải phim", style: contentStyle)));
        }else{
          return Scaffold(
            body: Consumer<DetailedFilmViewModel>(
                builder: (context,detailedFilmVM, child ) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        (detailedFilmVM.isSaving) ? LinearProgressIndicator() : SizedBox.shrink(),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Consumer<DetailedFilmViewModel>(
                                builder: (context, detailedFilmVM, child) {
                                  return Text(
                                    "CHI TIẾT PHIM: ${detailedFilmVM.film!.upperName}",
                                    style: titleStyle,
                                  );
                                }
                              ),
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                            Consumer<DetailedFilmViewModel>(
                              builder: (context, detailedFilmVM, child) {
                                return IconButton(
                                  icon: Icon(
                                      detailedFilmVM.isEdited ? Icons.save : Icons.edit
                                  ),
                                  onPressed: () {
                                    detailedFilmVM.editOnTap(context);
                                  },
                                );
                              }
                            ),
                            (detailedFilmVM.isEdited)
                            ? IconButton(
                              onPressed: (){
                                detailedFilmVM.cancelEditOnTap();
                              },
                              icon: Icon(Icons.cancel)
                            ): SizedBox.shrink(),
                            (!detailedFilmVM.isSaving)
                            ? IconButton(onPressed: (){
                              detailedFilmVM.deleteOnTap(context);
                            }, icon: Icon(Icons.delete)): SizedBox.shrink()
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      width: widthImage,
                                      height: heightImage,
                                      child: Consumer<DetailedFilmViewModel>(
                                        builder: (context, detailedFilmVM, child) {
                                          return (detailedFilmVM.selectedImage != null)
                                            ? Image.memory(detailedFilmVM.selectedImage!.bytes!)
                                            : Image.network(detailedFilmVM.film!.url, fit: BoxFit.fill);
                                        }
                                      )
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: detailedFilmVM.isEdited ? IconButton(
                                          onPressed: (){
                                            detailedFilmVM.pickImage();
                                          },
                                          icon: Icon(
                                            Icons.upload,
                                            color: Colors.black.withValues(alpha: 0.8),
                                            size: 100,
                                          ),
                                        ) : SizedBox.shrink(),
                                      ),
                                    )
                                  ]
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Form(
                                    key: detailedFilmVM.formKey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        buildTextFormField("Tên phim", detailedFilmVM.nameController),
                                        buildTextFormField("Mô tả", detailedFilmVM.descriptionController),
                                        buildTextFormField("Diễn viên", detailedFilmVM.actorsController),
                                        buildTextFormField("Đạo diễn", detailedFilmVM.directorController),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildDropdownButton(
                                                "Thể loại",
                                                detailedFilmVM.typeSelectController,
                                                detailedFilmVM.typeItems,
                                                "Thể loại",
                                                detailedFilmVM.maxTypeSelected
                                              ),
                                            ),
                                            Expanded(
                                              child: buildDropdownButton(
                                                "Độ tuổi",
                                                detailedFilmVM.ageSelectController,
                                                detailedFilmVM.ageItems,
                                                "Tuổi",
                                                detailedFilmVM.maxAgeSelected
                                              ),
                                            ),
                                            Expanded(
                                              child: buildDropdownButton(
                                                "Năm phát hành",
                                                detailedFilmVM.yearSelectController,
                                                detailedFilmVM.yearItems,
                                                "Năm",
                                                detailedFilmVM.maxYearSelected
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
                        ),
                        TextButton(onPressed: (){
                          detailedFilmVM.ping();
                        }, child: Text("Ping to server"))
                      ],
                    ),
                  );
                }
            ),
          );
        }
      }
    );
  }
  Widget buildTextFormField(String label, TextEditingController controller){
    return Consumer<DetailedFilmViewModel>(
      builder: (context, detailedFilmVM, child) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: TextFormField(
            controller: controller,
            enabled: detailedFilmVM.isEdited,
            maxLines: null,
            style: contentStyle,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 10)
              ),
              labelStyle: labelStyle,
              floatingLabelBehavior: FloatingLabelBehavior.always
            ),
            validator: (value){
              if (value == null || value.isEmpty){
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
    return Consumer<DetailedFilmViewModel>(
      builder: (context, detailedFilmVM , child) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: MultiDropdown<T>(
            controller: controller,
            enabled: detailedFilmVM.isEdited,
            items: items,
            chipDecoration: ChipDecoration(
              labelStyle: detailedFilmVM.isEdited ? contentStyle : contentStyle.copyWith(color: Colors.black),
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

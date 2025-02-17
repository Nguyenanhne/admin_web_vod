import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../service/auth_service.dart';
import '../service/type_service.dart';

class AddTypeViewModel extends ChangeNotifier{
  final TypeService _typeService = TypeService();
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  final dialogTitleStyle = TextStyle(
      fontSize: 16,
      fontFamily: GoogleFonts.roboto().fontFamily,
      fontWeight: FontWeight.bold
  );
  final dialogContentStyle = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.roboto().fontFamily,
  );
  Future<void> saveOnTap(BuildContext context) async{
    if(formKey.currentState!.validate()){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final verifyToken = await Auth().sendTokenToServer();
      if(!verifyToken){
        if(context.mounted){
          context.pop();
        }
        if (!context.mounted) return;
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Lỗi xác thực", style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Token không hợp lệ!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: () {context.pop(); },
                  child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
        return;
      }
      bool isAddType = false;
      isAddType = await addType();
      if(context.mounted){
        context.pop();
      }
      if(isAddType){
        reset();
        notifyListeners();
        if (!context.mounted) return;
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Thành công", style: dialogTitleStyle.copyWith(color: Colors.green),),
            content: Text("Thêm thể loại thành công!", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: (){
                context.pop();
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }else{
        if (!context.mounted) return;
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Thất bại", style: dialogTitleStyle.copyWith(color: Colors.red),),
            content: Text("Thêm thể loại thất bại, vui lòng thử lại sau", style: dialogContentStyle,),
            actions: [
              TextButton(onPressed: (){
                context.pop();
              }, child: Text("Xác nhận", style: dialogContentStyle))
            ],
          );
        });
      }
    }
    return;
  }

  Future<bool> addType() async{
    return await _typeService.addType(nameController.text);
  }
  void reset(){
    nameController.clear();
  }
}
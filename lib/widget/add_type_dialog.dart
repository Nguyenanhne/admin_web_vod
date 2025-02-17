import 'package:admin/view/add_type_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
class AddTypeDialog extends StatefulWidget {
  const AddTypeDialog({super.key});

  @override
  State<AddTypeDialog> createState() => _AddTypeDialogState();
}

class _AddTypeDialogState extends State<AddTypeDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddTypeViewModel>(
      builder: (context, typeVM, child) {
        return AlertDialog(
          title: const Text("Thêm thể loại"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: typeVM.formKey,
                child: TextFormField(
                  controller: typeVM.nameController,
                  decoration: const InputDecoration(
                    labelText: "Thể loại",
                    border: OutlineInputBorder()
                  ),
                  validator: (value){
                    if (value == null || value.trim().isEmpty){
                      return "Vui lòng nhập tên thể loại";
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                typeVM.saveOnTap(context);
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/inven_provider.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({
    super.key,
    required this.id,
    required this.title,
    required this.count,
    required this.date
    });

  final String id;
  final String title;
  final String count;
  final String date;

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {

  String? validateInput(String input) {
    if (input.isEmpty) {
      return 'Please enter an amount';
    }
    int? intValue = int.tryParse(input);
    if (intValue == null || intValue <= 0) {
      return 'Please enter a non-negative whole number';
    }
    return null;
  }

  final TextEditingController _titleController=TextEditingController();
  final TextEditingController _countController = TextEditingController();

  @override
  void initState() {
    _titleController.text=widget.title;
    _countController.text=widget.count;
    super.initState();
  }

  @override
  void dispose(){
    _titleController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final invenProvider = Provider.of<InvenProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'title',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  String? validationMessage = validateInput(_countController.text);
                  if (validationMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(validationMessage)),
                    );
                    return;
                  }
                  await invenProvider.updateTitle(
                    widget.id,
                    _titleController.text,
                  );
                  await invenProvider.updateCount(
                      widget.id,
                      _countController.text
                  );

                  Navigator.of(context).pop();
                },
                child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

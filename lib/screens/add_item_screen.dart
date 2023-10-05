import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../provider/inven_provider.dart';


class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {

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

  TextEditingController _titleController=TextEditingController();
  TextEditingController _countController = TextEditingController();
  TextEditingController _dateController=TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
        _dateController.text = formattedDate;
      });
    }
  }

  @override
  void dispose(){
    _titleController.dispose();
    _countController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invenProvider = Provider.of<InvenProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to the Freezer'),
      ),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Amount',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                hintText: 'Date',
                suffixIcon: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Icon(Icons.calendar_today),
                ),
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
              invenProvider.insertData(
                _titleController.text,
                _countController.text,
                _dateController.text
              );
              _titleController.clear();
              _countController.clear();
              _dateController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add')
          )
        ],
      ),
    );
  }
}

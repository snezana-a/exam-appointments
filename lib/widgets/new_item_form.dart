import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:intl/intl.dart';
import '../model/list_item.dart';

class NewItemForm extends StatefulWidget {
  final Function addItemFunction;

  const NewItemForm(this.addItemFunction, {super.key});

  @override
  State<StatefulWidget> createState() => _NewItemFormState();
}

class _NewItemFormState extends State<NewItemForm> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _submitData() {
    if (_nameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    final String examName = _nameController.text;
    final DateTime examDate = _selectedDate!;
    final TimeOfDay examTime = _selectedTime!;

    final Item item =
        Item(id: nanoid(4), name: examName, date: examDate, time: examTime);

    widget.addItemFunction(item);
    Navigator.of(context).pop();
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    setState(() {
      _selectedDate = date;
    });
  }

  void _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _selectedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Exam name"),
            onSubmitted: (_) => _submitData,
          ),
          TextField(
              readOnly: true,
              decoration: const InputDecoration(labelText: "Exam Date"),
              onTap: _selectDate,
              controller: TextEditingController(
                text: _selectedDate != null
                    ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                    : '',
              )),
          TextField(
            readOnly: true,
            decoration: const InputDecoration(labelText: "Exam Time"),
            onTap: _selectTime,
            controller: TextEditingController(
                text: _selectedTime != null
                    ? '${_selectedTime!.hour}:${_selectedTime!.minute}'
                    : ''),
          ),
          Container(
            padding: const EdgeInsets.only(top: 30),
            child: ElevatedButton(
              onPressed: _submitData,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

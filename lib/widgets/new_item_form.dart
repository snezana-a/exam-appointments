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
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  void _submitData() {
    if (_nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      return;
    }

    final String examName = _nameController.text;
    final String examDate = _dateController.text;
    final String examTime = _timeController.text;

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
    String formattedDate = DateFormat("dd/MM/yyyy").format(date);
    _dateController.text = formattedDate.toString();
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    String hour = time.hour.toString();
    String minute = time.minute.toString();
    _timeController.text = "$hour:$minute";
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
            controller: _dateController,
            readOnly: true,
            decoration: const InputDecoration(labelText: "Exam Date"),
            onSubmitted: (_) => _submitData,
            onTap: _selectDate,
          ),
          TextField(
            controller: _timeController,
            readOnly: true,
            decoration: const InputDecoration(labelText: "Exam Time"),
            onSubmitted: (_) => _submitData,
            onTap: _selectTime,
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

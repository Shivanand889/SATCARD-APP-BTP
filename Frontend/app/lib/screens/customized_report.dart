import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedFarm;
  String? _selectedDataType;
  String? _selectedFileType;

  final List<String> farms = ["Farm A", "Farm B", "Farm C"];
  final List<String> dataTypes = ["Weather Data", "Activity Data"];
  final List<String> fileTypes = ["PDF", "CSV"];

  List<Map<String, String>> _filteredData = [];

  /// Function to pick a date
  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFrom) {
          _fromDate = pickedDate;
        } else {
          _toDate = pickedDate;
        }
      });
    }
  }

 

  /// Function to submit the report
  void _submitReport() {
    if (_filteredData.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report generated as $_selectedFileType"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please preview the report before submitting"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generate Report")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selection
              Row(
                children: [
                  Expanded(
                    child: _buildDateField("From Date", _fromDate, () => _pickDate(context, true)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildDateField("To Date", _toDate, () => _pickDate(context, false)),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Farm Dropdown
              _buildDropdownField("Select Farm", farms, _selectedFarm, (value) {
                setState(() => _selectedFarm = value);
              }),

              SizedBox(height: 16),

              // Data Type Dropdown
              _buildDropdownField("Select Data Type", dataTypes, _selectedDataType, (value) {
                setState(() => _selectedDataType = value);
              }),

              SizedBox(height: 16),

              // File Type Dropdown
              _buildDropdownField("Select File Type", fileTypes, _selectedFileType, (value) {
                setState(() => _selectedFileType = value);
              }),



              
              // Submit Button
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReport,
                child: Text("Submit Report"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget for date selection fields
  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          validator: (value) => date == null ? "Select a date" : null,
          controller: TextEditingController(
            text: date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
          ),
        ),
      ),
    );
  }

  /// Widget for dropdown fields
  Widget _buildDropdownField(
      String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(label),
      decoration: InputDecoration(border: OutlineInputBorder()),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Select an option" : null,
    );
  }
}

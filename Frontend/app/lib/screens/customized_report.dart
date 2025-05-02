import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:app/utils/global_state.dart';

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

  List<String> farms = [];
  final List<String> dataTypes = ["Weather Data", "Activity Data"];

  List<Map<String, dynamic>> _weatherData = [];
  List<Map<String, dynamic>> _activityData = [];

  @override
  void initState() {
    super.initState();
    _fetchFarms();
  }

  Future<void> _fetchFarms() async {
    final uri = Uri.parse("http://127.0.0.1:8000/farmList?email=${GlobalState().email}");
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          farms = List<String>.from(data["farms"]);
        });
      } else {
        print('Failed to load farms: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching farms: $e');
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://127.0.0.1:8000/customizedReports");

    final body = json.encode({
      "fromDate": _fromDate!.toIso8601String().split('T')[0],
      "toDate": _toDate!.toIso8601String().split('T')[0],
      "farm": _selectedFarm,
      "dataType": _selectedDataType,
      "email": GlobalState().email,
    });

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData["data"];

        if (_selectedDataType == "Weather Data") {
          setState(() {
            _weatherData = List<Map<String, dynamic>>.from(dataList);
          });
          await _generateWeatherPdf();
        } else if (_selectedDataType == "Activity Data") {
          setState(() {
            _activityData = List<Map<String, dynamic>>.from(dataList);
          });
          await _generateActivityPdf();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Report generated as PDF")),
        );
      } else {
        print("Failed to generate report: ${response.statusCode}");
      }
    } catch (e) {
      print("Error submitting report: $e");
    }
  }

  Future<void> _generateWeatherPdf() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Weather Data Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ["Date", "Rain", "Wind", "Temperature", "Precipitation", "Humidity"],
            data: _weatherData.map((e) {
              return [
                dateFormat.format(DateTime.parse(e["date"])),
                "${e['rain']} mm",
                "${e['wind']} km/h",
                "${e['temperature']} °C",
                "${e['precipitation']}%",
                "${e['humidity']}%"
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> _generateActivityPdf() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Activity Data Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ["Name", "Activity", "Farm", "Date Assigned", "Status"],
            data: _activityData.map((e) {
              return [
                e["name"] ?? '',
                e["activity"] ?? '',
                e["farm"] ?? '',
                dateFormat.format(DateTime.parse(e["date assigned"])),
                e["status"] ?? '',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generate Report")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              farms.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : _buildDropdownField("Select Farm", farms, _selectedFarm, (value) {
                      setState(() => _selectedFarm = value);
                    }),
              SizedBox(height: 16),
              _buildDropdownField("Select Data Type", dataTypes, _selectedDataType, (value) {
                setState(() => _selectedDataType = value);
              }),
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
}

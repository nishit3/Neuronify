import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:neuronify/screens/hidden_layers.dart';
import 'package:http/http.dart' as http;
import 'package:neuronify/screens/inference.dart';

class UploadCSV extends StatefulWidget {

  const UploadCSV({super.key,});

  @override
  State<UploadCSV> createState() {
    return _UploadCSVState();
  }
}

class _UploadCSVState extends State<UploadCSV> {

  var _csvFileName = 'No CSV File Selected';
  List<List<dynamic>> _csvData = [];
  bool _isLoading = false;


  _UploadCSVState();

  Future<List<List<dynamic>>> readCsvFile(String filePath) async {
    List<List<dynamic>> csvTable = [];
    try {
      File file = File(filePath);
      List<String> lines = await file.readAsLines();

      csvTable = lines.map((line) {
        List<dynamic> row = line.split(',');
        return row;
      }).toList();
    } catch (e) {}
    return csvTable;
  }

  Future<void> selectAndSaveCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        setState(() {
          _csvFileName = result.files.first.name ?? 'No File Selected';
        });
        _csvData = await readCsvFile(result.files.first.path!);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HiddenLayers(csvData: _csvData),));
      } else {}
    } catch (e) {}
  }

  void _checkForModel() async
  {
    const String userID = "abcdefgijh";
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
      Uri.parse('https://1b92-2401-4900-53d8-cc40-f55f-5bc1-6467-f57b.ngrok-free.app/getInferenceMetaData?userID=$userID'),
    );
    if(response.statusCode == 200)
      {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Inference(),));
      }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _checkForModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text("Upload CSV"),
      ),
      body: Center(
        child: _isLoading?
            const CircularProgressIndicator(color: Colors.blue,)
            :
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_csvFileName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            OutlinedButton(
              onPressed: selectAndSaveCSV,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: const Text("Upload CSV"),
            ),
          ],
        ),
      ),
    );
  }
}

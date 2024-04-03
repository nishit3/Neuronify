import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neuronify/screens/upload_csv.dart';

class Inference extends StatefulWidget
{
  const Inference({super.key,});

  @override
  State<Inference> createState() {
    return _InferenceState();
  }
}

class _InferenceState extends State<Inference>
{

  final String userID = "abcdefgijh";
  List columns = [];
  List inferenceInput = [];
  String _predictonColumnName = '';
  String _prediction = '';
  _InferenceState();
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  void _getInference() async
  {
    if(_formKey.currentState!.validate())
      {
        _formKey.currentState!.save();
        setState(() {
          _isLoading = true;
        });
        final reqBody = json.encode(
            {
              "input": inferenceInput
            }
        );
        final response = await http.post(
            Uri.parse('https://1b92-2401-4900-53d8-cc40-f55f-5bc1-6467-f57b.ngrok-free.app/getInference?userID=$userID'),
            headers: {
              "Content-Type": "application/json"
            },
            body: reqBody
        );
        final responseBody = json.decode(response.body);
        _prediction = (responseBody["inference"]).toString();
        inferenceInput = [];
        setState(() {
          _isLoading = false;
        });
      }
  }

  void _getColumns() async{
    final response = await http.get(
      Uri.parse('https://1b92-2401-4900-53d8-cc40-f55f-5bc1-6467-f57b.ngrok-free.app/getInferenceMetaData?userID=$userID'),
    );
    final responseBody = json.decode(response.body);
    columns = responseBody["columns"];
    _predictonColumnName = columns[columns.length-1];
    columns.remove(columns[columns.length-1]);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _getColumns();
    super.initState();
  }

  void _reset() async{
    setState(() {
      _isLoading = true;
    });
    await http.get(
      Uri.parse('https://1b92-2401-4900-53d8-cc40-f55f-5bc1-6467-f57b.ngrok-free.app/deleteModelData?userID=$userID'),
    );
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const UploadCSV(),));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            child: const Text("Train Another", style: TextStyle(color: Colors.white)),
          )
        ],
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text("Take Inferences"),
      ),
      body: _isLoading?
          const Center(child: CircularProgressIndicator(color: Colors.blue,))
          :
      Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...columns.map((e) => TextFormField(
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    hintText: e
                  ),
                  validator: (value) {
                    if(value == '')
                      {
                        return "Input is required";
                      }
                    return null;
                  },
                  onSaved: (newValue) {
                    inferenceInput.insert(columns.indexOf(e), double.parse(newValue!));
                  },
                )),
                const SizedBox(height: 20,),
                Text("$_predictonColumnName:  $_prediction", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 40,),
                OutlinedButton(
                  onPressed: _getInference,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                  child: const Text("Predict"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

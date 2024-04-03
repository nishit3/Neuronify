import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:neuronify/screens/inference.dart';

class TrainingScreen extends StatefulWidget {
  final csvData;
  final Map<String, Map<String, int>> hiddenLayerData;
  final int optimizer;
  const TrainingScreen(
      {super.key,
      required this.csvData,
      required this.hiddenLayerData,
      required this.optimizer});

  @override
  State<StatefulWidget> createState() {
    return _TrainingScreenState(
        hiddenLayerData: hiddenLayerData,
        csvData: csvData,
        optimizer: optimizer);
  }
}

class _TrainingScreenState extends State<TrainingScreen> {
  final csvData;
  final Map<String, Map<String, int>> hiddenLayerData;
  final int optimizer;
  _TrainingScreenState(
      {required this.optimizer,
      required this.hiddenLayerData,
      required this.csvData});

  final _formKey = GlobalKey<FormState>();
  double meanDifference = 10.15;
  bool _isLoading = false;
  double trainSize = 0.8;
  int batchSize = 8;
  double learningRate = 0.1;
  int epochs = 500;
  String userID = "abcdefgijh";

  void _train() async {
    if(_formKey.currentState!.validate())
      {
        _formKey.currentState!.save();
        setState(() {
          _isLoading = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Training In Progress"),
          duration: Duration(seconds: 3),
        ));
        final reqBody = json.encode({
          "userID": userID,
          "hiddenLayersData": hiddenLayerData,
          "csv_data": csvData,
          "n_epochs": epochs,
          "train_size": trainSize,
          "batch_size": batchSize,
          "learning_rate": learningRate,
          "optimizer_id": optimizer,
        });
        final response = await http.post(
            Uri.parse(
                'https://1b92-2401-4900-53d8-cc40-f55f-5bc1-6467-f57b.ngrok-free.app/trainModel'),
            headers: {"Content-Type": "application/json"},
            body: reqBody);
        final responseBody = json.decode(response.body);
        meanDifference = responseBody["MeanDifference"];

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Inference(),
        ));

        setState(() {
          _isLoading = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          title: const Text("Its Train Time!"),
        ),
        body: Center(
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.blue,
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              initialValue: trainSize.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                helperText: "Train Ratio",
                                hintTextDirection: TextDirection.ltr,
                              ),
                              validator: (value) {
                                if (value == '') {
                                  return "Input is required";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                trainSize = double.parse(newValue!);
                              },
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            TextFormField(
                              initialValue: learningRate.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                helperText: "Learning Rate",
                              ),
                              validator: (value) {
                                if (value == '') {
                                  return "Input is required";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                learningRate = double.parse(newValue!);
                              },
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            TextFormField(
                              initialValue: batchSize.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                helperText: "Batch Size",
                              ),
                              validator: (value) {
                                if (value == '') {
                                  return "Input is required";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                batchSize = int.parse(newValue!);
                              },
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            TextFormField(
                              initialValue: epochs.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                helperText: "Epochs",
                              ),
                              validator: (value) {
                                if (value == '') {
                                  return "Input is required";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                epochs = int.parse(newValue!);
                              },
                            ),
                            const SizedBox(height: 100),
                            OutlinedButton(
                              onPressed: _train,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent,
                              ),
                              child: const Text("Train",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )));
  }
}

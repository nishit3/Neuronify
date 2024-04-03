import 'package:flutter/material.dart';
import 'package:neuronify/screens/training.dart';

class Optimizer extends StatefulWidget
{
  final csvData;
  final Map<String, Map<String, int>> hiddenLayerData;

  const Optimizer({super.key, required this.csvData, required this.hiddenLayerData});

  @override
  State<StatefulWidget> createState() {
    return _OptimizerState(csvData: csvData, hiddenLayerData: hiddenLayerData);
  }
}

class _OptimizerState extends State<Optimizer>
{
  final csvData;
  final Map<String, Map<String, int>> hiddenLayerData;

  _OptimizerState({required this.hiddenLayerData, required this.csvData});

  int optimizer = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Optimizer"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 50,),
            RadioListTile(
              value: 1,
              title: const Text("Adam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              groupValue: optimizer,
              onChanged: (value) {
                setState(() {
                  optimizer = value!;
                });
              },
            ),
            RadioListTile(
              value: 2,
              title: const Text("SGD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              groupValue: optimizer,
              onChanged: (value) {
                setState(() {
                  optimizer = value!;
                });
              },
            ),
            RadioListTile(
              value: 3,
              title: const Text("RMSprop", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              groupValue: optimizer,
              onChanged: (value) {
                setState(() {
                  optimizer = value!;
                });
              },
            ),
            RadioListTile(
              value: 4,
              title: const Text("Adagrad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              groupValue: optimizer,
              onChanged: (value) {
                setState(() {
                  optimizer = value!;
                });
              },
            ),
            const SizedBox(height: 30),
            OutlinedButton(
              onPressed: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => TrainingScreen(csvData: csvData, hiddenLayerData: hiddenLayerData, optimizer: optimizer),));
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: const Text("Next", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

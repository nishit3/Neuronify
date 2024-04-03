import 'package:flutter/material.dart';
import 'package:neuronify/screens/optimizer.dart';

class Nodes extends StatefulWidget
{
  final csvData;
  final totalHL;

  const Nodes({super.key, required this.csvData, required this.totalHL});

  @override
  State<StatefulWidget> createState() {
    return _NodesState(csvData: csvData, totalHL: totalHL);
  }
}

class _NodesState extends State<Nodes>
{
  var csvData;
  var totalHL = 0;
  int nodes = 1;
  Map<String, Map<String, int>> hiddenLayerData = {};
  var currentHiddenLayer = 1;
  int activationFunction = 1;
  final _formKey = GlobalKey<FormState>();
  _NodesState({required this.csvData, required this.totalHL});


  @override
  void initState() {
    super.initState();
  }

  void _handleNextHL() {
    if(_formKey.currentState!.validate())
      {
        _formKey.currentState!.save();
        hiddenLayerData.addAll({currentHiddenLayer.toString(): {"nodes": nodes, "activationFunc": activationFunction}});
        setState(() {
          currentHiddenLayer++;
        });
        if(currentHiddenLayer == totalHL + 1)
        {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Optimizer(csvData: csvData, hiddenLayerData: hiddenLayerData),));
        }
      }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Hidden Layer $currentHiddenLayer"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("How many Neurons in this hidden layer?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 2,),
                  TextFormField(
                    initialValue: "1",
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      nodes = int.parse(value!);
                    },
                    validator: (value) {
                      if(value == '')
                        {
                          return "Input is required";
                        }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
                  RadioListTile(
                    value: 1,
                    title: const Text("ReLU"),
                    groupValue: activationFunction,
                    onChanged: (value) {
                      setState(() {
                        activationFunction = value!;
                      });
                    },
                  ),
                  RadioListTile(
                      value: 2,
                      title: const Text("Leaky ReLU"),
                      groupValue: activationFunction,
                      onChanged: (value) {
                        setState(() {
                          activationFunction = value!;
                        });
                      },
                  ),
                  RadioListTile(
                    value: 3,
                    title: const Text("Tanh"),
                    groupValue: activationFunction,
                    onChanged: (value) {
                      setState(() {
                        activationFunction = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    value: 4,
                    title: const Text("None"),
                    groupValue: activationFunction,
                    onChanged: (value) {
                      setState(() {
                        activationFunction = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton(
                    onPressed: _handleNextHL,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    child: const Text("Next Hidden Layer"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

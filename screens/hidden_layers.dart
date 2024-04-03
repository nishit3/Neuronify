import 'package:flutter/material.dart';
import 'package:neuronify/screens/nodes.dart';

class HiddenLayers extends StatefulWidget
{
  final csvData;

  const HiddenLayers({super.key, required this.csvData});
  @override
  State<HiddenLayers> createState() {
    return _HiddenLayersState(csvData: csvData,);
  }
}

class _HiddenLayersState extends State<HiddenLayers>
{
  var csvData;
  var _totalHL = 1;
  final _formKey = GlobalKey<FormState>();
  _HiddenLayersState({required this.csvData,});

  void _next()
  {
    if(_formKey.currentState!.validate())
      {
        _formKey.currentState!.save();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Nodes(csvData: csvData, totalHL: _totalHL),));
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text("Hidden Layers"),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("How many hidden layers you want?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 30,),
                TextFormField(
                  initialValue: _totalHL.toString(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value == '')
                      {
                        return "Input is required";
                      }
                    return null;
                  },
                  onSaved: (value) {
                    _totalHL = int.parse(value!);
                  },
                ),
                const SizedBox(height: 50,),
                OutlinedButton(
                  onPressed: _next,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

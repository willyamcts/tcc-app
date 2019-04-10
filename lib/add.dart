import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPage extends StatefulWidget {
  AddPage({Key key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  final _formKey = GlobalKey<FormState>();

  final eventNameInput = TextEditingController();
  final startPlaceInput = TextEditingController();
  final numberInput = TextEditingController();

  void _save() {
    if(!_formKey.currentState.validate()) {
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Wrong!')));
    } else {
      Firestore.instance
          .collection('travels')
          .document()
          .setData({
            'eventName': eventNameInput.text,
            'startPlace': startPlaceInput.text,
            'number': numberInput.text,
            'created_at': DateTime.now().millisecondsSinceEpoch
          })
          .then((_) => Navigator.pop(context))
          .catchError((error) => print(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar"),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            
            TextFormField(
              controller: eventNameInput,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nome do evento'
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Insira o nome do evento';
                }
              },
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 25.0),
            ),

            TextFormField(
              controller: startPlaceInput,
              decoration: InputDecoration(
                labelText: 'Local de Saída'
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Insira o local de saída';
                }
              },
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 25.0),
            ),

            TextFormField(
              controller: numberInput,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Whatsapp para contato'
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Insira um número para contato';
                }
              },
            ),

          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: Icon(Icons.check),
      ),
    );
  }
}
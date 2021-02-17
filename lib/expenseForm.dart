import 'dart:math';

import 'package:dividi_spese/persistance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'expense.dart';

class ExpenseForm extends StatefulWidget {
  final List<String> favourites;

  ExpenseForm({Key key, @required this.favourites}) : super(key: key);

  @override
  _ExpenseFormState createState() => _ExpenseFormState(favourites: favourites);
}

class _ExpenseFormState extends State<ExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final _persistance = Persistance();
  Expense expense = new Expense();
  String nameCurrentText = "";
  List<String> favourites;

  _ExpenseFormState({@required this.favourites});

  _textListener() {
    setState(() {
      nameCurrentText = _typeAheadController.text;
    });
  }

  _handleFavourite() {
    setState(() {
      if (favourites.contains(nameCurrentText))
        favourites.remove(nameCurrentText);
      else
        favourites.add(nameCurrentText);
      print(favourites.toString());
    });
    _persistance.setFavourites(favourites);
  }

  @override
  void initState() {
    super.initState();

    _typeAheadController.addListener(_textListener);
  }

  List<String> _getSuggestions(String pattern) {
    List<String> match = favourites
        .where((e) => e.toLowerCase().startsWith(pattern.toLowerCase()))
        .toList();
    return match;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle _ts = TextStyle(fontSize: 18.0);
    final TextStyle _is = TextStyle(fontSize: 24.0);

    return Scaffold(
        appBar: AppBar(title: Text('Nuova spesa'), actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Builder(
              builder: (context) => RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      'Aggiungi',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    )
                  ],
                ),
                onPressed: () {
                  if (this._formKey.currentState.validate()) {
                    this._formKey.currentState.save();
                    print(expense.user + expense.cost.toString() + expense.description);
                    Navigator.pop(context, expense);
                  }
                },
              ),
            ),
          )
        ]),
        body: Form(
          key: this._formKey,
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
              padding: EdgeInsets.all(14.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                              controller: this._typeAheadController,
                              style: _is,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(25),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Persona',
                                labelStyle: _ts,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10))),
                              )),
                          hideOnEmpty: true,
                          suggestionsCallback: (pattern) {
                            return _getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this._typeAheadController.text = suggestion;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Inserisci un nome';
                            }
                            return null;
                          },
                          onSaved: (value) => expense.user = value,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                style: BorderStyle.solid, color: Colors.grey),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: IconButton(
                            icon: (favourites.contains(nameCurrentText))
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border),
                            color: Colors.red,
                            onPressed: (nameCurrentText == "")
                                ? null
                                : _handleFavourite,
                          ),
                        ),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Spesa",
                      labelStyle: _ts,
                      suffixText: "€",
                      hintText: "0,00",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    style: _is,
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]+((\.|\,)[0-9]{0,2})?')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                        if(value == "")
                          return "Campo obbligatorio";
                        double cost = double.tryParse(value.replaceAll(',', '.'));
                        if(cost == null)
                          return "Valore non valido";
                        return null;
                    },
                    onSaved: (cost) => expense.cost = double.parse(cost.replaceAll(',', '.')),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Descrizione (opzionale)",
                      labelStyle: _ts,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    style: _is,
                    maxLength: 40,
                    onSaved: (desc) => expense.description = desc,
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                ],
              )),
        ));
  }
}

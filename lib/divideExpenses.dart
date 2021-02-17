import 'dart:math';
import 'dart:ui';

import 'package:dividi_spese/exchange.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'expense.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DivideExpensesPage extends StatefulWidget {
  final List<Expense> expenses;

  DivideExpensesPage({Key key, @required this.expenses}) : super(key: key);

  @override
  _DivideExpensesPageState createState() => _DivideExpensesPageState(
        expenses: expenses,
      );
}

class _DivideExpensesPageState extends State<DivideExpensesPage> {
  final List<Expense> expenses;
  List<Exchange> exchanges;
  double _total;
  double _average;

  _DivideExpensesPageState({@required this.expenses});

  @override
  void initState() {
    super.initState();

    exchanges = _divideExpenses(expenses);
  }

  String _formatMoney(double e) {
    FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
        amount: e,
        settings: MoneyFormatterSettings(
          symbol: "€",
          decimalSeparator: ",",
          thousandSeparator: ".",
          fractionDigits: 2,
        ));
    return fmf.output.symbolOnRight;
  }

  Widget exchangeToString(Exchange e) {
    var value = _formatMoney(e.value);
    var text = RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        style: TextStyle(
            fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.normal),
        children: <TextSpan>[
          TextSpan(
              text: e.userFrom, style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' deve '),
          TextSpan(
              text: value,
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          TextSpan(text: ' a '),
          TextSpan(
              text: e.userTo, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      textAlign: TextAlign.center,
    );

    return text;
  }

  _emptyExcScreen() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 150.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image(image: AssetImage("assets/party_popper.png"))),
            ),
            Text(
              "Tutte le spese sono già divise!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black54,
                  ),
                  children: [
                    TextSpan(
                      text: "Ogni persona ha speso ",
                    ),
                    TextSpan(
                        text: _formatMoney(_average),
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: "\n Per un totale di ",
                    ),
                    TextSpan(
                        text: _formatMoney(_total),
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Dividi spese"),
        ),
        body: (exchanges.isEmpty)
            ? _emptyExcScreen()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Wrap(children: [
                      Text("Spesa totale: ", style: TextStyle(fontSize: 18)),
                      Text(_formatMoney(_total),
                          style: TextStyle(
                            fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Wrap(children: [
                      Text("Spesa a persona: ", style: TextStyle(fontSize: 18)),
                      Text(_formatMoney(_average),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child:
                      Text("Possibile soluzione: ", style: TextStyle(fontSize: 16)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exchanges.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1.0),
                              borderRadius: BorderRadius.all(Radius.circular(
                                      10.0) //                 <--- border radius here
                                  ),
                            ),
                            child: ListTile(
                              title: Container(
                                  child: exchangeToString(exchanges[index])),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ));
  }

  List<Exchange> _divideExpenses(List<Expense> expenses) {
    List<Exchange> exchanges = new List<Exchange>();

    Map<String, double> expensesDict = {};
    double total = 0;
    for (Expense e in expenses) {
      if (expensesDict.containsKey(e.user))
        expensesDict[e.user] += e.cost;
      else
        expensesDict[e.user] = e.cost;
      total += e.cost;
    }

    double average = total / expensesDict.length;

    //save values for display
    _total = total;
    _average = average;

    if (expenses.length < 2) return exchanges;

    Map<String, double> diffs =
        expensesDict.map((key, value) => MapEntry(key, value - average));

    while (diffs.values.any((element) => element != 0.0)) {
      MapEntry<String, double> minEntry = MapEntry("min", double.infinity);
      MapEntry<String, double> maxEntry =
          MapEntry("max", double.negativeInfinity);
      for (MapEntry<String, double> entry in diffs.entries) {
        if (entry.value > maxEntry.value) maxEntry = entry;
        if (entry.value < minEntry.value) minEntry = entry;
      }

      double remainder = maxEntry.value + minEntry.value;
      double exchange = min((maxEntry.value).abs(), (minEntry.value).abs());
      exchanges.add(new Exchange(
          userFrom: minEntry.key, userTo: maxEntry.key, value: exchange));

      //if the remainder is less than one cent approximate to zero
      if (remainder.abs() < 0.01) remainder = 0.0;

      //update diffs with the exchange
      diffs[maxEntry.key] = (remainder > 0) ? remainder : 0.0;
      diffs[minEntry.key] = (remainder < 0) ? remainder : 0.0;
    }

    return exchanges;
  }
}

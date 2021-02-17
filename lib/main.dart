import 'package:dividi_spese/expense.dart';
import 'package:dividi_spese/expenseForm.dart';
import 'package:dividi_spese/favourites.dart';
import 'package:dividi_spese/persistance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'divideExpenses.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dividi Spese',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        buttonColor: Color.fromARGB(255, 51, 138, 62),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExpensesPage(),
    );
  }
}

class ExpensesPage extends StatefulWidget {
  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage>
    with TickerProviderStateMixin<ExpensesPage> {
  List<Expense> _expenses = List<Expense>();
  List<String> _favourites = List<String>();
  final Persistance _persistance = Persistance();
  ScrollController _hideButtonController;
  var _hideFabAnimation;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _hideFabAnimation.reverse();
      } else {
        if (_hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
          _hideFabAnimation.forward();
        }
      }
    });
    _persistance.getExpenses().then((List<Expense> value) {
      setState(() {
        _expenses = value;
        _total = _getTotal(_expenses);
      });
    });
    _persistance.getFavourites().then((List<String> value) {
      setState(() {
        _favourites = value;
      });
    });
    _hideFabAnimation.forward();
  }

  double _getTotal(List<Expense> expenses) {
    double total = 0;
    for(Expense e in expenses)
      total += e.cost;
    return total;
  }

  _addExpense(BuildContext context) async {
    final expense = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return ExpenseForm(
        favourites: _favourites,
      );
    }));
    Scaffold.of(context).removeCurrentSnackBar();
    if (expense != null) {
      setState(() {
        _expenses.add(expense);
        _total = _getTotal(_expenses);
      });
      _persistance.setExpenses(_expenses);
      Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text('Spesa di ' + _formatCost(expense.cost) + ' aggiunta')));
    }
  }

  Widget _generateTile(expense) {
    return ListTile(
        title: Text(
          expense.user,
          style: TextStyle(fontSize: 16),
        ),
        subtitle: Text(
          expense.description,
          style: TextStyle(fontSize: 14),
        ),
        trailing: Text(
          _formatCost(expense.cost),
          style: TextStyle(color: Colors.green, fontSize: 18),
        ));
  }

  String _formatCost(double cost) {
    FlutterMoneyFormatter fmf = FlutterMoneyFormatter(
        amount: cost,
        settings: MoneyFormatterSettings(
          symbol: "€",
          decimalSeparator: ",",
          thousandSeparator: ".",
          fractionDigits: 2,
        ));
    return fmf.output.symbolOnRight;
  }

  void _handleMenuChoice(String choice) async {
    switch (choice) {
      case "preferiti":
        {
          List<String> updatedFavourites = await Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return FavouritesPage(favourites: _favourites);
          }));
          _favourites = updatedFavourites;
          _persistance.setFavourites(_favourites);
          return;
        }
      case "cancella":
        {
          AlertDialog alert = AlertDialog(
            title: Text("Cancella tutto"),
            content: Text("Sei sicuro di voler cancellare tutte le spese?"),
            actions: [
              FlatButton(
                child: Text("Annulla"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Cancella"),
                onPressed: () {
                  setState(() {
                    _expenses.clear();
                    _total = _getTotal(_expenses);
                    Navigator.of(context).pop();
                  });
                  _persistance.setExpenses(_expenses);
                },
              ),
            ],
          );

          // show the dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
        return;
    }
  }

  _emptyExpScreen() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 150.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 100,
                height: 100,
                child: Icon(
                  Icons.money_off,
                  color: Colors.green,
                  size: 100,
                )),
            Text(
              "Nessuna spesa inserita",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "Puoi cominciare aggiungendo delle spese con il tasto ",
                    ),
                    WidgetSpan(
                        child: Icon(
                      Icons.add_circle,
                      color: Colors.green,
                    )),
                    TextSpan(
                      text: " in basso a destra.",
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _headerTile() {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Dividi spese',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return DivideExpensesPage(
                      expenses: _expenses,
                    );
                  }));
              return;
            },
          ),
          Wrap(children: [
            Text(
              "Totale: ",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              _formatCost(_total),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            )
          ]),
        ],
      ),
      subtitle: Divider(thickness: 2,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Spese"),
          actions: [
            PopupMenuButton<String>(
                onSelected: _handleMenuChoice,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem(
                          child: Text("Preferiti"), value: "preferiti"),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Cancella tutto"),
                            Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        value: "cancella",
                      )
                    ])
          ],
        ),
        body: (_expenses.isEmpty)
            ? _emptyExpScreen()
            : ListView.builder(
                padding: EdgeInsets.only(bottom: 56),
                controller: _hideButtonController,
                itemCount: _expenses.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _headerTile();
                  } else {
                    index -= 1;
                    final Expense item = _expenses[index];
                    return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          setState(() {
                            _expenses.removeAt(index);
                            _total = _getTotal(_expenses);
                          });
                          _persistance.setExpenses(_expenses);
                          Scaffold.of(context).removeCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("Spesa di " +
                                  _formatCost(item.cost) +
                                  " rimossa"),
                              action: SnackBarAction(
                                  label: "ANNULLA",
                                  onPressed: () {
                                    setState(() {
                                      _expenses.insert(index, item);
                                      _total = _getTotal(_expenses);
                                    });
                                    _persistance.setExpenses(_expenses);
                                  })));
                        },
                        background: Container(
                          color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              )
                            ],
                          ),
                        ),
                        child: _generateTile(item));
                  }
                },
              ),
        floatingActionButton: Builder(
          builder: (context) => ScaleTransition(
            scale: _hideFabAnimation,
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: () {
                _addExpense(context);
              },
              tooltip: 'Aggiungi spesa',
              child: Icon(Icons.add),
            ),
          ),
        ));
  }
}

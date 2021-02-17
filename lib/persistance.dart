
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'expense.dart';

class Persistance {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _favouritesFile async {
    final path = await _localPath;
    return File('$path/favourites.json');
  }

  Future<File> get _expensesFile async {
    final path = await _localPath;
    return File('$path/expenses.json');
  }

  Future<List<String>> getFavourites() async {
    try {

      final file = await _favouritesFile;
      String contents = await file.readAsString();
      List<String> favourites=(jsonDecode(contents) as List<dynamic>).cast<String>();
      return favourites;

    } catch (e) {
      return List<String>();
    }
  }

  void setFavourites(List<String> favourites) async {
    File file = await _favouritesFile;
    var encoded = json.encode(favourites);
    file.writeAsString(encoded);
  }

  Future<List<Expense>> getExpenses() async {
    try {

      final file = await _expensesFile;
      String contents = await file.readAsString();
      List<Expense> expenses=(json.decode(contents) as List).map((i) =>
          Expense.fromJson(i)).toList();
      return expenses;

    } catch (e) {
      return List<Expense>();
    }
  }

  void setExpenses(List<Expense> expenses) async {
    File file = await _expensesFile;
    var encoded = json.encode(expenses);
    file.writeAsString(encoded);
  }
}
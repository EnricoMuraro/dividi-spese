import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatefulWidget {
  final List<String> favourites;

  FavouritesPage({Key key, @required this.favourites}) : super(key: key);

  @override
  _FavouritesPageState createState() => _FavouritesPageState(
        favourites: favourites,
      );
}

class _FavouritesPageState extends State<FavouritesPage> {
  final List<String> favourites;
  List<int> removedIndexes = new List<int>();

  _FavouritesPageState({@required this.favourites});

  _emptyFavScreen() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 150.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 100, height: 100,
                child: Image(image: AssetImage("assets/Broken_heart.png"))),
            Text(
              "Non hai nessun preferito",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RichText(
                textAlign: TextAlign.center ,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                  children: [
                    TextSpan(
                      text: "Puoi aggiungere preferiti durante l'inserimento di una nuova spesa cliccando l'icona ",
                    ),
                    WidgetSpan(child: Icon(Icons.favorite_border, color: Colors.red,)),
                    TextSpan(
                      text: " vicino al nome della persona",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Preferiti"),
        ),
        body: WillPopScope(
          onWillPop: () async {
            List<String> newFavourites = List.of(favourites);
            for (int index in removedIndexes) {
              newFavourites.remove(favourites[index]);
            }
            Navigator.pop(context, newFavourites);
            return true;
          },
          child: (favourites.isEmpty)
              ? _emptyFavScreen()
              : ListView.builder(
                  itemCount: favourites.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${favourites[index]}'),
                      trailing: IconButton(
                        icon: Icon((removedIndexes.contains(index))
                            ? Icons.favorite_border
                            : Icons.favorite),
                        color: (removedIndexes.contains(index))
                            ? null
                            : Colors.red,
                        onPressed: () {
                          setState(() {
                            if (removedIndexes.contains(index))
                              removedIndexes.remove(index);
                            else
                              removedIndexes.add(index);
                          });
                        },
                      ),
                    );
                  },
                ),
        ));
  }
}

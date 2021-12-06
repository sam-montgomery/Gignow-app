import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../constants.dart';
import 'cards_section_alignment.dart';

List<String> genreFilters = [
  "Pop",
  "Rock",
  "Metal",
  "Accoustic",
  "Folk",
  "Country",
  "Hip Hop",
  "Jazz",
  "Musical Theatre",
  "Punk Rock",
  "Heavy Metal",
  "Electronic",
  "Funk",
  "House",
  "Disco",
  "EDM",
  "Orchestra"
];
double distance = 2000000;

class SwipeFeedPage extends StatefulWidget {
  @override
  _SwipeFeedPageState createState() => _SwipeFeedPageState();
}

class _SwipeFeedPageState extends State<SwipeFeedPage> {
  FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebaseService.getArtistAccounts(genreFilters, distance),
        builder: (builder, snapshot) {
          if (snapshot.hasData) {
            List<UserModel> artists = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                centerTitle: true,
                backgroundColor: Colors.white,
                leading: IconButton(
                    onPressed: () {
                      showFiltersPopUp(context);
                    },
                    icon: Icon(Icons.settings, color: Colors.grey)),
              ),
              backgroundColor: Colors.white,
              body: Column(children: <Widget>[
                CardsSectionAlignment(artists, context),
              ]),
            );
          } else {
            return Loading();
          }
        });
  }

  Future<String> showFiltersPopUp(BuildContext context) {
    List<String> _genres = [
      "Pop",
      "Rock",
      "Metal",
      "Accoustic",
      "Folk",
      "Country",
      "Hip Hop",
      "Jazz",
      "Musical Theatre",
      "Punk Rock",
      "Heavy Metal",
      "Electronic",
      "Funk",
      "House",
      "Disco",
      "EDM",
      "Orchestra"
    ];

    List<String> selectedGenres;

    final genreSelector = MultiSelectChipField(
      items: _genres
          .map((genre) => MultiSelectItem<String>(genre, genre))
          .toList(),
      title: Text("Genres:"),
      headerColor: Colors.blue.withOpacity(0.5),
      decoration: BoxDecoration(
        border: Border.all(color: kButtonBackgroundColour, width: 1.8),
      ),
      selectedChipColor: Colors.blue.withOpacity(0.5),
      selectedTextStyle: TextStyle(color: Colors.blue[800]),
      onTap: (values) {
        selectedGenres = values;
      },
    );

    double _currentSliderValue = 40;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Filters"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //mainAxisAlignment: MainAxisSize.max,
              children: <Widget>[
                Text("Range: "),
                Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 200,
                    divisions: 10,
                    label: _currentSliderValue.round().toString() + "km",
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    }),
                genreSelector,
                MaterialButton(
                    elevation: 5.0,
                    child: Text("Ok"),
                    onPressed: () {
                      genreFilters = selectedGenres;
                      distance = _currentSliderValue * 1000;
                      firebaseService.getArtistAccounts(genreFilters, distance);
                      SwipeFeedPage();
                      Navigator.of(context).pop();
                    })
              ],
            ),
          );
        });
  }
}

// content: TextField(controller: customController),
//             actions: <Widget>[
//               MaterialButton(
//                   elevation: 5.0,
//                   child: Text("Ok"),
//                   onPressed: () {
//                     Navigator.of(context).pop(customController.text.toString());
//                   })
//             ],

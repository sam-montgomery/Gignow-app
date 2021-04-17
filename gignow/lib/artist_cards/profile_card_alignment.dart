import 'package:flutter/material.dart';

import '../model/user.dart';
import '../net/firebase_service.dart';
import '../ui/loading.dart';
import 'profile_view.dart';

class ProfileCardAlignment extends StatefulWidget {
  final int cardNum;
  bool isCard = true;
  ProfileCardAlignment(this.cardNum);
  @override
  _ProfileCardAlignementState createState() =>
      _ProfileCardAlignementState(cardNum);
}

class _ProfileCardAlignementState extends State<ProfileCardAlignment> {
  final int cardNum;
  _ProfileCardAlignementState(this.cardNum);
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebaseService.getArtistAccounts(),
        //firebaseService.getUser("08KWaAMZsuamtPY2B4GgKBqsBmp1"),
        builder: (BuildContext context, snapshot) {
          print("");
          if (snapshot.hasData) {
            List<UserModel> artists = snapshot.data;
            return Column(
              children: [
                FlatButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      if (!widget.isCard) {
                        setState(() {
                          widget.isCard = true;
                        });
                      }
                    },
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: widget.isCard
                            ? Text("")
                            : Icon(Icons.arrow_back_rounded,
                                color: Colors.grey))),
                Expanded(
                  child: Card(
                    child: !widget.isCard
                        ? ProfileView(artists[cardNum])
                        : Stack(
                            children: <Widget>[
                              SizedBox.expand(
                                child: Material(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                      artists[cardNum].profilePictureUrl,
                                      fit: BoxFit.cover),
                                ),
                              ),
                              SizedBox.expand(
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                        Colors.transparent,
                                        Colors.black54
                                      ],
                                          begin: Alignment.center,
                                          end: Alignment.bottomCenter)),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16.0, horizontal: 16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(artists[cardNum].name,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w700)),
                                        Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 8.0)),
                                        Text(artists[cardNum].genres,
                                            textAlign: TextAlign.start,
                                            style:
                                                TextStyle(color: Colors.white)),
                                        Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 8.0)),
                                        FloatingActionButton(
                                            onPressed: () {
                                              setState(() {
                                                widget.isCard = false;
                                              });
                                            },
                                            backgroundColor: Colors.grey,
                                            child: Icon(Icons.info_rounded,
                                                color: Colors.white)),
                                      ],
                                    )),
                              )
                            ],
                          ),
                  ),
                ),
              ],
            );
          } else {
            return Loading();
          }
        });
  }
}

// class ProfileCardAlignment extends StatelessWidget {
//   final int cardNum;
//   ProfileCardAlignment(this.cardNum);
//   bool _currentWidgetisCard;

//   bool get currentWidget {
//     return _currentWidgetisCard;
//   }

//   void set currentWidget(bool current) {
//     _currentWidgetisCard = current;
//   }

//   @override
//   Widget build(BuildContext context) {
//       if (_currentWidgetisCard == false) {
//         return profileView();
//       } else
//         return cardView();
//   }

//   Widget profileView() {
//     return ProfileView();
//   }

//   Widget cardView() {
//     return Card(
//       child: Stack(
//         children: <Widget>[
//           SizedBox.expand(
//             child: Material(
//               borderRadius: BorderRadius.circular(12.0),
//               child: Image.asset('res/portrait.jpeg', fit: BoxFit.cover),
//             ),
//           ),
//           SizedBox.expand(
//             child: Container(
//               decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       colors: [Colors.transparent, Colors.black54],
//                       begin: Alignment.center,
//                       end: Alignment.bottomCenter)),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomLeft,
//             child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text('Card number $cardNum',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20.0,
//                             fontWeight: FontWeight.w700)),
//                     Padding(padding: EdgeInsets.only(bottom: 8.0)),
//                     Text('A short description.',
//                         textAlign: TextAlign.start,
//                         style: TextStyle(color: Colors.white)),
//                     Padding(padding: EdgeInsets.only(bottom: 8.0)),
//                     FloatingActionButton(
//                         onPressed: () {
//                           setState() {
//                             _currentWidgetisCard = false;
//                           }
//                         },
//                         backgroundColor: Colors.grey,
//                         child: Icon(Icons.info_rounded, color: Colors.white)),
//                   ],
//                 )),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/ui/loading.dart';
import '../model/user.dart';
import '../model/user.dart';
import '../net/firebase_service.dart';
import '../net/firebase_service.dart';
import '../ui/loading.dart';
import 'profile_card_alignment.dart';
import 'dart:math';
import 'profile_card_alignment.dart';
import 'profile_card_alignment.dart';
import 'profile_view.dart';

List<Alignment> cardsAlign = [
  Alignment(0.0, 1.0),
  Alignment(0.0, 1.0),
  Alignment(0.0, 1.0)
];
List<Size> cardsSize = List(3);

class CardsSectionAlignment extends StatefulWidget {
  List<UserModel> artists;
  CardsSectionAlignment(this.artists, BuildContext context) {
    cardsSize[0] = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 2);
    cardsSize[1] = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 2);
    cardsSize[2] = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 2);
  }

  @override
  _CardsSectionState createState() => _CardsSectionState(user);
  UserModel user;
}

class _CardsSectionState extends State<CardsSectionAlignment>
    with SingleTickerProviderStateMixin {
  int cardsCounter;
  bool noArtistsLeft = false;

  UserModel user;
  _CardsSectionState(user);

  FirebaseService firebaseService = FirebaseService();
  FirebaseAuth auth = FirebaseAuth.instance;

  List<ProfileCardAlignment> cards = List();
  AnimationController _controller;

  final Alignment defaultFrontCardAlign = Alignment(0.0, 1.0);
  Alignment frontCardAlign;
  double frontCardRot = 0.0;
  int profileIndex = 0;
  List<UserModel> artists;

  @override
  void initState() {
    super.initState();
    artists = widget.artists;
    // Init cards
    // for (cardsCounter = 0; cardsCounter < 3; cardsCounter++) {
    //   cards.add(ProfileCardAlignment(profileIndex));
    //   profileIndex++;
    // }

    for (cardsCounter = 0; cardsCounter < 3; cardsCounter++) {
      if (artists.length != 0) {
        if (artists.length <= cardsCounter) {
          cards.add(ProfileCardAlignment(null));
        } else {
          cards.add(ProfileCardAlignment(artists[cardsCounter]));
        }
      } else {
        cards.add(ProfileCardAlignment(null));
      }
    }

    frontCardAlign = cardsAlign[2];

    // Init the animation controller
    _controller =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) changeCardsOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Stack(
      children: <Widget>[
        backCard(),
        middleCard(),
        frontCard(),

        // Prevent swiping if the cards are animating
        _controller.status != AnimationStatus.forward
            ? SizedBox.expand(
                child: GestureDetector(
                // While dragging the first card
                onPanUpdate: (DragUpdateDetails details) {
                  // Add what the user swiped in the last frame to the alignment of the card
                  setState(() {
                    // 20 is the "speed" at which moves the card
                    if (!noArtistsLeft) {
                      frontCardAlign = Alignment(
                          frontCardAlign.x +
                              20 *
                                  details.delta.dx /
                                  MediaQuery.of(context).size.width,
                          frontCardAlign.y +
                              40 *
                                  details.delta.dy /
                                  MediaQuery.of(context).size.height);
                      frontCardRot = frontCardAlign.x;
                    } //0 is the speed if no
                    else
                      frontCardAlign = Alignment(
                          frontCardAlign.x +
                              0 *
                                  details.delta.dx /
                                  MediaQuery.of(context).size.width,
                          frontCardAlign.y +
                              0 *
                                  details.delta.dy /
                                  MediaQuery.of(context).size.height);
                    frontCardRot = frontCardAlign.x;
                  }

                      // * rotation speed;
                      );
                },
                // When releasing the first card
                onPanEnd: (_) {
                  // If the front card was swiped far enough to count as swiped
                  if (frontCardAlign.x > 3.0) {
                    if (!noArtistsLeft) {
                      createConnection();
                      animateCards();
                    }
                  } else if (frontCardAlign.x < -3.0) {
                    if (!noArtistsLeft) animateCards();
                  } else {
                    // Return to the initial rotation and alignment
                    setState(() {
                      frontCardAlign = defaultFrontCardAlign;
                      frontCardRot = 0.0;
                    });
                  }
                },
              ))
            : Container(),
      ],
    ));
  }

  Widget backCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.backCardAlignmentAnim(_controller).value
          : cardsAlign[0],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.backCardSizeAnim(_controller).value
              : cardsSize[2],
          child: cards[2]),
    );
  }

  Widget middleCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.middleCardAlignmentAnim(_controller).value
          : cardsAlign[1],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.middleCardSizeAnim(_controller).value
              : cardsSize[1],
          child: cards[1]),
    );
  }

  Widget frontCard() {
    return Align(
        alignment: _controller.status == AnimationStatus.forward
            ? CardsAnimation.frontCardDisappearAlignmentAnim(
                    _controller, frontCardAlign)
                .value
            : frontCardAlign,
        child: Transform.rotate(
          angle: (pi / 180.0) * frontCardRot,
          child: SizedBox.fromSize(size: cardsSize[0], child: cards[0]),
        ));
  }

  Widget noArtists() {
    return Expanded(
      child: Card(
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter)),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("No more artists in search",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700)),
                      Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  void changeCardsOrder() {
    setState(() {
      // Swap cards (back card becomes the middle card; middle card becomes the front card, front card becomes a  bottom card)
      //var temp = cards[0];
      var next;
      //cardsCounter++;
      if (cardsCounter >= artists.length + 2) {
        setState(() {
          noArtistsLeft = true;
        });
      }
      if (cardsCounter >= artists.length) {
        next = ProfileCardAlignment.emptyCard();
      } else
        next = ProfileCardAlignment(artists[cardsCounter]);

      cards[0] = cards[1];
      cards[1] = cards[2];
      cards[2] = next;
      //cards[2] = ProfileCardAlignment(artists[cardsCounter]);

      frontCardAlign = defaultFrontCardAlign;
      frontCardRot = 0.0;
      cardsCounter++;
    });
  }

  void animateCards() {
    _controller.stop();
    _controller.value = 0.0;
    _controller.forward();
    //changeCardsOrder();
  }

  void createConnection() {
    firebaseService.createConnection(auth.currentUser.uid, cards[0].artist.uid);
  }
}

class CardsAnimation {
  static Animation<Alignment> backCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[0], end: cardsAlign[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Size> backCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[2], end: cardsSize[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Alignment> middleCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[1], end: cardsAlign[2]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Size> middleCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[1], end: cardsSize[0]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Alignment> frontCardDisappearAlignmentAnim(
      AnimationController parent, Alignment beginAlign) {
    return AlignmentTween(
            begin: beginAlign,
            end: Alignment(
                beginAlign.x > 0 ? beginAlign.x + 30.0 : beginAlign.x - 30.0,
                0.0) // Has swiped to the left or right?
            )
        .animate(CurvedAnimation(
            parent: parent, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));
  }
}

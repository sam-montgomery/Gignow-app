import 'package:flutter/material.dart';
import 'package:gignow/constants.dart';
import 'package:intl/intl.dart';
import 'package:gignow/model/event.dart';

final List<String> moty = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC'
];

final TextStyle activeScreen =
    TextStyle(fontSize: 18, decoration: TextDecoration.underline);

final TextStyle inActiveScreen = TextStyle(fontSize: 18);

final TextStyle monthStyle =
    TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold);
final TextStyle dateStyle =
    TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold);
final TextStyle dayStyle =
    TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold);
final TextStyle timeStyle = TextStyle(fontSize: 16, color: Colors.white);

Container generateOpenEventTile(BuildContext context, Event event) {
  String startingTime = event.eventStartTime.hour.toString() +
      ':' +
      (event.eventStartTime.minute == 0
          ? "00"
          : event.eventStartTime.minute.toString());
  String finishingTime = event.eventFinishTime.hour.toString() +
      ':' +
      (event.eventFinishTime.minute == 0
          ? "00"
          : event.eventFinishTime.minute.toString());
  return Container(
    height: MediaQuery.of(context).size.height * 0.1,
    width: MediaQuery.of(context).size.height * 0.1,
    decoration: BoxDecoration(
        color: kButtonBackgroundColour,
        borderRadius: BorderRadius.all(Radius.circular(15))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    moty[event.eventStartTime.month - 1],
                    textAlign: TextAlign.center,
                    style: monthStyle,
                  ),
                  Text(
                    event.eventStartTime.day.toString(),
                    textAlign: TextAlign.center,
                    style: dateStyle,
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEEE').format(event.eventStartTime),
                textAlign: TextAlign.center,
                style: dayStyle,
              ),
              Text(
                "$startingTime - $finishingTime",
                textAlign: TextAlign.left,
                style: timeStyle,
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.14,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                child: Text('Applicants'),
                color: Colors.lightBlue,
                onPressed: () {},
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
      ],
    ),
  );
}

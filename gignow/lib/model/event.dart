import 'package:gignow/model/user.dart';

class Event {
  String
      eventId; //Unique identifier for the event, comprising of 'VenueId - index'
  DateTime eventStartTime; //Scheduled start time of event
  DateTime eventFinishTime; //Scheduled end time of the event
  String venueId; //Venue organising event
  Map<String, dynamic> venue;
  List<String> applicants = []; //Users (artists) who have applied
  String acceptedUid; //Uid of accepted applicant
  bool confirmed = false; //Confirmation by applicant

  Event(this.eventId, this.eventStartTime, this.eventFinishTime, this.venueId, this.venue,
      [this.applicants, this.acceptedUid, this.confirmed]);
}

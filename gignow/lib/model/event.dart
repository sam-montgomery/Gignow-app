import 'package:gignow/model/user.dart';

class Event {
  String
      eventId; //Unique identifier for the event, comprising of 'VenueId - index'
  String eventName; //Title of the event
  DateTime eventStartTime; //Scheduled start time of event
  Duration eventDuration; //Duration of the event
  String eventPhotoURL; //Photo attached to the event
  String venueId; //Venue organising event
  String genres; //Genres specified by the venue to specify the type of gig
  Map<String, dynamic> venue;
  List<String> applicants = []; //Users (artists) who have applied
  String acceptedUid; //Uid of accepted applicant
  bool confirmed = false; //Confirmation by applicant

  Event(this.eventId, this.eventName, this.eventStartTime, this.eventDuration,
      this.eventPhotoURL, this.venueId, this.genres, this.venue,
      [this.applicants, this.acceptedUid, this.confirmed]);
}

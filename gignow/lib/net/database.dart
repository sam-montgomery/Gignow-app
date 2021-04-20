import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gignow/model/user.dart';

class DatabaseMethods {
  addUserInfoToDB() {
    FirebaseFirestore.instance.collection("Artists");
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String name) async {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("name", isEqualTo: name)
        .snapshots();
  }

  Future<QuerySnapshot> getUserByUserUID(String uid) async {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("userUid", isEqualTo: uid)
        .get();
  }

  addMessage(String chatRoomID, Map messageInfoMap) {
    FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("chats")
        .add(messageInfoMap);

    Map<String, dynamic> lastMessageInfoMap = {
      "lastMessage": messageInfoMap["message"],
      "lastMessageSentTimeStamp": messageInfoMap["timeStamp"],
      "lastMessageSentBy": messageInfoMap["sentBy"]
    };

    updateLastMessageSent(chatRoomID, lastMessageInfoMap);
  }

  updateLastMessageSent(String chatRoomID, Map lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomID)
        .update(lastMessageInfoMap);
  }

  getChatRoomIDByHandle(String handleA, String handleB) {
    if (handleA.substring(1, 2).codeUnitAt(0) >=
        handleB.substring(1, 2).codeUnitAt(0)) {
      return "$handleB\_$handleA";
    } else {
      return "$handleA\_$handleB";
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomID) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("chats")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms(String uid) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .orderBy("lastMessageSentTimeStamp", descending: true)
        .where("users", arrayContains: uid)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getConnections(String uid) async {
    return FirebaseFirestore.instance
        .collection("Connections")
        .where("users", arrayContains: "/Users/" + uid)
        .snapshots();
  }

  // Future<UserModel> getUserInfoByHandle(String handle) async {
  //   return await FirebaseFirestore.instance
  //       .collection("Users")
  //       .where("handle", isEqualTo: handle)
  //       .get();
  // }

  createChatRoom(String chatRoomID, Map chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomID)
        .get();

    if (snapShot.exists) {
      //chat room already exists
      return true;
    } else {
      //create chat room
      return FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomID)
          .set(chatRoomInfoMap);
    }
  }
}

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

  Future<QuerySnapshot> getUserByUserHandle(String handle) async {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("handle", isEqualTo: handle)
        .get();
  }

  Future addMessage(String chatRoomID, Map messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("chats")
        .add(messageInfoMap);
  }

  updateLastMessageSent(String chatRoomID, Map lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomID)
        .update(lastMessageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomID) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("chats")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms(String handle) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .orderBy("lastMessageSentTimeStamp", descending: true)
        .where("users", arrayContains: handle)
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

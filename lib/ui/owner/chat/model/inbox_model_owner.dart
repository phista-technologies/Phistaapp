import 'package:cloud_firestore/cloud_firestore.dart';

class InboxModelOwner {
  String? lastMessage;
  String? mediaUrl;
  String? senderId;
  String? receiverId;
  bool? seen;
  String? type;
  Timestamp? timestamp;
  bool? archive;

  InboxModelOwner({this.lastMessage, this.mediaUrl, this.senderId, this.receiverId, this.seen, this.type, this.timestamp, this.archive});

  InboxModelOwner.fromJson(Map<String, dynamic> json) {
    lastMessage = json['lastMessage'];
    mediaUrl = json['mediaUrl'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    seen = json['seen'];
    type = json['type'];
    timestamp = json['timestamp'];
    archive = json['archive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastMessage'] = lastMessage;
    data['mediaUrl'] = mediaUrl;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['seen'] = seen;
    data['type'] = type;
    data['timestamp'] = timestamp;
    data['archive'] = archive;
    return data;
  }
}

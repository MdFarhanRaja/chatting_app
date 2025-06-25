class NotificationMessage {
  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      title: json['title'],
      msg: json['msg'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      timestamp: json['timestamp'],
      token: json['token'],
      userName: json['userName'],
    );
  }
  final int? id;
  final String? userName;
  final String? msg;
  final String? senderId;
  final String? receiverId;
  final String? title;
  final String? timestamp;
  final String? token;

  NotificationMessage({
    this.id,
    this.userName,
    this.msg,
    this.senderId,
    this.receiverId,
    this.title,
    this.timestamp,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'msg': msg,
      'senderId': senderId,
      'receiverId': receiverId,
      'title': title,
      'timestamp': timestamp,
      'token': token,
    };
  }

  factory NotificationMessage.fromMap(Map<String, dynamic> map) {
    return NotificationMessage(
      id: map['id'],
      userName: map['userName'],
      msg: map['msg'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      title: map['title'],
      timestamp: map['timestamp'],
      token: map['token'],
    );
  }
}

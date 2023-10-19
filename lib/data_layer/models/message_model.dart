class MessageModel {
  String? senderId ;
  String? receiverId ;
  String? messageId ;
  dynamic dateTime;
  String? text;
  Map<String,dynamic>? emoji ;
  List<dynamic>? messageImages;
  List<dynamic>? messageImagesNamesInStorage;
  Map<String,dynamic>? reply ;
  String? record ;
  int? recordDuration ;
  bool? isPlaying ;
  bool? isSeen ;

  MessageModel({
    this.senderId,
    this.receiverId,
    this.messageId,
    this.dateTime,
    this.text,
    this.emoji,
    this.messageImages,
    this.messageImagesNamesInStorage,
    this.reply,
    this.record,
    this.recordDuration,
    this.isPlaying,
    this.isSeen,
  });

  MessageModel.fromJson(Map<String,dynamic> json){
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    messageId = json['messageId'];
    dateTime = json['dateTime'];
    text = json['text'];
    messageImages = json['messageImages'];
    messageImagesNamesInStorage = json['messageImagesNamesInStorage'];
    emoji = json['emoji'];
    reply = json['reply'];
    record = json['record'];
    recordDuration = json['recordDuration'];
    isPlaying = json['isPlaying'];
    isSeen = json['isSeen'];
  }

  Map<String,dynamic> toMap()
  {
    return
      {
      'senderId' : senderId ,
      'receiverId' : receiverId ,
      'messageId' : messageId ,
      'dateTime' : dateTime ,
        'text' : text ,
      'messageImages' : messageImages ,
      'messageImagesNamesInStorage' : messageImagesNamesInStorage ,
      'emoji' : emoji ,
      'reply' : reply ,
      'record' : record ,
      'recordDuration' : recordDuration ,
      'isPlaying' : isPlaying ,
      'isSeen' : isSeen ,

    };
  }
}
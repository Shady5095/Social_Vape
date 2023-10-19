class CommentModel {
  String? name ;
  String? uId;
  String? image;
  String? dateTime;
  String? commentImage;
  String? commentImageNameInStorage;
  String? text ;
  List<dynamic>? likes ;
  String? commentId ;
  int? noOfReplays ;

  CommentModel({
    this.name,
    this.uId,
    this.image,
    this.dateTime,
    this.commentImage,
    this.commentImageNameInStorage,
    this.text,
    this.likes,
    this.commentId,
    this.noOfReplays,
  });

  CommentModel.fromJson(Map<String,dynamic> json){
    name = json['name'];
    uId = json['uId'];
    image = json['image'];
    dateTime = json['dateTime'];
    commentImage = json['commentImage'];
    commentImageNameInStorage = json['commentImageNameInStorage'];
    text = json['text'];
    likes = json['likes'];
    commentId = json['commentId'];
    noOfReplays = json['noOfReplays'];
  }

  Map<String,dynamic> toMap()
  {
    return
      {
      'name' : name ,
      'uId' : uId ,
      'image' : image ,
        'dateTime' : dateTime ,
      'commentImages' : commentImage ,
      'commentImageNameInStorage' : commentImageNameInStorage ,
      'text' : text ,
        'commentId' : commentId,
        'noOfReplays' : noOfReplays,
    };
  }
}
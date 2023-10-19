class PostModel {
  String? name ;
  String? uId;
  String? image;
  String? dateTime;
  List<dynamic>? postImages;
  List<dynamic>? postImagesNameInStorage;
  String? text ;
  String? postId ;
  List<dynamic>? likes ;
  List<dynamic>? savedBy ;
  int? noOfComments ;

  PostModel({
    this.name,
    this.uId,
    this.image,
    this.dateTime,
    this.postImages,
    this.postImagesNameInStorage,
    this.text,
    this.postId,
    this.likes,
    this.savedBy,
    this.noOfComments,

  });

  PostModel.fromJson(Map<String,dynamic> json){
    name = json['name'];
    uId = json['uId'];
    image = json['image'];
    dateTime = json['dateTime'];
    postImages = json['postImages'];
    postImagesNameInStorage = json['postImagesNameInStorage'];
    text = json['text'];
    postId = json['postId'];
    likes = json['likes'];
    savedBy = json['savedBy'];
    noOfComments = json['noOfComments'];
  }

  Map<String,dynamic> toMap()
  {
    return
      {
      'name' : name ,
      'uId' : uId ,
      'image' : image ,
        'dateTime' : dateTime ,
      'postImages' : postImages ,
      'postImagesNameInStorage' : postImagesNameInStorage ,
      'text' : text ,
      'postId' : postId ,
        'likes' : likes,
        'savedBy' : savedBy,
        'noOfComments' : noOfComments,
    };
  }
}
class UserModel {
  String? name ;
  String? email ;
  String? phone;
  String? uId;
  String? bio;
  String? image;
  String? coverImage;
  List<dynamic>? followers;
  List<dynamic>? following;
  int? posts;

  UserModel({
    this.name,
    this.email,
    this.phone,
    this.uId,
    this.bio,
    this.image,
    this.coverImage,
    this.followers,
    this.following,
    this.posts,

  });

  UserModel.fromJson(Map<String,dynamic> json){
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    uId = json['uId'];
    bio = json['bio'];
    image = json['image'];
    coverImage = json['coverImage'];
    followers = json['followers'];
    following = json['following'];
    posts = json['posts'];

  }

  Map<String,dynamic> toMap()
  {
    return
      {
      'name' : name ,
      'email' : email ,
      'phone' : phone ,
        'uId' : uId ,
      'bio' : bio ,
      'image' : image ,
      'coverImage' : coverImage ,
      'following' : following ,
      'followers' : followers ,
      'posts' : posts ,

    };
  }
}
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_vape/business_logic_layer/social_cubit/social_states.dart';
import '../../components/constans.dart';
import '../../data_layer/models/post_model.dart';
import '../../data_layer/models/user_model.dart';
import '../../presentation_layer/screens/chat_screen/chat_screen.dart';
import '../../presentation_layer/screens/discover_screen/discover_screen.dart';
import '../../presentation_layer/screens/feeds_screen/feeds_screen.dart';
import '../../presentation_layer/screens/my_profile_screen/my_profile_screen.dart';
import '../../data_layer/local/cache_helper.dart';
import '../../styles/icon_broken.dart';

class SocialCubit extends Cubit<SocialStates> {
  SocialCubit() : super(IntStateSocial());

  static SocialCubit get(context) => BlocProvider.of(context);


  int currentIndex = 0 ;
  Map<int,int> postPhotoIndex = {
    0:1
  } ;
  Map<String,bool> postSavedOrNot = {} ;
  var indexNo =1;
  UserModel? userModel;
  var db = FirebaseFirestore.instance ;
  var storage = FirebaseStorage.instance;
  List<Widget> screens = [
    const FeedsScreen(),
     ChatsScreen(),
    const DiscoverScreen(),
    const MyProfileScreen(),
  ];

  File? profileImagePicker ;
  File? coverImagePicker ;
  var picker = ImagePicker();

  Future<void> pickProfileImage({
  bool openCamera = false ,
}) async {
    XFile? pickedFile = await picker.pickImage(
        source:openCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 100,
    );
    var croppedFile = await ImageCropper().cropImage(
        sourcePath: (pickedFile?.path)!,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      compressFormat: ImageCompressFormat.jpg,

      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.purple,
          toolbarTitle: 'Edit Image',
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: 'Edit Image',
        )
      ],
    );

    if(pickedFile != null){
      profileImagePicker = File((croppedFile?.path)!);
      emit(ProfileImagePickedSuccessState());
    }
  }

  Future<void> pickCoverImage({
    bool openCamera = false ,
  }) async {
    XFile? pickedFile = await picker.pickImage(
        source:openCamera ? ImageSource.camera : ImageSource.gallery
    );

    var croppedFile = await ImageCropper().cropImage(
      sourcePath: (pickedFile?.path)!,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      compressQuality: 80,
      compressFormat: ImageCompressFormat.jpg,

      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.purple,
          toolbarTitle: 'Edit Image',
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: 'Edit Image',
        )
      ],
    );

    if(pickedFile != null){
      coverImagePicker = File((croppedFile?.path)!);
      emit(CoverImagePickedSuccessState());
    }
  }

  List<XFile?> postImagePicker =[];
  Future<void> pickPostImage() async {
    List<XFile?> pickedFile = await picker.pickMultiImage(
      imageQuality: 70,
    );

    if(pickedFile != null){
      postImagePicker = pickedFile;
      emit(ProfileImagePickedSuccessState());
    }
  }


  void removePostPhotoFromList(int index){
    postImagePicker.removeAt(index);
    emit(RemovePostPhotoFromList());
  }

  XFile? editedPostPhoto;
  void editPostPhoto(path,int index)async {

    var croppedFile = await ImageCropper().cropImage(
      sourcePath: (path),
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      compressFormat: ImageCompressFormat.jpg,

      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.purple,
          toolbarTitle: 'Edit Image',
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: 'Edit Image',
        )
      ],
    );

    if(croppedFile != null){
       editedPostPhoto = XFile((croppedFile.path));
      emit(EditPostImagePickedSuccessState());
    }
    if(editedPostPhoto != null){
      postImagePicker[index] = editedPostPhoto;
    }
  }

  void changeBottomNav(int index) {
    currentIndex = index ;
    emit(ChangeBottomNavState());
  }

  void getProfileData({
  bool inUpdateData = false,
     BuildContext? context ,
}){
    emit(GetProfileLoadingState());

    db.collection('users').doc(myUid).get().
    then((value) {
      userModel = UserModel.fromJson((value.data())!);
      emit(GetProfileSuccessState());
      if(inUpdateData)Navigator.pop(context!);
    }).
    catchError((error){
      if (kDebugMode) {
        print(error);
      }
      emit(GetProfileErrorState());
    });
  }

  void showCustomDialog({
    required BuildContext context,
    Function()? galleryOnTap,
    Function()? cameraOnTap,
  }) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 180,
            width: 280,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(40)),
            child: SizedBox.expand(child: Material(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: galleryOnTap,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                IconBroken.Image,
                                color: Colors.green,
                               size: 50,
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: cameraOnTap,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                IconBroken.Camera,
                                color: Colors.blue,
                                size: 50,
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Camera',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  String profileImageUrl = '' ;
  String? coverImageUrl ;
  Future<void> uploadProfileImage({
    required String name,
    required String phone,
    required String bio,
    required BuildContext context,
  bool profileAndCover =false,
}) async {
    emit(ProfileImageUploadLoadingState());

    storage.ref().child('$myUid/userProfilePhoto').listAll().
    then((value)  {
      if(value.items.isNotEmpty)storage.ref().child(value.items[0].fullPath).delete(); //delete old photo

       storage. // put new photo
      ref().
      child('$myUid/userProfilePhoto/${Uri.file((profileImagePicker?.path)!).pathSegments.last}').
      putFile(profileImagePicker!)
          .then((value)  async {
        await value.ref.getDownloadURL().then((value) {
          profileImageUrl = value ;
          //if(!profileAndCover) profileImagePicker = null;
          updateFeedsUserNewProfileData(updatePhoto: true);
          emit(ProfileImageUploadSuccessState());
            if(profileAndCover) {
              uploadCoverImage(
                  name: name,
                  phone: phone,
                  bio: bio,
                  profileAndCover: true,
                context: context,
              );
            }
            else{
              updateUserData(name: name, phone: phone, bio: bio,profile: profileImageUrl,context: context);
              //Navigator.pop(context);
            }

        }).catchError((error){
          emit(ProfileImageUploadErrorState());
        });
      })
          .catchError((error){
        if (kDebugMode) {
          print(error);
        }
        emit(ProfileImageUploadErrorState());
      });
    });

  }

  void uploadCoverImage({
    required String name,
    required String phone,
    required String bio,
  bool profileAndCover = false,
    required BuildContext context
}) async {
    emit(CoverImageUploadLoadingState());

    storage.ref().child('$myUid/userCoverPhoto').listAll(). //list items to delete
    then((value){
      if(value.items.isNotEmpty)storage.ref().child(value.items[0].fullPath).delete(); //delete old photo from database
      storage. // put new photo to database
      ref().
      child('$myUid/userCoverPhoto/${Uri.file((coverImagePicker?.path)!).pathSegments.last}').
      putFile(coverImagePicker!)
          .then((value) async {
        await value.ref.getDownloadURL().then((value) {
          coverImageUrl = value ;
          //if(!profileAndCover) coverImagePicker = null;
          //Navigator.pop(context);
          if(profileAndCover) {
            updateUserData(
              name: name,
              phone: phone,
              bio: bio,
              cover: coverImageUrl,
              profile: profileImageUrl,
              context: context
            );
          }
          else
          {
            updateUserData(name: name, phone: phone, bio: bio, cover: coverImageUrl,context: context);

          }

          emit(CoverImageUploadSuccessState());
        }).catchError((error){
          emit(CoverImageUploadErrorState());
        });
      })
          .catchError((error){
        if (kDebugMode) {
          print(error);
        }
        emit(CoverImageUploadErrorState());
      });
    });

  }

  void updateUserData ({
  required String name,
  required String phone,
  required String bio,
   String? profile,
   String? cover,
    required BuildContext context,
}) async {
    emit(UpdateProfileLoadingState());
     FirebaseFirestore
        .instance
        .collection('users')
        .doc(myUid!)
        .update({
       'name' : name,
       'email' : userModel?.email,
       'phone' : phone,
       'uId' : myUid,
       'bio' : bio,
       'image' : profile??userModel?.image,
       'coverImage' : cover??userModel?.coverImage,
     })
    .then((value) {
       getProfileData(context: context, inUpdateData: true);
       updateFeedsUserNewProfileData(userName: name);
    }).catchError((error){
      emit(UpdateProfileErrorState());
    });
    }

    void profileAndCover({
      required String name,
      required String phone,
      required String bio,
      bool profileAndCover = true ,
      required BuildContext context
    }){
    uploadProfileImage(
      name: name,
      phone: phone,
      bio: bio,
      profileAndCover: profileAndCover,
      context: context
    );

    }


  /// CreatePost CreatePost
  /// CreatePost CreatePost
  /// CreatePost CreatePost
List<String> postImagesUrl =[] ;
List<dynamic> postImagesNameInStorage =[] ;
  void createPost({
    required String dateTime,
    String? text,
  }) async {
    emit(CreatePostLoadingState());
    PostModel model ;
    if(postImagePicker.isNotEmpty){
       for (int index = 0 ; index < postImagePicker.length; index++){
         await storage. // put new photo to database
        ref().
        child('$myUid/userPostImages/${Uri.file((postImagePicker[index]?.path)!).pathSegments.last}').
        putFile(File((postImagePicker[index]?.path)!)).then((value) async {
           postImagesNameInStorage.add(value.ref.name);
          await value.ref.getDownloadURL().then((value)
          {
            postImagesUrl.add(value);
          });
        });
      }
         model = PostModel(
         name: userModel?.name,
         image: userModel?.image,
         uId: userModel?.uId,
         text: text,
         dateTime: DateTime.now().toString(),
         postImages: postImagesUrl,
           postImagesNameInStorage: postImagesNameInStorage,
           likes: [],
           savedBy: [],
           noOfComments: 0
       );

       db
           .collection('posts')
           .add(model.toMap())
           .then((value) {
             postImagePicker = [];
             postImagesUrl = [];
             postImagesNameInStorage = [];
             emit(CreatePostSuccessState());
             db
                 .collection('posts')
                 .doc(value.id)
                 .update({
               'postId': value.id
             });
             db.collection('users').doc(myUid).update({
               'posts' : FieldValue.increment(1)
             });
       })
           .catchError((error){
             emit(CreatePostErrorState());
       });
    }
    else {
      model = PostModel(
        text: text,
        dateTime: DateTime.now().toString(),
        image: userModel?.image,
        name: userModel?.name,
        postImages: [],
        uId: userModel?.uId,
          postImagesNameInStorage : [],
        likes: [],
        savedBy: [],
        noOfComments: 0,
      );
      await db
          .collection('posts')
          .add(model.toMap())
          .then((value) {
        emit(CreatePostSuccessState());
        db
            .collection('posts')
            .doc(value.id)
            .update({
          'postId': value.id
        });
        db.collection('users').doc(myUid).update({
          'posts' : FieldValue.increment(1)
        });
       })
          .catchError((error){
        emit(CreatePostErrorState());
      });
    }
  }

  /// handle when user change profile photo or name it take effect on his old posts and comments and likes
  void updateFeedsUserNewProfileData({
  bool updatePhoto = false,
    String? userName ,
}){
    FirebaseFirestore
        .instance
        .collection('posts')
        .get().then((value) {
      for (var postsDoc in value.docs) {
        if(postsDoc.data()['uId']== myUid){
          FirebaseFirestore
              .instance
              .collection('posts')
              .doc(postsDoc.id)
              .update({
            if(updatePhoto)"image" : profileImageUrl,
            "name" : userName?? userModel?.name,
          });
        } ///posts
        db.collection('posts').doc(postsDoc.id).collection('comments').get().then((value) {
          for (var commentDoc in value.docs) {
            if(commentDoc.data()['uId']== myUid){
              FirebaseFirestore
                  .instance
                  .collection('posts')
                  .doc(postsDoc.id)
                  .collection('comments')
                  .doc(commentDoc.id)
                  .update({
                if(updatePhoto)"image" : profileImageUrl,
                "name" : userName?? userModel?.name,
              });
            }
            db
                .collection('posts')
                .doc(postsDoc.id)
                .collection('comments')
                .doc(commentDoc.id)
                .collection('replays')
                .get().then((value) {
              for (var replayDoc in value.docs){
                if(replayDoc.data()['uId']== myUid){
                  FirebaseFirestore
                      .instance
                      .collection('posts')
                      .doc(postsDoc.id)
                      .collection('comments')
                      .doc(commentDoc.id)
                      .collection('replays')
                      .doc(replayDoc.id)
                      .update({
                    if(updatePhoto)"image" : profileImageUrl,
                    "name" : userName?? userModel?.name,
                  });
                }
              }
            });
          }
        }); ///comments and replays
        db.collection('posts').doc(postsDoc.id).collection('likes').get().then((value) {
          for (var likeDoc in value.docs) {
            if(likeDoc.data()['uId']== myUid){
              FirebaseFirestore
                  .instance
                  .collection('posts')
                  .doc(postsDoc.id)
                  .collection('likes')
                  .doc(likeDoc.id)
                  .update({
                if(updatePhoto)"image" : profileImageUrl,
                "name" : userName?? userModel?.name,
              });
            }
          }
        }); ///likes
      }


      emit(UpdateFeedsUserNewProfilePhotoSuccess());
    }).catchError((error){
      emit(UpdateFeedsUserNewProfilePhotoError());
      if (kDebugMode) {
        print(error);
      }
    });

  }

  /// handle photo indicator
  void changePostPhotoIndex( postNo, index) {
    postPhotoIndex = {
      postNo : index + 1
    };

    emit(ChangePostPhotoIndexState());
  }
  int postsLength = 0 ;
  void clearPostIndex(){
    for(var i=0 ; i < postsLength ; i++){
      CacheHelper.removeData(key: '$i');
    }
    emit(ClearPostIndexState());
  }

  /// DeletePost DeletePost
  /// DeletePost DeletePost
  /// DeletePost DeletePost
  Future<void> deletePost({
    required String postId,
    required BuildContext context,
    required List<dynamic> postImagesNameInStorage,
      }) async {
    db
        .collection('posts')
        .doc(postId)
        .delete().then((value) async {
          await deletePhotoFromStorage(postImagesNameInStorage: postImagesNameInStorage);
          emit(DeletePostSuccessState());
          db.collection('users').doc(myUid).update({
            'posts' : FieldValue.increment(-1)
          });
    }).catchError((error){
      emit(DeletePostErrorState());
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  Future<void> deletePhotoFromStorage({
    required List<dynamic> postImagesNameInStorage,
})async{
for (int index = 0 ; index < postImagesNameInStorage.length; index++){
await storage
    .ref()
    .child('$myUid/userPostImages/${postImagesNameInStorage[index]}')
    .delete();
}
}

  /// SavePost SavePost
  /// SavePost SavePost
  /// SavePost SavePost
  void savePost(String postId,List<dynamic> savedBy)async{
    if(savedBy.contains(myUid)){
      db
          .collection('posts')
          .doc(postId)
          .update({
        'savedBy' : FieldValue.arrayRemove([myUid])
      })
          .then((value) {
        emit(DeleteSavedPostSuccessState());
      }).catchError((error){
        emit(DeleteSavedPostErrorState());
      });
    }
    else {
      db
          .collection('posts')
          .doc(postId)
          .update({
        'savedBy' : FieldValue.arrayUnion([myUid])
      })
          .then((value) {
        emit(SavePostSuccessState());
      }).catchError((error){
        emit(SavePostErrorState());
      });
    }
  }



  /// EditPost EditPost
  /// EditPost EditPost
  /// EditPost EditPost
  Future<void> editPost({
    required String? postId,
    required String? text,
    required List<dynamic>? postImages ,
    required List<dynamic>? postImagesNameInStorage ,
    required BuildContext context,
  })
  async {
    db
        .collection('posts')
        .doc(postId)
        .update({
      'text' : text,
      'postImages' : postImages,
      'postImagesNameInStorage' : postImagesNameInStorage,
    })
        .then((value) {
          emit(EditPostSuccessState());
          Navigator.pop(context);
    })
        .catchError((error){
          emit(EditPostErrorState());
    });

  }


  Future<dynamic> getAllUserUid() async {
    List<dynamic> allUserUid = [];
    await db.collection('users').get().then((value) {
      for (var docSnapshot in value.docs) {
        allUserUid.add(docSnapshot.id);
      }
    },
    );
    return allUserUid;
  }

  void likePost({
    required String? postId,
    required String? uId,
    required List likes,
  })async{
    if(likes.contains(uId)){
       db
          .collection('posts')
          .doc(postId)
          .update({
        'likes' : FieldValue.arrayRemove([uId])
      })
          .then((value) {
            emit(UnLikePostSuccessState());
      }).catchError((error){
        emit(LikePostErrorState());
      });
       db.collection('posts').doc(postId).collection('likes').doc(uId).delete();
    }
    else {
      db
          .collection('posts')
          .doc(postId)
          .update({
        'likes' : FieldValue.arrayUnion([uId])
      })
          .then((value) {
       emit(LikePostSuccessState());
      }).catchError((error){
       emit(LikePostErrorState());
      });
      db.collection('posts').doc(postId).collection('likes').doc(uId).set({
        'name':userModel?.name,
        'image':userModel?.image,
        'uId':uId,
        'time' : DateTime.now()
      });
    }

  }

  bool isLikeAnimating = false ;

  void likeAnimation(bool isAnimate){
    isLikeAnimating = isAnimate ;
    emit(LikePostSuccessState());
  }

  Future<UserModel?> getUserDataWithUid(String uId) async {
    UserModel? model ;
      await db.collection('users').doc(uId).get().then((value) {
      model = UserModel.fromJson((value.data())!);
    });

    return model ;
  }

  String commentImageUrl = '';
  String? commentImageNameInStorage ;
  String replayCommentImageUrl = '';
  String? replayCommentImageNameInStorage ;
  Future<void> commentPost({
    required String postId,
    required String text,
    required String dateTime,
    bool isReplay = false ,
    String? commentId,
  }) async{
    if(!isReplay)
    {
      if(commentImagePicker != null){
        emit(CreatePostLoadingState());
        await storage. // put new photo to database
        ref().
        child('$myUid/userCommentsImages/${Uri.file((commentImagePicker?.path)!).pathSegments.last}').
        putFile(File((commentImagePicker?.path)!)).then((value) async {
          commentImageNameInStorage = value.ref.name;
          await value.ref.getDownloadURL().then((value)
          {
            commentImageUrl = value ;
          });
        });
      }
      await db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'name' : userModel?.name,
        'image' : userModel?.image,
        'uId' : userModel?.uId,
        'text' : text ,
        'likes' : [],
        'dateTime' : dateTime ,
        'commentImageNameInStorage': commentImageNameInStorage??'',
        'commentImage' : commentImagePicker == null ? null : commentImageUrl ,
      })
          .then((value) async {
        commentImagePicker = null ;
        commentImageNameInStorage = null;
        emit(CommentPostSuccessState());
        await db
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(value.id).update({
          'commentId' : value.id,
        });
        db.collection('posts').doc(postId).update({
          'noOfComments' : FieldValue.increment(1),
        });
      })
          .catchError((error){
        if (kDebugMode) {
          print(error);
        }
      });
    }
    else
      {
        if(replayCommentImagePicker != null){
          emit(CreatePostLoadingState());
          await storage. // put new photo to database
          ref().
          child('$myUid/userCommentsImages/${Uri.file((replayCommentImagePicker?.path)!).pathSegments.last}').
          putFile(File((replayCommentImagePicker?.path)!)).then((value) async {
            replayCommentImageNameInStorage = value.ref.name;
            await value.ref.getDownloadURL().then((value)
            {
              replayCommentImageUrl = value ;
            });
          });
        }
        await db
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replays')
            .add({
          'name' : userModel?.name,
          'image' : userModel?.image,
          'uId' : userModel?.uId,
          'text' : text ,
          'likes' : [],
          'dateTime' : dateTime ,
          'commentImageNameInStorage': replayCommentImageNameInStorage??'',
          'commentImage' : replayCommentImagePicker == null ? null : replayCommentImageUrl ,
        })
            .then((value) async {
          replayCommentImagePicker = null ;
          replayCommentImageNameInStorage = null;
          db
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .update({
            'noOfReplays' : FieldValue.increment(1),
          });
          emit(CommentPostSuccessState());
          await db
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .collection('replays')
              .doc(value.id).update({
            'commentId' : value.id
          });
        })
            .catchError((error){
          if (kDebugMode) {
            print(error);
          }
        });
      }
  }

  
  void likeComment({
  required String postId,
  required String commentId,
  required List likes,
    bool replayComment = false ,
    String? replayId ,
}){
    if(!replayComment){
      if(likes.contains(myUid)){
      db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'likes' : FieldValue.arrayRemove([myUid]),
      });
    }
    else{
      db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'likes' : FieldValue.arrayUnion([myUid]),
      });
    }
    }
    else
    {
      if(likes.contains(myUid)){
        db
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replays')
            .doc(replayId)
            .update({
          'likes' : FieldValue.arrayRemove([myUid]),
        }).then((value) {
          emit(LikeReplayCommentState());
        });
      }
      else{
        db
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replays')
            .doc(replayId)
            .update({
          'likes' : FieldValue.arrayUnion([myUid]),
        }).then((value) {
          emit(LikeReplayCommentState());
        });
      }

    }
  }

  void deleteComment({
    required String postId,
    required String commentId,
    String? commentImageNameInStorage,
    bool isReplay = false ,
    String? replayId,
  }){
    if(!isReplay)
    {
      if(commentImageNameInStorage != '' && commentImageNameInStorage != null){
        storage
            .ref()
            .child('$myUid/userCommentsImages/$commentImageNameInStorage')
            .delete();
      }

      db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete().then((value) {
        db.collection('posts').doc(postId).update({
          'noOfComments' : FieldValue.increment(-1)
        });
      });
    }
    else
    {
      {
        if(commentImageNameInStorage != '' && commentImageNameInStorage != null){
          storage
              .ref()
              .child('$myUid/userCommentsImages/$commentImageNameInStorage')
              .delete();
        }

        db
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replays')
            .doc(replayId)
            .delete()
            .then((value) {
          db
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .update({
            'noOfReplays' : FieldValue.increment(-1),
          });
        });
      }
    }
    }

  void editComment({
    required String postId,
    required String commentId,
    required String text,
    bool isReplay = false ,
    String? replayId ,
  }){
    if(!isReplay){
      db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'text' : text,
      });
    }
    else{
      db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replays')
          .doc(replayId)
          .update({
        'text' : text,
      });
    }
  }

  File? commentImagePicker ;
  File? replayCommentImagePicker ;
  Future<void> pickCommentImage({
  bool isReplay = false,
}) async {
    XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if(pickedFile != null && !isReplay){
      commentImagePicker = File(pickedFile.path);
      emit(ProfileImagePickedSuccessState());
    }
    if(pickedFile != null && isReplay){
      replayCommentImagePicker = File(pickedFile.path);
      emit(ProfileImagePickedSuccessState());
    }
  }

  void removeCommentImage({
  bool isReplay = false ,
}) {
    if(!isReplay){
      commentImagePicker = null ;
    }
    if(isReplay){
      replayCommentImagePicker = null ;
    }
    emit(RemovePostPhotoFromList());
  }

  void followUser({
  required String userId ,
  required String userImage ,
  required String userName ,
  required List userFollowersList ,
})
  {
    if(userFollowersList.contains(myUid)){
      db.collection('users').doc(userId).update({
        'followers' : FieldValue.arrayRemove([myUid])
      }).then((value) {
        emit(UnFollowUserState());
      });
      db.collection('users').doc(userId).collection('followers').doc(myUid).delete();
      db.collection('users').doc(myUid).update({
        'following' : FieldValue.arrayRemove([userId])
      });
      db.collection('users').doc(myUid).collection('following').doc(userId).delete();
    }
    else
      {
        db.collection('users').doc(userId).update({
          'followers' : FieldValue.arrayUnion([myUid])
        }).then((value) {
          emit(FollowUserState());
        });
        db.collection('users').doc(myUid).update({
          'following' : FieldValue.arrayUnion([userId])
        });
        db.collection('users').doc(myUid).collection('following').doc(userId).set({
          'uId' : userId,
          'image' : userImage,
          'name' : userName,
        });
        db.collection('users').doc(userId).collection('followers').doc(myUid).set({
          'uId' : myUid,
          'image' : userModel?.image,
          'name' : userModel?.name,
        });
      }
  }


  Future<UserModel?> userModelFromUid({
  required String uId,
}) async {
    UserModel? userModel ;
    await db.collection('users').doc(uId).get().then((value) {
      userModel = UserModel.fromJson((value.data())!);
    });
    return userModel ;
  }


  String? chatUserUid ; ///current chat user uid

  void userOnlineStatus(bool isOnline){
    try {
      db.collection('users').doc(myUid).update(
          {
            'online' : isOnline
          }
      );
    }
    on FirebaseException catch (e) {
      if(e.message == 'Some requested document was not found.'){
        db.collection('users').doc(myUid).set(
            {
              'online' : isOnline
            }
        );
      }
    }
  }
  void userLastSeen(){
    try {
      db.collection('users').doc(myUid).update(
          {
            'lastSeen' : FieldValue.serverTimestamp()
          }
      );
    }
    on FirebaseException catch (e) {
      if(e.message == 'Some requested document was not found.'){
        db.collection('users').doc(myUid).set(
            {
              'lastSeen' : FieldValue.serverTimestamp()
            }
        );
      }
    }
  }

  bool? typing ;
  Future<void> chatTyping({
    String? value,
    required String receiverId,
    bool isMessageSent= false ,
  }) async {
    if(!isMessageSent) typing = value != ''  ;
    try {
      await db.collection('users').doc(myUid).collection('chats').doc(receiverId).update(
          {
            'typing' : isMessageSent ? false : typing
          }
      );
    }
    on FirebaseException catch (e) {
      if(e.message == 'Some requested document was not found.'){
        await db.collection('users').doc(myUid).collection('chats').doc(receiverId).set(
            {
              'typing' : isMessageSent ? false : typing
            }
        );
      }
    }
  }
  bool? isDark ;
  void darkModeLightMode({
    bool? fromShared ,
    bool? isDarkMode,
  }){
    if(fromShared != null){
      isDark = fromShared ;
      emit(ChangeAppMode());
    }
    else if(isDarkMode != null) {
      isDark = isDarkMode ;
      CacheHelper.putBool(key: 'isDark', value: isDarkMode).then((value) {
        emit(ChangeAppMode());
      });
    }
    else
      {
        isDark = null ;
        CacheHelper.removeData(key: 'isDark',)?.then((value) {
          emit(ChangeAppMode());
        });
      }
  }
}


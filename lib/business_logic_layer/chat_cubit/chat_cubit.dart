import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/components.dart';
import '../../components/constans.dart';
import '../../data_layer/models/message_model.dart';
import '../../data_layer/models/user_model.dart';
import '../../data_layer/network/dio_helper.dart';
import '../../presentation_layer/screens/chat_screen/background_opecity_screen.dart';
import 'chat_states.dart';

 class ChatCubit extends Cubit<ChatStates>  {
  ChatCubit() : super(ChatIntState());

  static ChatCubit get(context) => BlocProvider.of(context);


  var db = FirebaseFirestore.instance ;
  var storage = FirebaseStorage.instance;
  var picker = ImagePicker();
  UserModel? userModel ;

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

  List<dynamic>? messageImagesNameInStorage ;
  List<String>? messageImagesUrl = [] ;
  Future<void> sendMessage({
    required String receiverId ,
    required String? dateTime ,
    String? text ,
    required UserModel? receiverUserModel ,
  })
  async {
    ///make typing false after send message
    chatTyping(
        receiverId: receiverId,
        isMessageSent: true
    );
    if((messageImagesPicker.isNotEmpty) || messageImagePickerCamera != null)
    {
      if ((messageImagesPicker.isNotEmpty) &&
          messageImagesPicker.length < 4) {
        emit(SendImageMessageLoadingState());
        for (int index = 0; index < (messageImagesPicker.length); index++) {
          await storage
              . // put new photo to database
          ref()
              .child(
              '$myUid/userMessageImages/${Uri.file((messageImagesPicker[index].path)).pathSegments.last}')
              .putFile(File((messageImagesPicker[index].path)))
              .then((value) async {
            messageImagesNameInStorage?.add(value.ref.name);
            await value.ref.getDownloadURL().then((value) {
              messageImagesUrl?.add(value);
            });
          });

          await db
              .collection('users')
              .doc(myUid)
              .collection('chats')
              .doc(receiverId)
              .collection('messages')
              .add({
            'senderId' : myUid,
            'receiverId' : receiverId,
            'text' : text ?? '',
            'dateTime' : FieldValue.serverTimestamp(),
            'messageImages' :  messageImagesUrl ?? [],
            'messageImagesNamesInStorage' : messageImagesNameInStorage ?? [],
            'isSeen' : false
          })
              .then((messageId) {
            emit(SendImageMessageSuccessState());
            db
                .collection('users')
                .doc(myUid)
                .collection('chats')
                .doc(receiverId)
                .collection('messages')
                .doc(messageId.id)
                .update({
              'messageId': messageId.id,
              if(replyMessage != null )'reply.${'text'}' : replyMessage!.text,
              if(replyMessage != null )'reply.${'images'}' : replyMessage!.messageImages,
              if(replyMessage != null )'reply.${'messageId'}' : replyMessage!.messageId,
              if(replyMessage != null )'reply.${'senderId'}' : replyMessage!.senderId,
            });

            db
                .collection('users')
                .doc(receiverId)
                .collection('chats')
                .doc(myUid)
                .collection('messages')
                .doc(messageId.id)
                .set({
              'senderId' : myUid,
              'receiverId' : receiverId,
              'text' : text ?? '',
              'dateTime' : FieldValue.serverTimestamp(),
              'messageImages' :  messageImagesUrl ?? [],
              'messageImagesNamesInStorage' : messageImagesNameInStorage ?? [],
              'isSeen' : false
            })
                .then((message) {
              DioHelper.postNotification(
                  data: {
                    'to' : '/topics/$receiverId',
                    'notification' : {
                      "title": "${userModel!.name}",
                      "body": text == '' ?'Photo': text,
                      "sound": "default",
                      "image": messageImagesUrl![0]
                    },
                    'data' : {
                      "uId": userModel!.uId,
                      "click_action": "FLUTTER_NOTIFICATION_CLICK"
                    },
                  }
              );
              messageImagesUrl = [];
              messageImagesNameInStorage = [];
              db
                  .collection('users')
                  .doc(receiverId)
                  .collection('chats')
                  .doc(myUid)
                  .collection('messages')
                  .doc(messageId.id)
                  .update({
                'messageId': messageId.id,
                if(replyMessage != null )'reply.${'text'}' : replyMessage!.text,
                if(replyMessage != null )'reply.${'images'}' : replyMessage!.messageImages,
                if(replyMessage != null )'reply.${'messageId'}' : replyMessage!.messageId,
                if(replyMessage != null )'reply.${'senderId'}' : replyMessage!.senderId,
              });
            }).catchError((error) {
              if (kDebugMode) {
                print(error);
              }
            });
          }).catchError((error) {
            if (kDebugMode) {
              print(error);
            }
          });
        }
        messageImagesPicker = [];
      }
      if (( messageImagesPicker.isNotEmpty) &&
          messageImagesPicker.length >= 4) {
        emit(SendImageMessageLoadingState());
        for (int index = 0; index < (messageImagesPicker.length); index++) {
          await storage
              . // put new photo to database
          ref()
              .child(
              '$myUid/userMessageImages/${Uri.file((messageImagesPicker[index].path)).pathSegments.last}')
              .putFile(File((messageImagesPicker[index].path)))
              .then((value) async {
            messageImagesNameInStorage?.add(value.ref.name);
            await value.ref.getDownloadURL().then((value) {
              messageImagesUrl?.add(value);
            });
          });
        }

        await db
            .collection('users')
            .doc(myUid)
            .collection('chats')
            .doc(receiverId)
            .collection('messages')
            .add({
          'senderId' : myUid,
          'receiverId' : receiverId,
          'text' : text ?? '',
          'dateTime' : FieldValue.serverTimestamp(),
          'messageImages' :  messageImagesUrl ?? [],
          'messageImagesNamesInStorage' : messageImagesNameInStorage ?? [],
          'isSeen' : false
        })
            .then((messageId) {
          emit(SendImageMessageSuccessState());
          db
              .collection('users')
              .doc(myUid)
              .collection('chats')
              .doc(receiverId)
              .collection('messages')
              .doc(messageId.id)
              .update({
            'messageId': messageId.id,
            if(replyMessage != null )'reply.${'text'}' : replyMessage!.text,
            if(replyMessage != null )'reply.${'images'}' : replyMessage!.messageImages,
            if(replyMessage != null )'reply.${'messageId'}' : replyMessage!.messageId,
            if(replyMessage != null )'reply.${'senderId'}' : replyMessage!.senderId,
          });

          db
              .collection('users')
              .doc(receiverId)
              .collection('chats')
              .doc(myUid)
              .collection('messages')
              .doc(messageId.id)
              .set({
            'senderId' : myUid,
            'receiverId' : receiverId,
            'text' : text ?? '',
            'dateTime' : FieldValue.serverTimestamp(),
            'messageImages' :  messageImagesUrl ?? [],
            'messageImagesNamesInStorage' : messageImagesNameInStorage ?? [],
            'isSeen' : false
          })
              .then((message) {
            db
                .collection('users')
                .doc(receiverId)
                .collection('chats')
                .doc(myUid)
                .collection('messages')
                .doc(messageId.id)
                .update({
              'messageId': messageId.id,
              if(replyMessage != null )'reply.${'text'}' : replyMessage!.text,
              if(replyMessage != null )'reply.${'images'}' : replyMessage!.messageImages,
              if(replyMessage != null )'reply.${'messageId'}' : replyMessage!.messageId,
              if(replyMessage != null )'reply.${'senderId'}' : replyMessage!.senderId,
            });
          }).catchError((error) {
            if (kDebugMode) {
              print(error);
            }
          });
        }).catchError((error) {
          if (kDebugMode) {
            print(error);
          }
        });
        DioHelper.postNotification(
            data: {
              'to' : '/topics/$receiverId',
              'notification' : {
                "title": "${userModel!.name}",
                "body": text == ''? 'Photos' : text,
                "sound": "default",
                "image": messageImagesUrl![0]
              },
              'data' : {
                "uId": userModel!.uId,
                "click_action": "FLUTTER_NOTIFICATION_CLICK"
              },
            }
        );
        messageImagesUrl = [];
        messageImagesPicker = [];
        messageImagesNameInStorage = [];
      }
      if (messageImagePickerCamera != null) {
        emit(SendImageMessageLoadingState());
        await storage
            . // put new photo
        ref()
            .child(
            '$myUid/userMessageImages/${Uri.file((messageImagePickerCamera?.path)!).pathSegments.last}')
            .putFile(messageImagePickerCamera!)
            .then((value) async {
          messageImagesNameInStorage?.add(value.ref.name);
          await value.ref.getDownloadURL().then((value) {
            messageImagesUrl?.add(value);
            emit(SendImageMessageSuccessState());
          });
        });


        await db
            .collection('users')
            .doc(myUid)
            .collection('chats')
            .doc(receiverId)
            .collection('messages')
            .add({
          'senderId' : myUid,
          'receiverId' : receiverId,
          'text' : text ?? '',
          'dateTime' : FieldValue.serverTimestamp(),
          'messageImages' :  messageImagesUrl ?? [],
          'messageImagesNamesInStorage' : messageImagesNameInStorage ?? [],
          'isSeen' : false
        })
            .then((messageId) {
          db
              .collection('users')
              .doc(myUid)
              .collection('chats')
              .doc(receiverId)
              .collection('messages')
              .doc(messageId.id)
              .update({
            'messageId': messageId.id,
            if(replyMessage != null )'reply.${'text'}' : replyMessage!.text,
            if(replyMessage != null )'reply.${'images'}' : replyMessage!.messageImages,
            if(replyMessage != null )'reply.${'messageId'}' : replyMessage!.messageId,
            if(replyMessage != null )'reply.${'senderId'}' : replyMessage!.senderId,
          });
          db
              .collection('users')
              .doc(receiverId)
              .collection('chats')
              .doc(myUid)
              .collection('messages')
              .doc(messageId.id)
              .set({
            'senderId' : myUid,
            'receiverId' : receiverId,
            'text' : text ?? '',
            'dateTime' : FieldValue.serverTimestamp(),
            'messageImages' :  messageImagesUrl ?? [],
            'messageImagesNamesInStorage' : messageImagesNameInStorage ?? [],
            'isSeen' : false
          })
              .then((message) {
            db
                .collection('users')
                .doc(receiverId)
                .collection('chats')
                .doc(myUid)
                .collection('messages')
                .doc(messageId.id)
                .update({
              'messageId': messageId.id,
              if(replyMessage != null )'reply.${'text'}' : replyMessage!.text,
              if(replyMessage != null )'reply.${'images'}' : replyMessage!.messageImages,
              if(replyMessage != null )'reply.${'messageId'}' : replyMessage!.messageId,
              if(replyMessage != null )'reply.${'senderId'}' : replyMessage!.senderId,
            });
          }).catchError((error) {
            if (kDebugMode) {
              print(error);
            }
          });
          DioHelper.postNotification(
              data: {
                'to' : '/topics/$receiverId',
                'notification' : {
                  "title": "${userModel!.name}",
                  "body": text == ''? 'Photo' : text,
                  "sound": "default",
                  "image": messageImagesUrl![0]
                },
                'data' : {
                  "uId": userModel!.uId,
                  "click_action": "FLUTTER_NOTIFICATION_CLICK"
                },
              }
          );
          messageImagePickerCamera = null;
          messageImagesUrl = [];
          messageImagesPicker = [];
          messageImagesNameInStorage = [];
          emit(SendImageMessageSuccessState());
        }).catchError((error) {
          if (kDebugMode) {
            print(error);
          }
        });
      }
    }
    else
    {
      await db.collection('users').doc(myUid).collection('chats').doc(receiverId).collection('messages')
          .add({
        'senderId' : myUid,
        'receiverId' : receiverId,
        'text' : text,
        'dateTime' : FieldValue.serverTimestamp(),
        'messageImages' :  [],
        'isSeen' : false,
      }).then((messageId) async {
        db.collection('users').doc(receiverId).collection('chats').doc(myUid).collection('messages')
            .doc(messageId.id).set({
          'senderId' : myUid,
          'receiverId' : receiverId,
          'text' : text,
          'dateTime' : FieldValue.serverTimestamp(),
          'messageImages' :  [],
          'messageId' : messageId.id,
          'isSeen' : false,
          if(replyMessage != null)'reply' : {
            'text' : replyMessage!.text ,
            'images' : replyMessage!.messageImages ,
            'messageId' : replyMessage!.messageId ,
            'senderId' : replyMessage!.senderId ,
          },
        });
        db
            .collection('users')
            .doc(myUid)
            .collection('chats')
            .doc(receiverId)
            .collection('messages')
            .doc(messageId.id)
            .update({
          'messageId': messageId.id,
          if(replyMessage != null )'reply.${'text'}' : replyMessage!.text,
          if(replyMessage != null )'reply.${'images'}' : replyMessage!.messageImages,
          if(replyMessage != null )'reply.${'messageId'}' : replyMessage!.messageId,
          if(replyMessage != null )'reply.${'senderId'}' : replyMessage!.senderId,
        });

      });
      DioHelper.postNotification(
          data: {
            'to' : '/topics/$receiverId',
            'notification' : {
              "title": "${userModel!.name}",
              "body": text,
              "sound": "default",
            },
            'data' : {
              "uId": userModel!.uId,
              "click_action": "FLUTTER_NOTIFICATION_CLICK"
            },
          }
      );
    }
    if(replyMessage != null){
      clearReplyMessage();
    }
    ///user information
    try{
      await db
          .collection('users')
          .doc(myUid)
          .collection('chats')
          .doc(receiverId)
          .update({
        'image' : receiverUserModel?.image,
        'name' : receiverUserModel?.name,
        'uId' : receiverUserModel!.uId,
      });

      await db
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(myUid)
          .update({
        'image' : userModel!.image,
        'name' : userModel!.name,
        'uId' : userModel!.uId,
      });
    }
    on FirebaseException {
      await db
          .collection('users')
          .doc(myUid)
          .collection('chats')
          .doc(receiverId)
          .set({
        'image' : receiverUserModel?.image,
        'name' : receiverUserModel?.name,
        'uId' : receiverUserModel!.uId,
      });

      await db
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(myUid)
          .set({
        'image' : userModel!.image,
        'name' : userModel!.name,
        'uId' : userModel!.uId,
      });
    }
    getLastMessage(receiverId: receiverId);
  }

  File? messageImagePickerCamera ;
  List<XFile> messageImagesPicker = [] ;
  Future<void> pickMessageImage({
    bool openCamera = false ,
  }) async {
    if(openCamera){
      XFile? pickedFile = await picker.pickImage(source: ImageSource.camera,imageQuality: 60);
      messageImagePickerCamera = File((pickedFile?.path)!);
      emit(MessageImagePickedSuccessState());
    }
    else {
      List<XFile>? pickedFile = await picker.pickMultiImage(
        imageQuality: 60,
        maxHeight: null,
        maxWidth: null,
      );
      messageImagesPicker = pickedFile ;
      emit(MessageImagePickedSuccessState());
    }
  }

  XFile? editedMessagePhoto;
  void editMessagePhoto(path,int index,context)async {

    var croppedFile = await ImageCropper().cropImage(
      sourcePath: (path),
      compressQuality: 100,
      compressFormat: ImageCompressFormat.jpg,

      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.purple,
          toolbarTitle: 'Edit Image',
          backgroundColor: Theme.of(context).primaryColor,
        ),
        IOSUiSettings(
          title: 'Edit Image',
        )
      ],
    );

    if(croppedFile != null){
      editedMessagePhoto = XFile((croppedFile.path));
      emit(EditMessageImagePickedSuccessState());
    }
    if(editedMessagePhoto != null)
    {
      messageImagesPicker[index] = editedMessagePhoto!;
    }
  }
  void removeMessagePhotoFromList({
    int? index,
    bool isCameraPhoto = false
  }){
    if(isCameraPhoto){
      messageImagePickerCamera = null ;
      emit(RemoveMessagePhotoFromList());
    }
    else
    {
      messageImagesPicker.removeAt(index!);
      emit(RemoveMessagePhotoFromList());
    }
  }

  List<String> selectedMessages = [];
  bool isMultiSelectionMode = false ;
  void selectMessage(String messageId){
    isMultiSelectionMode = true ;
    final isSelected = selectedMessages.contains(messageId);
    isSelected
        ? selectedMessages.remove(messageId)
        : selectedMessages.add(messageId);
    emit(SelectMessageState());
    if(selectedMessages.isEmpty){
      isMultiSelectionMode = false ;
    }
  }

  void clearSelectedMessages(){
    selectedMessages.clear();
    isMultiSelectionMode = false ;
    emit(SelectMessageState());
  }

  Future<void> deleteMessage({
    required List<String> messagesId,
    required String receiverId,
    bool deleteForEveryone = false,
  }) async {
    for (var messageId in messagesId){
      await db
          .collection('users')
          .doc(myUid)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .doc(messageId)
          .delete()
          .then((value) {
        if(deleteForEveryone){
          db
              .collection('users')
              .doc(receiverId)
              .collection('chats')
              .doc(myUid)
              .collection('messages')
              .doc(messageId)
              .delete();
        }
      }).catchError((error){
        emit(DeleteMessageErrorState());
      });
    }
    emit(DeleteMessageSuccessState());
    selectedMessages.clear();
    getLastMessage(receiverId: receiverId);
  }

  Future<void> deleteAllMessages({
    required String receiverId,
    bool deleteForEveryone = false,
  }) async {
    await db.collection('users')
        .doc(myUid)
        .collection('chats')
        .doc(receiverId)
        .collection('messages').get().then((snapshot) async {
      for (DocumentSnapshot docs in snapshot.docs){
        db.collection('users')
            .doc(myUid)
            .collection('chats')
            .doc(receiverId)
            .collection('messages').doc(docs.id).delete();
      }
    });
    if(deleteForEveryone){
      await db.collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(myUid)
          .collection('messages').get().then((snapshot) async {
        for (DocumentSnapshot docs in snapshot.docs){
          db.collection('users')
              .doc(receiverId)
              .collection('chats')
              .doc(myUid)
              .collection('messages').doc(docs.id).delete();
        }
      });
    }

    emit(DeleteMessageSuccessState());
    selectedMessages.clear();
    getLastMessage(receiverId: receiverId);
  }

  Future<void> reactOnMessage({
    required String messageId,
    required String receiverId,
    required String emoji,
    required List? myEmojiList,
  }) async {
    clearSelectedMessages();
    await db
        .collection('users')
        .doc(myUid)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .doc(messageId)
        .update({
      'emoji.$myUid' : myEmojiList != null &&myEmojiList.contains(emoji)
          ? FieldValue.arrayRemove([emoji])
          : [emoji]
    })
        .then((value) async {
      await db
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(myUid)
          .collection('messages')
          .doc(messageId)
          .update({
        'emoji.$myUid' : myEmojiList != null &&myEmojiList.contains(emoji)
            ? FieldValue.arrayRemove([emoji])
            : [emoji]
      });

    }).catchError((error){
      if (kDebugMode) {
        print(error);
      }
    });
  }
  MessageModel? replyMessage ;
  void swipeReplayMessage(MessageModel message){
    replyMessage = message ;
    emit(ReplyMessageState());
  }
  void clearReplyMessage(){
    replyMessage = null ;
    emit(ReplyMessageState());
  }

  int? chatColor ;
  Future<void> changeChatColor({
    required String receiverId ,
  }) async {
    try {
      await db
          .collection('users')
          .doc(myUid)
          .collection('chats')
          .doc(receiverId)
          .update({
        'chatColor' : chatColor??4280391411
      });

      await db
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(myUid)
          .update({
        'chatColor' : chatColor??4280391411
      });
    }
    on FirebaseException catch (e){
      if(e.message == 'Some requested document was not found.')
      {
        await db
            .collection('users')
            .doc(myUid)
            .collection('chats')
            .doc(receiverId)
            .set({
          'chatColor' : chatColor??4280391411
        });

        await db
            .collection('users')
            .doc(receiverId)
            .collection('chats')
            .doc(myUid)
            .set({
          'chatColor' : chatColor??4280391411
        });
      }
    }
    chatColor = null ;
  }

  File? chatBackgroundImage ;
  Future<void> pickChatBackgroundImage({
    required BuildContext context ,
    required String receiverId ,
  }) async {
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery,imageQuality: 90);
    if(pickedFile != null){
      var croppedFile = await ImageCropper().cropImage(
        sourcePath: (pickedFile.path),
        compressQuality: 100,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatio: const CropAspectRatio(ratioX: 8, ratioY: 14.5),
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
        chatBackgroundImage = File((croppedFile.path));
        print(chatBackgroundImage?.path);
        navigateToAnimated(
            context: context,
            widget: BackGroundOpacityScreen(
              backgroundImage: chatBackgroundImage!,
              receiverId: receiverId,
            )
        );
      }
      emit(ChatBackgroundImagePickedSuccessState());
    }

  }
  double? chatBackgroundImageOpacity ;
  String? chatBackgroundImageUrl ;
  Future<void> uploadChatBackgroundImage({
    required String receiverId
  }) async {
    emit(UploadChatBackgroundImageLoadingState());
    await storage. // put new photo to database
    ref().
    child('$myUid/userChatBackGroundImages/${Uri.file((chatBackgroundImage?.path)!).pathSegments.last}').
    putFile(chatBackgroundImage!)
        .then((value) async {
      await value.ref.getDownloadURL().then((value) {
        chatBackgroundImageUrl = value ;
      }).catchError((error){
        if (kDebugMode) {
          print(error);
        }
      });
    });
    try {
      await db
          .collection('users')
          .doc(myUid)
          .collection('chats')
          .doc(receiverId)
          .update({
        'backgroundImage' : chatBackgroundImageUrl,
        'backgroundImageOpacity' : chatBackgroundImageOpacity??100
      });
    }
    on FirebaseException catch (e){
      if(e.message == 'Some requested document was not found.')
      {
        await db
            .collection('users')
            .doc(myUid)
            .collection('chats')
            .doc(receiverId)
            .set({
          'backgroundImage' : chatBackgroundImageUrl,
          'backgroundImageOpacity' : chatBackgroundImageOpacity??100
        });
      }
    }
    emit(UploadChatBackgroundImageSuccessState());
  }

  Future<void> removeChatBackgroundImage({
    required String receiverId
  }) async {
    await db
        .collection('users')
        .doc(myUid)
        .collection('chats')
        .doc(receiverId)
        .update({
      'backgroundImage' : null,
      'backgroundImageOpacity' : null,
    });
  }
  Future<void> getLastMessage({
    required String receiverId,
  }) async {
    String? text ;
    dynamic dateTime ;
    bool? isSeen ;
    ///get last message
    await db
        .collection('users')
        .doc(myUid)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('dateTime',descending: true).limit(1)
        .get().then((value) {
      text = value.docs.isNotEmpty ? ((value.docs[0].data()['text']) != '' ? (value.docs[0].data()['text']) : 'Photo') : null;
      dateTime = value.docs.isNotEmpty ? value.docs[0].data()['dateTime'] : null;
      isSeen = value.docs.isNotEmpty ? value.docs[0].data()['isSeen'] : false;
    });
    try {
      db.collection('users').doc(myUid).collection('chats').doc(receiverId).update(
          {
            'lastMessage' : text != null ? 'You : $text' : 'You : Voice message',
            'lastMessageDatetime' : dateTime,
            'isSeen' : true
          }
      );
      db.collection('users').doc(receiverId).collection('chats').doc(myUid).update(
          {
            'lastMessage' : text != null ? '$text' : 'Voice message',
            'lastMessageDatetime' : dateTime,
            'isSeen' : isSeen
          }
      );
    }
    on FirebaseException catch (e) {
      if(e.message == 'Some requested document was not found.'){
        db.collection('users').doc(myUid).collection('chats').doc(receiverId).set(
            {
              'lastMessage' : text != null ? 'You : $text' : 'You : Voice message',
              'lastMessageDatetime' : dateTime,
            }
        );
        db.collection('users').doc(receiverId).collection('chats').doc(myUid).set(
            {
              'lastMessage' : text != null ? '$text' : 'Voice message',
              'lastMessageDatetime' : dateTime,
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

  File? record ;
  String? recordUrl ;
  int? recordDuration ;
  Future<void> sendRecord({
    required String receiverId,
  }) async {
    record?.length().then((value) {
    });
    emit(RecordLoadingState());
    await storage. // put new photo to database
    ref().
    child('$myUid/userChatRecords/${Uri.file((record?.path)!).pathSegments.last}').
    putFile(record!)
        .then((value) async {
      await value.ref.getDownloadURL().then((value) {
        recordUrl = value ;
      }).catchError((error){
        if (kDebugMode) {
          print(error.toString());
        }
      });
    });
    await db.collection('users').doc(myUid).collection('chats').doc(receiverId).collection('messages')
        .add({
      'senderId' : myUid,
      'receiverId' : receiverId,
      'text' : null,
      'dateTime' : FieldValue.serverTimestamp(),
      'messageImages' :  [],
      'record' : recordUrl,
      'recordDuration' : recordDuration,
      'isPlaying' : false,
      'isSeen' : false
    }).then((messageId) async {
      db.collection('users').doc(receiverId).collection('chats').doc(myUid).collection('messages')
          .doc(messageId.id).set({
        'senderId' : myUid,
        'receiverId' : receiverId,
        'text' : null,
        'dateTime' : FieldValue.serverTimestamp(),
        'messageImages' :  [],
        'messageId' : messageId.id,
        'record' : recordUrl,
        'recordDuration' : recordDuration,
        'isPlaying' : false,
        'isSeen' : false,
        if(replyMessage != null)'reply' : {
          'text' : replyMessage!.text ,
          'images' : replyMessage!.messageImages ,
          'messageId' : replyMessage!.messageId ,
          'senderId' : replyMessage!.senderId ,
        },
      });
      db
          .collection('users')
          .doc(myUid)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .doc(messageId.id)
          .update({
        'messageId': messageId.id,
        if(replyMessage != null )'reply.${'text'}' : replyMessage!.text,
        if(replyMessage != null )'reply.${'images'}' : replyMessage!.messageImages,
        if(replyMessage != null )'reply.${'messageId'}' : replyMessage!.messageId,
        if(replyMessage != null )'reply.${'senderId'}' : replyMessage!.senderId,
      });

    });
    DioHelper.postNotification(
        data: {
          'to' : '/topics/$receiverId',
          'notification' : {
            "title": "${userModel!.name}",
            "body": 'Voice message',
            "sound": "default",
          },
          'data' : {
            "uId": userModel!.uId,
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          },
        }
    );
    getLastMessage(receiverId: receiverId);
  }

  Future<void> isPlayingAudio({
    required String? messageId ,
    required String? receiverId ,
    bool isPlaying = false ,
  }) async {
    await db
        .collection('users')
        .doc(myUid)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .doc(messageId).update({
      'isPlaying' : isPlaying
    });
  }

  Future<void> messageSeen({
    required String receiverId,
    required String messageId,
  }) async {
    try{
      await db
          .collection('users')
          .doc(myUid)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isSeen' : true ,
      });

      await db
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(myUid)
          .collection('messages')
          .doc(messageId)
          .update({
        'isSeen' : true ,
      });

      await db.collection('users').doc(myUid).collection('chats').doc(receiverId).update(
          {
            'isSeen' : true ,
          }
      );
    }
    on FirebaseException {
      await db
          .collection('users')
          .doc(myUid)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .doc(messageId)
          .set({
        'isSeen' : true ,
      });

      await db
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(myUid)
          .collection('messages')
          .doc(messageId)
          .set({
        'isSeen' : true ,
      });

      await db.collection('users').doc(myUid).collection('chats').doc(receiverId).set(
          {
            'isSeen' : true ,
          }
      );
    }
  }
}
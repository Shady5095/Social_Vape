import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as player;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as date;
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_cubit.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../../business_logic_layer/chat_cubit/chat_states.dart';
import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../data_layer/models/message_model.dart';
import '../../../data_layer/models/user_model.dart';
import '../../../styles/icon_broken.dart';
import '../../widgets/image_viewer.dart';
import 'chat_settings_screen.dart';
import 'message_images_screen.dart';

class ChatsDetailsScreen extends StatefulWidget {
  final UserModel userModel ;

  const ChatsDetailsScreen({super.key,
    required this.userModel,
  });

  @override
  State<ChatsDetailsScreen> createState() => _ChatsDetailsScreenState();
}

class _ChatsDetailsScreenState extends State<ChatsDetailsScreen> {
  final record = FlutterSoundRecorder();
  final audioPlayer = player.AudioPlayer();
  String? messageIdAudio ;

  Future<void> initRecord() async {
    await Permission.microphone.request();

    await record.openRecorder() ;

    record.setSubscriptionDuration(
      Duration(milliseconds: 500)
    );
  }
  String formatTime(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds);

    return [
      if(duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
  @override
  void initState() {
    super.initState();
    initRecord();
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = (event == player.PlayerState.playing) ;
      });
      if(messageIdAudio != null){
        ChatCubit.get(context).isPlayingAudio(
            messageId: messageIdAudio,
            receiverId: widget.userModel.uId,
            isPlaying: (event == player.PlayerState.playing),
        );
      }
    });


  }

  @override
  void dispose() {
    record.closeRecorder();
    super.dispose();
  }

  final chatController = TextEditingController();

  final itemScrollController = ItemScrollController();

  bool isRecording = false ;

  bool isPlaying = false ;
  Duration currentPosition = Duration.zero ;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ChatCubit>(context),
      child: BlocConsumer<ChatCubit,ChatStates>(
        listener: (context,state){},
        builder: (context,state){
          var chatCubit = ChatCubit.get(context);
          return Scaffold(
              appBar: chatCubit.isMultiSelectionMode ?  AppBar(
                toolbarHeight: 80,
                leadingWidth: double.infinity,
                leading: Row(
                  children: [
                    IconButton(
                      onPressed: (){
                        chatCubit.clearSelectedMessages();
                      },
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        IconBroken.Arrow___Left_2,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      '${chatCubit.selectedMessages.length}',
                      style:  TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).highlightColor,
                          actionsOverflowButtonSpacing: 20,
                          title:  Text(
                            chatCubit.selectedMessages.length == 1
                                ? 'Delete message?'
                                : 'Delete ${chatCubit.selectedMessages.length} messages?',
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(
                                'Delete for everyone',
                                style: TextStyle(
                                    fontSize: 18
                                ),
                              ),
                              onPressed: () {
                                chatCubit.deleteMessage(
                                  messagesId: chatCubit.selectedMessages,
                                  receiverId: (widget.userModel.uId)!,
                                  deleteForEveryone: true,
                                );
                                Navigator.pop(context);
                                chatCubit.isMultiSelectionMode = false ;
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'Delete for me',
                                style: TextStyle(
                                    fontSize: 18
                                ),
                              ),
                              onPressed: () {
                                chatCubit.deleteMessage(
                                    messagesId: chatCubit.selectedMessages,
                                    receiverId: (widget.userModel.uId)!
                                );
                                Navigator.pop(context);
                                chatCubit.isMultiSelectionMode = false ;
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    fontSize: 18
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                        IconBroken.Delete
                    ),
                  ),
                ],
              ) :AppBar(
                toolbarHeight: 60,
                leadingWidth: double.infinity,
                leading: InkWell(
                  onTap: (){
                    navigateTo(
                      context: context,
                      widget: ChatSettingsScreen(userModel: widget.userModel),
                    );
                    chatCubit.getLastMessage(receiverId: widget.userModel.uId!);
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await audioPlayer.pause();
                          Navigator.pop(context);
                          chatCubit.clearReplyMessage();
                          chatCubit.chatTyping(
                              receiverId: widget.userModel.uId!,
                              isMessageSent: true
                          );
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          IconBroken.Arrow___Left_2,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                      Hero(
                        tag: '${widget.userModel.uId!}+chat',
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).highlightColor,
                          backgroundImage: NetworkImage('${widget.userModel.image}'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('users')
                              .doc(widget.userModel.uId)
                              .collection('chats')
                              .doc(myUid).snapshots(),
                          builder: (context, isTyping) {
                            return StreamBuilder(
                                stream: FirebaseFirestore.instance.collection('users')
                                    .doc(widget.userModel.uId).snapshots(),
                                builder: (context, onlineLastSeen) {
                                  DateTime myDateTime = (onlineLastSeen.data?.data()!['lastSeen']??Timestamp.now()).toDate();
                                  String lastSeenText(){
                                    if(myDateTime.year == Timestamp.now().toDate().year && myDateTime.month == Timestamp.now().toDate().month && myDateTime.day == Timestamp.now().toDate().day){
                                      return 'today at ${date.DateFormat('jm').format(myDateTime)}' ;
                                    }
                                    if(myDateTime.year == Timestamp.now().toDate().year && myDateTime.month == Timestamp.now().toDate().month && myDateTime.day == Timestamp.now().toDate().day -1 ){
                                      return 'yesterday at ${date.DateFormat('jm').format(myDateTime)}' ;
                                    }
                                    return "${date.DateFormat('MEd').format(myDateTime)} at ${date.DateFormat('jm').format(myDateTime)}" ;
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${widget.userModel.name}',
                                        style:  TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context).secondaryHeaderColor,
                                        ),
                                      ),
                                      Text(
                                        (isTyping.data?.data()?['typing']??false) ? 'typing...' : onlineLastSeen.data?.data()!['online']??false ? 'online' : 'last seen ${lastSeenText()}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500]
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            );
                          }
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: (){
                      navigateToAnimated(
                          context: context,
                          widget: ChatSettingsScreen(userModel: widget.userModel),
                          animation: PageTransitionType.rightToLeft
                      );
                    },
                    splashColor: Colors.transparent,
                    icon: Icon(
                        IconBroken.More_Circle
                    ),
                  )
                ],
              ) ,
              body: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('users')
                      .doc(myUid)
                      .collection('chats')
                      .doc(widget.userModel.uId).snapshots(),
                  builder: (context, chatSettings) {
                    return Container(
                      decoration: (chatSettings.data?.data()?['backgroundImage']) != null
                          ? BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                              image: CachedNetworkImageProvider('${chatSettings.data?.data()?['backgroundImage']}'),
                              opacity: (chatSettings.data?.data()?['backgroundImageOpacity']/100)??1,
                              fit: BoxFit.cover
                          )
                      )
                          : const BoxDecoration(),
                      child: Column(
                        children: [
                          Expanded(
                            child: StreamBuilder(
                              stream: FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(myUid)
                                  .collection('chats')
                                  .doc(widget.userModel.uId)
                                  .collection('messages')
                                  .orderBy('dateTime',descending: true)
                                  .snapshots(),
                              builder: (context,snapshot){
                                if(snapshot.hasError){
                                  return const Center(
                                    child: Icon(
                                      Icons.warning_amber,
                                      color: Colors.red,
                                      size: 100,
                                    ),
                                  );
                                }
                                if(!snapshot.hasData){
                                  return const Center(child: CircularProgressIndicator(color: Colors.purple,));
                                }
                                if((snapshot.data?.docs.isEmpty)!){
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          IconBroken.Chat,
                                          size: 150,
                                          color: Theme.of(context).secondaryHeaderColor,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'No messages yet...',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  reverse: true,
                                  itemBuilder: (context,index){
                                    //int reverseIndex = (snapshot.data?.docs.length)! -1- index ;
                                    DateTime myDateTime = (snapshot.data?.docs[index].data()['dateTime']??Timestamp.now()).toDate();
                                    MessageModel messageModel = MessageModel.fromJson((snapshot.data?.docs[index].data())!);
                                    final isSelected = chatCubit.selectedMessages.contains(messageModel.messageId);
                                    final haveNip = (index == snapshot.data!.docs.length -1) ||
                                        (index == 0 &&
                                            messageModel.senderId !=
                                                snapshot.data!.docs[index+1].data()['senderId']) ||
                                        (messageModel.senderId !=
                                            snapshot.data!.docs[index+1].data()['senderId'] &&
                                            messageModel.senderId ==
                                                snapshot.data!.docs[index-1].data()['senderId']) ||
                                        (messageModel.senderId !=
                                            snapshot.data!.docs[index+1].data()['senderId'] &&
                                            messageModel.senderId !=
                                                snapshot.data!.docs[index-1].data()['senderId']);

                                    final isShowDateCard = (index == snapshot.data!.docs.length - 1) ||
                                        ((index == 0) && myDateTime.day >
                                            (snapshot.data?.docs[index+1].data()['dateTime'] as Timestamp).toDate().day) ||
                                        (myDateTime.day >
                                            (snapshot.data?.docs[index+1].data()['dateTime'] as Timestamp).toDate().day &&
                                            myDateTime.day <=
                                                (snapshot.data?.docs[index-1].data()['dateTime']??Timestamp.now() as Timestamp).toDate().day);
                                    String dateCardText(){
                                      if(myDateTime.year == Timestamp.now().toDate().year && myDateTime.month == Timestamp.now().toDate().month && myDateTime.day == Timestamp.now().toDate().day){
                                        return 'Today' ;
                                      }
                                      if(myDateTime.year == Timestamp.now().toDate().year && myDateTime.month == Timestamp.now().toDate().month && myDateTime.day == Timestamp.now().toDate().day -1 ){
                                        return 'Yesterday' ;
                                      }
                                      return date.DateFormat('yMMMMd').format(myDateTime) ;
                                    }
                                    String emoji(){
                                      if(messageModel.emoji != null && messageModel.emoji!.isNotEmpty){
                                        if((messageModel.emoji![myUid] != null
                                            && messageModel.emoji![widget.userModel.uId] != null
                                            && messageModel.emoji![myUid].isNotEmpty
                                            && messageModel.emoji![widget.userModel.uId].isNotEmpty)
                                            &&(messageModel.emoji![myUid][0]!=messageModel.emoji![widget.userModel.uId][0])){
                                          return '${messageModel.emoji![myUid][0]} ${messageModel.emoji![widget.userModel.uId][0]}  2';
                                        }
                                        if((messageModel.emoji![myUid] !=null && messageModel.emoji![widget.userModel.uId]==null && messageModel.emoji![myUid].isNotEmpty)
                                            || messageModel.emoji![myUid]!=null
                                                && messageModel.emoji![myUid].isNotEmpty
                                                && messageModel.emoji![widget.userModel.uId]!=null
                                                && messageModel.emoji![widget.userModel.uId].isEmpty){
                                          return '${messageModel.emoji![myUid][0]}';
                                        }
                                        if((messageModel.emoji![myUid] ==null && messageModel.emoji![widget.userModel.uId]!=null && messageModel.emoji![widget.userModel.uId].isNotEmpty)
                                            || messageModel.emoji![myUid]!=null
                                                && messageModel.emoji![myUid].isEmpty
                                                && messageModel.emoji![widget.userModel.uId]!=null
                                                && messageModel.emoji![widget.userModel.uId].isNotEmpty){
                                          return '${messageModel.emoji![widget.userModel.uId][0]}';
                                        }
                                        if((messageModel.emoji![myUid] != null
                                            && messageModel.emoji![widget.userModel.uId] != null
                                            && messageModel.emoji![myUid].isNotEmpty
                                            && messageModel.emoji![widget.userModel.uId].isNotEmpty)
                                            &&(messageModel.emoji![myUid][0]==messageModel.emoji![widget.userModel.uId][0])){
                                          return '${messageModel.emoji![myUid][0]} 2';
                                        }
                                      }
                                      return '';
                                    }
                                    if(!messageModel.isSeen! && messageModel.receiverId == myUid){
                                      chatCubit.messageSeen(
                                          receiverId: widget.userModel.uId!,
                                          messageId: messageModel.messageId!
                                      );
                                    }
                                    return Column(
                                      children: [
                                        if(isShowDateCard) Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0 , top: 3.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).highlightColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              dateCardText(),
                                              style:  TextStyle(
                                                color: Theme.of(context).secondaryHeaderColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if(snapshot.data?.docs[index].data()['senderId']==myUid)buildMessage(
                                            context: context,
                                            messageModel: messageModel,
                                            isUserMessage: false,
                                            haveNip: haveNip,
                                            index : index,
                                            userModel: widget.userModel,
                                            isSelected: isSelected,
                                            emoji: emoji(),
                                            chatColor: (chatSettings.data?.data()?['chatColor'])??-9820454,
                                            chatCubit: chatCubit
                                        ),
                                        if(snapshot.data?.docs[index].data()['senderId']!=myUid)buildMessage(
                                            context: context,
                                            messageModel: messageModel,
                                            isUserMessage: true,
                                            haveNip: haveNip,
                                            index : index,
                                            userModel: widget.userModel,
                                            isSelected: isSelected,
                                            emoji: emoji(),
                                            chatColor: (chatSettings.data?.data()?['chatColor'])??-9820454,
                                            chatCubit: chatCubit
                                        ),
                                      ],
                                    ) ;
                                  },
                                  separatorBuilder: (context,index)=>const SizedBox(height: 5,),
                                  itemCount: (snapshot.data?.docs.length)!,
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                if(((chatCubit.messageImagesPicker.isNotEmpty)))
                                  SizedBox(
                                    height: 160,
                                    child: ListView.separated(
                                        scrollDirection: Axis.horizontal,

                                        itemBuilder:(context,index)=> selectedPhotos(
                                          messagePhoto: chatCubit.messageImagesPicker[index],
                                          index: index,
                                          state: state,
                                          cubit: ChatCubit.get(context),
                                          messagePhotoCamera: chatCubit.messageImagePickerCamera,
                                        ),
                                        separatorBuilder: (context,index)=>const SizedBox(
                                          width: 7,
                                        ),
                                        itemCount: (chatCubit.messageImagesPicker.length)
                                    ),
                                  ),
                                if(chatCubit.messageImagePickerCamera != null)
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: 190,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.black.withOpacity(0.5)
                                        ),
                                        height: 200,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),

                                            child: Image(
                                              width: 300,
                                              fit: BoxFit.cover,
                                              image: FileImage((chatCubit.messageImagePickerCamera)!),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: InkWell(
                                          onTap: (){
                                            chatCubit.removeMessagePhotoFromList(
                                                isCameraPhoto: true
                                            );
                                          },
                                          child: const CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.red,
                                            child: Icon(
                                              Icons.close,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if(state is SendImageMessageLoadingState)
                                        const Positioned(
                                            right: 60,
                                            top: 60,
                                            child: CircularProgressIndicator(color: Colors.purple,
                                            ))
                                    ],
                                  ),
                                if(chatCubit.replyMessage != null)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FittedBox(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[900],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 7,
                                                      decoration: BoxDecoration(
                                                        color: chatCubit.replyMessage?.senderId != myUid
                                                            ? Colors.grey[700]
                                                            : Color((chatSettings.data?.data()?['chatColor'])??-9820454),
                                                        borderRadius: const BorderRadius.only(
                                                          topLeft: Radius.circular(12),
                                                          bottomLeft: Radius.circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                '${chatCubit.replyMessage?.senderId != myUid
                                                                    ? widget.userModel.name : 'You'}',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style:  TextStyle(
                                                                  color: chatCubit.replyMessage?.senderId != myUid
                                                                      ? Colors.grey[700]
                                                                      : Color((chatSettings.data?.data()?['chatColor'])??-9820454),
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                              if(chatCubit.replyMessage!.messageImages!.isEmpty || chatCubit.replyMessage!.messageImages!.length > 1)
                                                                InkWell(
                                                                  onTap: (){
                                                                    chatCubit.clearReplyMessage();
                                                                  },
                                                                  child: const Icon(
                                                                    Icons.close,
                                                                    color: Colors.white54,
                                                                    size: 20,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              if(chatCubit.replyMessage!.text == null)
                                                                const Icon(
                                                                  Icons.mic,
                                                                  color: Colors.white54,
                                                                ),
                                                              Text(
                                                                chatCubit.replyMessage!.text == null
                                                                    ? formatTime(Duration(microseconds: (chatCubit.replyMessage!.recordDuration)!))
                                                                    : chatCubit.replyMessage!.text == '' ? 'Photo'
                                                                    : '${chatCubit.replyMessage!.text}',
                                                                style: const TextStyle(
                                                                    color: Colors.white54,
                                                                    fontSize: 16
                                                                ),
                                                                maxLines: 3,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if(chatCubit.replyMessage!.messageImages!.isNotEmpty
                                                        &&chatCubit.replyMessage!.messageImages!.length == 1)
                                                      Stack(
                                                        alignment: Alignment.topRight,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: const BorderRadius.only(topRight: Radius.circular(12),bottomRight: Radius.circular(12)),
                                                            child: Image.network(
                                                              '${chatCubit.replyMessage?.messageImages![0]}',
                                                              width: 65,
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: (){
                                                              chatCubit.clearReplyMessage();
                                                            },
                                                            child: const CircleAvatar(
                                                              backgroundColor: Colors.white54,
                                                              radius: 10,
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors.black,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: chatController,
                                        textAlign: TextAlign.start,
                                        showCursor: isRecording ? false : true,
                                        textDirection: TextDirection.rtl,
                                        onChanged: (value){
                                          chatCubit.chatTyping(
                                              receiverId: widget.userModel.uId!,
                                              value: value
                                          );
                                        },
                                        maxLines: 4,
                                        minLines: 1,
                                        autofocus: true,
                                        style: TextStyle(
                                            color: Theme.of(context).secondaryHeaderColor,
                                            height: 1.5
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.all(9),
                                          isDense: true,
                                          filled: true,

                                          prefix: isRecording ? Row(
                                            children: [
                                              const Icon(Icons.mic,color: Colors.red, size: 25,),
                                              const SizedBox(width: 3,),
                                              StreamBuilder<RecordingDisposition>(
                                                  stream: record.onProgress,
                                                  builder: (context, snapshot) {
                                                    final duration = snapshot.hasData
                                                        ? snapshot.data!.duration
                                                        : Duration.zero;
                                                    chatCubit.recordDuration = duration.inMicroseconds ;
                                                    String twoDigits(int n) => n.toString().padLeft(2, '0');

                                                    final twoDigitMinutes =
                                                    twoDigits(duration.inMinutes.remainder(60));
                                                    final twoDigitSeconds =
                                                    twoDigits(duration.inSeconds.remainder(60));
                                                    return Text(
                                                      '$twoDigitMinutes:$twoDigitSeconds',
                                                      style:  TextStyle(
                                                          color: Colors.grey[500]
                                                      ),);
                                                  }
                                              ),
                                            ],
                                          ) : null,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context).highlightColor,
                                              ),
                                              borderRadius: BorderRadius.circular(20)
                                          ),
                                          fillColor: Theme.of(context).highlightColor,
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              borderSide:  BorderSide(
                                                color: Theme.of(context).highlightColor,
                                              )
                                          ),
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                            height: 0.8,
                                          ),
                                          hintText: isRecording ? null : 'Message',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),

                                          ),
                                        ),
                                      ),
                                    ),
                                    if(!isRecording)
                                      IconButton(
                                        onPressed: (){
                                          SocialCubit.get(context).showCustomDialog(
                                            context: context,
                                            galleryOnTap: (){
                                              chatCubit.pickMessageImage();
                                              Navigator.pop(context);
                                            },
                                            cameraOnTap: (){
                                              chatCubit.pickMessageImage(openCamera: true);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                        splashColor: Colors.transparent,
                                        icon: const Icon(
                                          Icons.attachment_outlined,
                                          color: Colors.green,
                                          size: 32,
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: (){
                                        if(chatController.text.isNotEmpty || (chatCubit.messageImagesPicker.isNotEmpty) ||chatCubit.messageImagePickerCamera != null ){
                                          chatCubit.sendMessage(
                                              receiverId: (widget.userModel.uId)!,
                                              dateTime: DateTime.now().toString(),
                                              text: chatController.text,
                                              receiverUserModel: widget.userModel
                                          );
                                          chatController.clear();
                                        }
                                      },
                                      onLongPressStart: (value) async {
                                        setState(() {
                                          isRecording = true ;
                                        });
                                        record.startRecorder(toFile : '${DateTime.now()}.aac',codec: Codec.aacMP4);
                                      },
                                      onLongPressEnd: (value)  {
                                        setState(() {
                                          isRecording = false ;
                                        });
                                        record.stopRecorder().then((value) {
                                          chatCubit.record = File(value!);
                                          chatCubit.sendRecord(receiverId: (widget.userModel.uId)!);
                                        });
                                      },
                                      child:  Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          chatController.text.isEmpty
                                              && chatCubit.messageImagesPicker.isEmpty
                                              && chatCubit.messageImagePickerCamera == null
                                              ?  Icons.mic
                                              : IconBroken.Send,
                                          color: Color((chatSettings.data?.data()?['chatColor'])??-9820454),
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              )
          );
        },
      ),
    );
  }

  Widget buildMessage({
  required BuildContext context,
  required MessageModel messageModel,
  required UserModel userModel,
  required bool isUserMessage,
  required bool haveNip,
  required bool isSelected,
  required int index,
  required String emoji,
  required int chatColor,
  required ChatCubit chatCubit,
}) {
    return SwipeTo(
      key: GlobalKey(),
        onRightSwipe: (){
          chatCubit.swipeReplayMessage(messageModel);
        },
      iconOnRightSwipe: Icons.reply,
      iconColor: Colors.grey[700],
      onLeftSwipe: (){
        chatCubit.swipeReplayMessage(messageModel);
      },
      animationDuration: const Duration(milliseconds: 200),

        child: Stack(
          alignment: isUserMessage ? Alignment.bottomLeft : Alignment.bottomRight,
          children: [
            Column(
              children: [
                if(isSelected&&chatCubit.selectedMessages.length == 1)
                  buildSelectEmojiMenu(
                    messageModel: messageModel,
                    chatCubit: chatCubit,
                    userModel: userModel,
                  ),
                  Align(
                  alignment: isUserMessage ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
                  child: InkWell(
                    onLongPress: (){
                      chatCubit.selectMessage((messageModel.messageId)!);
                    },
                    onTap: (){
                      if(chatCubit.isMultiSelectionMode){
                        chatCubit.selectMessage((messageModel.messageId)!);
                      }
                      else if(messageModel.messageImages!.length < 4 && messageModel.messageImages!.isNotEmpty){
                        navigateToAnimated(
                          context: context,
                          widget: ImageViewer(
                            photo: NetworkImage('${messageModel.messageImages![0]}'),
                          ),
                        );
                      }
                      else if(messageModel.messageImages!.isNotEmpty){
                        navigateToAnimated(
                          context: context,
                          widget: MessageImagesScreen(
                              messageModel: messageModel,
                              senderName: (userModel.name)!
                          ),
                        );
                      }
                    },
                    onDoubleTap: (){
                      chatCubit.reactOnMessage(
                          messageId: (messageModel.messageId)!,
                          receiverId: (userModel.uId)!,
                          emoji: '❤',
                          myEmojiList: (messageModel.emoji?[myUid])??[]
                      );
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding:  chatCubit.isMultiSelectionMode
                              ? EdgeInsets.only(left:  isUserMessage ?  45 : 0 ,right: isUserMessage ? 0 : haveNip ? 8.0 : 15)
                              : (isUserMessage ? EdgeInsets.only(left:  haveNip ? 8.0 : 15) : EdgeInsets.only(right:  haveNip ? 8.0 : 15)),
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Align(
                                alignment: isUserMessage ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
                                child: FittedBox(
                                  child: ClipPath(
                                    clipper: haveNip ? UpperNipMessageClipperTwo(
                                      isUserMessage ? MessageType.receive : MessageType.send,
                                      nipWidth: 6,
                                      nipHeight: 10,
                                      bubbleRadius: haveNip ? 12 : 0 ,
                                    ): null ,
                                    child: Container(
                                      color: Colors.transparent,
                                      constraints: const BoxConstraints(
                                        maxWidth: double.infinity,
                                      ),
                                      child: Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width * 0.70,
                                            //minWidth: MediaQuery.of(context).size.width * 0.25
                                        ),
                                        padding:  messageModel.messageImages!.isNotEmpty || messageModel.reply != null
                                            ? EdgeInsets.only(top: 5,left: messageModel.reply != null && isUserMessage && haveNip ? 11 : haveNip && isUserMessage ? 10 : 5, right: messageModel.reply != null && haveNip && !isUserMessage ? 11 : haveNip && !isUserMessage ? 10 :5)
                                            : EdgeInsets.only(left: isUserMessage
                                            || !haveNip ? 12 : 8,top: 8 , bottom: 2, right: isUserMessage
                                            || !haveNip ? 9 : 12),
                                        decoration: BoxDecoration(
                                            color: isUserMessage ? Colors.grey[900] : Color(chatColor),
                                            borderRadius: haveNip ? null : BorderRadius.circular(12)
                                        ),
                                        child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            if(messageModel.reply != null)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 5.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(24, 24, 24, 0.10),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: IntrinsicHeight(
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            width: 7,
                                                            decoration: BoxDecoration(
                                                              color: isUserMessage ? Color(chatColor) : Theme.of(context).highlightColor,
                                                              borderRadius: const BorderRadius.only(
                                                                topLeft: Radius.circular(12),
                                                                bottomLeft: Radius.circular(12),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  '${messageModel.reply!['senderId'] != myUid
                                                                      ? userModel.name : 'You'}',
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style:  TextStyle(
                                                                    color: isUserMessage ? Color(chatColor) : Theme.of(context).highlightColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 0,
                                                                ),
                                                                Text(
                                                                  messageModel.reply!['text'] == null ? 'Voice message' : messageModel.reply!['text'] == '' ? 'Photo' : '${messageModel.reply!['text']}',
                                                                  style: const TextStyle(
                                                                      color: Colors.white54,
                                                                      fontSize: 16
                                                                  ),
                                                                  maxLines: 3,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          if(messageModel.reply!['images'].isNotEmpty
                                                              &&messageModel.reply!['images'].length == 1)
                                                          Padding(
                                                            padding: const EdgeInsets.only(left : 10.0),
                                                            child: ClipRRect(
                                                              borderRadius: const BorderRadius.only(topRight: Radius.circular(12),bottomRight: Radius.circular(12)),
                                                              child: Image.network(
                                                                '${messageModel.reply!['images'][0]}',
                                                                width: 65,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if(messageModel.messageImages!.length >= 4)
                                              GridView.count(
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                crossAxisCount: 2,
                                                childAspectRatio: 1 / 1,
                                                mainAxisSpacing: 4,
                                                crossAxisSpacing: 4,
                                                children: List.generate(
                                                  4,
                                                      (index) => SizedBox(
                                                    child: Stack(
                                                      fit: StackFit.expand,
                                                      children: [
                                                        ClipRRect(
                                                            borderRadius: BorderRadius.circular(12),
                                                            child: Image.network(
                                                              '${messageModel.messageImages![index]}',
                                                              fit: BoxFit.cover,
                                                              loadingBuilder: (BuildContext context, Widget child,
                                                                  ImageChunkEvent? loadingProgress) {
                                                                if (loadingProgress == null) {
                                                                  return child;
                                                                }
                                                                return Center(
                                                                  child: CircularProgressIndicator(
                                                                    color: Colors.white,
                                                                    value: loadingProgress.expectedTotalBytes != null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                        loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                                  ),
                                                                );
                                                              },
                                                            )),
                                                        if(index == 3 && messageModel.messageImages!.length > 4)
                                                          Center(
                                                            child: Text(
                                                              '+${messageModel.messageImages!.length - 4}',
                                                              style: const TextStyle(
                                                                  fontSize: 35,
                                                                  color: Colors.white
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if(messageModel.messageImages!.length < 4 && messageModel.messageImages!.isNotEmpty)
                                              Padding(
                                                padding:  EdgeInsets.only(bottom: messageModel.text != '' ? 5 : 0),
                                                child: SizedBox(
                                                  child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: FadeInImage(
                                                        image: CachedNetworkImageProvider(
                                                          '${messageModel.messageImages![0]}',
                                                        ), placeholder: MemoryImage(kTransparentImage),
                                                      )),
                                                ),
                                              ),
                                            Container(
                                              constraints: BoxConstraints(
                                                minWidth: MediaQuery.of(context).size.width * 0.17
                                              ),
                                              child: Stack(
                                                children: [
                                                  if(messageModel.messageImages!.isNotEmpty ||messageModel.reply !=null)
                                                    Align(
                                                      alignment: AlignmentDirectional.centerEnd,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(bottom: 13.0 ,left: messageModel.messageImages!.isNotEmpty ? 5 : 0 ),
                                                        child: Text(
                                                          isUserMessage ? '${messageModel.text}' :'${messageModel.text}',
                                                          textDirection: TextDirection.rtl,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if(messageModel.messageImages!.isEmpty &&messageModel.reply == null&& messageModel.text != null)
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 15.0 ),
                                                      child: Text(
                                                        //textAlign: TextAlign.start,
                                                        textDirection: TextDirection.rtl,
                                                        isUserMessage ? '${messageModel.text}' :'${messageModel.text}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                        ),

                                                      ),
                                                    ),
                                                    if(messageModel.record != null)
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 15.0 ),
                                                      child: SizedBox(
                                                        //width: MediaQuery.of(context).size.width * 0.40,
                                                        height: 53,
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor: Theme.of(context).highlightColor,
                                                              radius: 27,
                                                              backgroundImage: CachedNetworkImageProvider(
                                                                '${isUserMessage ? widget.userModel.image : chatCubit.userModel!.image}'
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                IconButton(
                                                                  onPressed: () async {
                                                                    if(isPlaying){
                                                                      await chatCubit.isPlayingAudio(
                                                                        messageId: messageIdAudio,
                                                                        receiverId: widget.userModel.uId,
                                                                        isPlaying: false,
                                                                      );
                                                                    }
                                                                    messageIdAudio = messageModel.messageId;
                                                                    if(messageModel.isPlaying!){
                                                                      await audioPlayer.pause();
                                                                    }
                                                                    else
                                                                      {
                                                                        await audioPlayer.play(player.UrlSource(
                                                                          (messageModel.record)!
                                                                        ));
                                                                      }
                                                                  },
                                                                  padding: const EdgeInsets.only(left: 17,top: 11,bottom: 11),
                                                                  constraints: const BoxConstraints(
                                                                    maxWidth: 30
                                                                  ),
                                                                  icon: Icon(
                                                                    messageModel.isPlaying! ? CupertinoIcons.pause : CupertinoIcons.play_arrow_solid,
                                                                    color: Colors.white,
                                                                    size: 27,
                                                                  ),
                                                                ),
                                                                StreamBuilder(
                                                                  stream: audioPlayer.onPositionChanged,
                                                                  builder: (context,snapshot) {
                                                                    return Row(
                                                                      children: [
                                                                        if(mounted)
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width * 0.42,
                                                                          child: Slider(
                                                                              value: snapshot.data == null || !messageModel.isPlaying!
                                                                                  ? 0
                                                                                  : ((snapshot.data!.inMicroseconds.toDouble())/Duration(microseconds: messageModel.recordDuration!).inMicroseconds.toDouble()) > 1
                                                                                  ? 1 :((snapshot.data!.inMicroseconds.toDouble())/Duration(microseconds: messageModel.recordDuration!).inMicroseconds.toDouble()),
                                                                              activeColor: Colors.lightBlue,
                                                                            inactiveColor: Colors.grey[700],
                                                                            onChanged: (double value) {},
                                                                          ),
                                                                        )
                                                                      ],
                                                                    );
                                                                  }
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  Positioned(
                                                    bottom: messageModel.messageImages!.isNotEmpty ? 4 :  2,
                                                    right: 1,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          date.DateFormat('jm').format((messageModel.dateTime??Timestamp.now()).toDate()),
                                                          style: const TextStyle(
                                                            color: Colors.white54,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        if(!isUserMessage)
                                                          const SizedBox(
                                                            width: 2,
                                                          ),
                                                        if(!isUserMessage)
                                                           Icon(
                                                            messageModel.isSeen! ? Icons.done_all :  Icons.done,
                                                            color:  Colors.white54,
                                                            size: 18,
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  if(messageModel.record != null)
                                                    Positioned(
                                                      bottom: 2,
                                                      right: 140,
                                                      child: Row(
                                                        children: [
                                                          StreamBuilder(
                                                            stream: audioPlayer.onPositionChanged,
                                                            builder: (context, snapshot) {
                                                              return Text(
                                                                messageModel.isPlaying! ? formatTime(snapshot.data??Duration(microseconds: (messageModel.recordDuration)!)) : formatTime(Duration(microseconds: (messageModel.recordDuration)!)),
                                                                style: const TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 14,
                                                                ),
                                                              );
                                                            }
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if(isSelected)
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    opacity: 0.4, duration: const Duration(milliseconds: 400),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              Align(
                                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                                  child: const SizedBox()
                              )
                            ],
                          ),
                        ),
                        if(chatCubit.isMultiSelectionMode)
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: isSelected ? Colors.green:Theme.of(context).scaffoldBackgroundColor,
                                  child: isSelected ? const Icon(
                                    Icons.check,
                                    size: 18,
                                  ): null,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if(messageModel.emoji != null && messageModel.emoji!.isNotEmpty && emoji !='')
                  Align(
                    alignment: isUserMessage ? Alignment.centerLeft : Alignment.centerRight,
                    child: Padding(
                      padding: chatCubit.isMultiSelectionMode
                          ? EdgeInsets.only(left:  isUserMessage ?  45 : 0 ,right: isUserMessage ? 0 : haveNip ? 8.0 : 15)
                          : (isUserMessage ? EdgeInsets.only(left:  haveNip ? 8.0 : 15) : EdgeInsets.only(right:  haveNip ? 8.0 : 15)),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.70,
                        height: 25,
                      ),
                    ),
                  ),
              ],
            ),
            if(messageModel.emoji != null && messageModel.emoji!.isNotEmpty && emoji !='')
              buildEmojiAfterUserReact(
                chatCubit: chatCubit,
                emoji: emoji,
                isUserMessage: isUserMessage,
              ),
          ],
        ),
    );
  }

  Widget buildEmojiAfterUserReact({chatCubit, isUserMessage, emoji}) => Padding(
    padding:  EdgeInsets.only(left: isUserMessage
        ? chatCubit.isMultiSelectionMode
        ?  59 : 22 : 0, right: isUserMessage
        ? 0 : 22
    ),
    child: Container(
      padding: const EdgeInsets.all(5.5),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(24, 24, 24, 1.0),
          borderRadius: BorderRadius.circular(25)
      ),
      child:  Text(
        //textDirection: TextDirection.ltr,
        emoji,
        style: const TextStyle(
            fontSize: 16,
            color: Colors.white
        ),
      ),
    ),
  );

  Widget buildSelectEmojiMenu({required MessageModel messageModel , required ChatCubit chatCubit , required UserModel userModel}) => Container(
    width: MediaQuery.of(context).size.width * 0.75,
    height: 55,
    decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20)
    ),
    child: Builder(
      builder: (context){
        bool? myEmoji(String emoji){
          if(messageModel.emoji != null && messageModel.emoji![myUid] != null && messageModel.emoji![myUid].isNotEmpty){
            if(messageModel.emoji![myUid][0]== emoji){
              return true ;
            }
          }
          return false ;
        }
        return Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: (){
                  chatCubit.reactOnMessage(
                      messageId: (messageModel.messageId)!,
                      receiverId: (userModel.uId)!,
                      emoji: '👍',
                      myEmojiList: (messageModel.emoji?[myUid])??[]
                  );
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(24, 24, 24, myEmoji('👍')! ? 0.9 : 0),
                  radius: 22,
                  child: const Center(
                    child: Text(
                      '👍',
                      style: TextStyle(
                          fontSize: 28
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: (){
                  chatCubit.reactOnMessage(
                      messageId: (messageModel.messageId)!,
                      receiverId: (userModel.uId)!,
                      emoji: '❤',
                      myEmojiList: (messageModel.emoji?[myUid])??[]
                  );
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(24, 24, 24, myEmoji('❤')! ? 0.9 : 0),
                  radius: 22,
                  child: const Center(
                    child: Text(
                      '❤',
                      style: TextStyle(
                          fontSize: 28
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: (){
                  chatCubit.reactOnMessage(
                      messageId: (messageModel.messageId)!,
                      receiverId: (userModel.uId)!,
                      emoji: '😂',
                      myEmojiList: (messageModel.emoji?[myUid])??[]
                  );
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(24, 24, 24, myEmoji('😂')! ? 0.9 : 0),
                  radius: 22,
                  child: const Center(
                    child: Text(
                      '😂',
                      style: TextStyle(
                          fontSize: 28
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: (){
                  chatCubit.reactOnMessage(
                      messageId: (messageModel.messageId)!,
                      receiverId: (userModel.uId)!,
                      emoji: '😮',
                      myEmojiList: (messageModel.emoji?[myUid])??[]
                  );
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(24, 24, 24, myEmoji('😮')! ? 0.9 : 0),
                  radius: 22,
                  child: const Center(
                    child: Text(
                      '😮',
                      style: TextStyle(
                          fontSize: 28
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: (){
                  chatCubit.reactOnMessage(
                      messageId: (messageModel.messageId)!,
                      receiverId: (userModel.uId)!,
                      emoji: '😢',
                      myEmojiList: (messageModel.emoji?[myUid])??[]
                  );
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(24, 24, 24, myEmoji('😢')! ? 0.9 : 0),
                  radius: 22,
                  child: const Center(
                    child: Text(
                      '😢',
                      style: TextStyle(
                          fontSize: 28
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: (){
                  chatCubit.reactOnMessage(
                      messageId: (messageModel.messageId)!,
                      receiverId: (userModel.uId)!,
                      emoji: '😡',
                      myEmojiList: (messageModel.emoji?[myUid])??[]
                  );
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(24, 24, 24, myEmoji('😡')! ? 0.9 : 0),
                  radius: 22,
                  child: const Center(
                    child: Text(
                      '😡',
                      style: TextStyle(
                          fontSize: 28
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget selectedPhotos({
    XFile? messagePhoto,
    File? messagePhotoCamera,
    required int index,
    required ChatCubit cubit,
    required ChatStates state
  }) =>
      Stack(
        alignment: Alignment.topRight,
        children: [
          InkWell(
            onTap: (){
              cubit.editMessagePhoto(messagePhoto?.path, index,context);
            },
            child: SizedBox(
                width: 160,
                height: 160,
                child: Image(
                  image: FileImage(File((messagePhotoCamera?.path)??(messagePhoto?.path)!)),
                  fit: BoxFit.cover,
                )
            ),
          ),
          if(state is !SendImageMessageLoadingState)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
              onTap: (){
                cubit.removeMessagePhotoFromList(
                  index: index
                );
              },
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.close,
                  size: 15,
                ),
              ),
            ),
          ),
          if(state is SendImageMessageLoadingState)
          const Positioned(
            right: 60,
              top: 60,
              child: CircularProgressIndicator(color: Colors.purple,
              ))
        ],
      );
}

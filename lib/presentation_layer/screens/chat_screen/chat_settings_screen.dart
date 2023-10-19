import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_cubit.dart';

import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../data_layer/models/user_model.dart';
import '../../../styles/icon_broken.dart';
import '../user_profile_screen/user_profile_screen.dart';

class ChatSettingsScreen extends StatelessWidget {
  UserModel userModel ;

  int? chatColor ;

  ChatSettingsScreen({
    required this.userModel
  });

  @override
  Widget build(BuildContext context) {
    var chatCubit = ChatCubit.get(context);
    return Scaffold(
      appBar: deafaultAppBar(
          context: context,
        title: ''
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users')
              .doc(myUid)
              .collection('chats')
              .doc(userModel.uId).snapshots(),
          builder: (context, chatSetting) {
            if(!chatSetting.hasData){
              return const SizedBox();
            }
            return Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                Center(
                  child: Hero(
                    tag: '${userModel.uId}+chat',
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(
                        '${userModel.image}',
                      ),
                      backgroundColor: Theme.of(context).highlightColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  '${userModel.name}',
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 28
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ListTile(
                  onTap: (){
                    navigateToAnimated(
                      context: context,
                      widget: UserProfileScreen(
                          userUid: userModel.uId!,
                          userName: userModel.name!,
                      ),
                      animation: PageTransitionType.rightToLeft,
                    );
                  },
                  leading:  Icon(
                    IconBroken.Profile,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 30,
                  ),
                  title:  Text(
                    'View profile',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 20
                    ),
                  ),
                ),
                ListTile(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).highlightColor,
                        actionsOverflowButtonSpacing: 20,
                        title:  Text(
                          'Select color',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor
                          ),
                        ),
                        actions: <Widget>[
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: colorPicker(
                              listOfColors: [
                                Colors.blue, ///4280391411   4280391411
                                Colors.red, ///-3145728   4294198070
                                Colors.deepPurpleAccent, ///-9820454   4286336511
                                Colors.amberAccent, ///-6317564   4294956864
                                Colors.green, ///-13850541   4283215696
                                Colors.pinkAccent, ///-2086252   4294918273
                                Colors.deepOrange, ///-181441   4294924066
                                Colors.teal,
                                Colors.cyan,
                                Colors.purple ///4288423856   -5439276
                              ],
                              circleSize: 50,
                              onColorChange: (color){
                                print(color?.value);
                                switch(color?.value)
                                {
                                  case 4280391411 : {
                                    chatCubit.chatColor = 4280391411 ;
                                  }
                                  break ;
                                  case 4294198070 : {
                                    chatCubit.chatColor = -3145728 ;
                                  }
                                  break ;
                                  case 4286336511 : {
                                    chatCubit.chatColor = -9820454 ;
                                  }
                                  break ;
                                  case 4294956864 : {
                                    chatCubit.chatColor = -6317564 ;
                                  }
                                  break ;
                                  case 4283215696 : {
                                    chatCubit.chatColor = -13850541 ;
                                  }
                                  break ;
                                  case 4294918273 : {
                                    chatCubit.chatColor = -2086252 ;
                                  }
                                  break ;
                                  case 4294924066 : {
                                    chatCubit.chatColor = -2927269 ;
                                  }
                                  break ;
                                  case 4278228616 : {
                                    chatCubit.chatColor = 4278228616 ;
                                  }
                                  break ;
                                  case 4278238420 : {
                                    chatCubit.chatColor = 4278238420 ;
                                  }
                                  break ;
                                  case 4288423856 : {
                                    chatCubit.chatColor = -5439276 ;
                                  }
                                  break ;
                                }
                              },
                              selectedColor: Color(chatCubit.chatColor??4280391411) ,
                            ),
                          ),
                          TextButton(
                            child: const Text(
                              'Ok',
                              style: TextStyle(
                                  fontSize: 18
                              ),
                            ),
                            onPressed: () {
                              chatCubit.changeChatColor(
                                  receiverId: (userModel.uId)!
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  leading:  Icon(
                    Icons.color_lens,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 30,
                  ),
                  title:  Text(
                    'Change chat color',
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 20
                    ),
                  ),
                ),
                ListTile(
                  onTap: (){
                    chatCubit.pickChatBackgroundImage(context: context,receiverId: userModel.uId!);
                  },
                  leading:  Icon(
                    IconBroken.Image,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 30,
                  ),
                  title:  Text(
                    'Change background image',
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 20
                    ),
                  ),
                ),
                if(chatSetting.data!.data() != null && chatSetting.data!.data()!['backgroundImage'] != null)
                ListTile(
                  onTap: (){
                    chatCubit.removeChatBackgroundImage(receiverId: userModel.uId!).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Background removed successfully'),
                      ));
                    });
                  },
                  leading:  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                       Icon(
                        IconBroken.Image,
                        size: 30,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                        RotationTransition(
                          turns: AlwaysStoppedAnimation(330 / 360),
                          child: Container(
                            height: 40,
                            width: 2,
                            decoration:  BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,

                            ),
                          ),
                        ),
                    ],
                  ),
                  title:  Text(
                    'Remove background image',
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 20
                    ),
                  ),
                ),
                ListTile(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).highlightColor,
                        actionsOverflowButtonSpacing: 20,
                        title:  Text(
                          'Delete all messages?',
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
                              chatCubit.deleteAllMessages(
                                  receiverId: (userModel.uId)!,
                                  deleteForEveryone: true,
                              ).then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Chat deleted successfully'),
                                ));
                              });
                              Navigator.pop(context);
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
                              chatCubit.deleteAllMessages(
                                  receiverId: (userModel.uId)!,
                              ).then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Chat deleted successfully'),
                                ));
                              });
                              Navigator.pop(context);
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
                  leading: const Icon(
                    IconBroken.Delete,
                    color: Colors.red,
                    size: 30,
                  ),
                  title: const Text(
                    'Delete chat',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_cubit.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_states.dart';
import 'package:social_vape/presentation_layer/widgets/shimmer.dart';

import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../components/constans.dart';
import '../../../data_layer/models/user_model.dart';
import 'chat_details_screen.dart';


class ChatsScreen extends StatelessWidget {
   ChatsScreen({Key? key}) : super(key: key);

  late UserModel userModelChat ;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ChatCubit>(context),
      child: BlocConsumer<ChatCubit,ChatStates>(
        listener: (context,state){},
        builder: (context,state){
          return Scaffold(
            appBar: AppBar(
              title: const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  'Chats',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
              titleSpacing: 30,
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').doc(myUid).collection('following').snapshots(),
                    builder: (context,snapshot){
                      if(!snapshot.hasData){
                        return  Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            height: 110,
                            child: ListView.separated(
                              itemBuilder: (context,index) {
                                return buildChatHeadShimmer(context);
                              },
                              separatorBuilder: (context,index) =>
                              const SizedBox(
                                width: 8,
                              ),
                              itemCount: 10,
                              scrollDirection: Axis.horizontal,
                            ),
                          ),
                        );
                      }
                      if((snapshot.data?.docs.isEmpty)!){
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 110,
                          child: ListView.separated(
                            itemBuilder: (context,index) {
                              UserModel userModel = UserModel.fromJson((snapshot.data?.docs[index].data())!);
                              userModelChat = userModel;
                              return buildChatHead(
                                  userModel: userModel,
                                  context: context
                              );
                            },
                            separatorBuilder: (context,index) =>const SizedBox(
                              width: 8,
                            ),
                            itemCount: (snapshot.data?.docs.length)??0,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                      );
                    },
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(myUid)
                        .collection('chats')
                        .where('lastMessageDatetime',isNull: false)
                        .orderBy('lastMessageDatetime',descending: true)
                        .snapshots(),
                    builder: (context,snapshot){
                      if(!snapshot.hasData){
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView.separated(
                            itemBuilder: (context,index) {
                              return buildChatItemShimmer(context);
                            },
                            separatorBuilder: (context,index) =>const SizedBox(
                              height: 14,
                            ),
                            itemCount: 10,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                          ),
                        );
                      }
                      if((snapshot.data?.docs.isEmpty)!){
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView.separated(
                          itemBuilder: (context,index) {
                            DateTime myDateTime = (snapshot.data?.docs[index].data()['lastMessageDatetime']??Timestamp.now()).toDate();
                            String lastMessageTimeText(){
                              if(myDateTime.year == Timestamp.now().toDate().year && myDateTime.month == Timestamp.now().toDate().month && myDateTime.day == Timestamp.now().toDate().day){
                                return DateFormat('jm').format(myDateTime) ;
                              }
                              if(myDateTime.year == Timestamp.now().toDate().year && myDateTime.month == Timestamp.now().toDate().month && myDateTime.day == Timestamp.now().toDate().day -1 ){
                                return 'Yesterday' ;
                              }
                              return DateFormat('yMd').format(myDateTime) ;
                            }
                            return buildChatItem(
                                snapshot : snapshot.data!.docs[index].data(),
                                context: context,
                                lastMessageTimeText: lastMessageTimeText()
                            );
                          },
                          separatorBuilder: (context,index) =>const SizedBox(
                            height: 14,
                          ),
                          itemCount: snapshot.data!.docs.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildChatHead({
  required UserModel userModel,
  required BuildContext context,
}) => InkWell(
  onTap: (){
    SocialCubit.get(context).getUserDataWithUid(userModel.uId!).then((value) {
      SocialCubit.get(context).chatUserUid = userModel.uId! ;
      Navigator.push(context, MaterialPageRoute(
        builder: (context)=> ChatsDetailsScreen(userModel: value!),
      ),
      ).then((v) {
        ChatCubit.get(context).clearSelectedMessages();
        SocialCubit.get(context).chatUserUid = null ;
        ChatCubit.get(context).clearReplyMessage();
        ChatCubit.get(context).chatTyping(
            receiverId: value!.uId!,
            isMessageSent: true
        );
      });
    });
  },
  child: StreamBuilder(
    stream: FirebaseFirestore.instance.collection('users').doc(userModel.uId).snapshots(),
    builder: (context, userData) {
      if(!userData.hasData){
        return const SizedBox();
      }
      return SizedBox(
        width: 74,
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Theme.of(context).highlightColor,
                  backgroundImage: NetworkImage('${userData.data?.data()!['image']}'),
                ),
                if(userData.data?.data()!['online']??false)
                CircleAvatar(
                  radius: 8.3,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                if(userData.data?.data()!['online']??false)
                const CircleAvatar(
                  radius: 7,
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(
                height:6
            ),
            Text(
              '${userData.data?.data()!['name']}',
              textAlign: TextAlign.center,
              softWrap: true,
              style:  TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  ),
);


  Widget buildChatItem({
  required var snapshot,
  required BuildContext context,
    required String lastMessageTimeText,

}) => InkWell(
  onTap: ()  {
    SocialCubit.get(context).getUserDataWithUid(snapshot['uId']).then((value) {
      SocialCubit.get(context).chatUserUid = snapshot['uId'] ;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatsDetailsScreen(userModel: value!),
      ),
      ).then((v) {
        ChatCubit.get(context).clearSelectedMessages();
        SocialCubit.get(context).chatUserUid = null ;
        ChatCubit.get(context).clearReplyMessage();
        ChatCubit.get(context).chatTyping(
            receiverId: value!.uId!,
            isMessageSent: true
        );
      });
    });
  },
  child: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(snapshot['uId']).snapshots(),
      builder: (context, userData) {
        if(!userData.hasData){
          return const SizedBox();
        }
        return Row(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Hero(
                  tag: '${snapshot['uId']}+chat',
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: Theme.of(context).highlightColor,
                    backgroundImage: NetworkImage('${userData.data?.data()!['image']}'),
                  ),
                ),
                if(userData.data?.data()!['online']??false)
                  CircleAvatar(
                    radius: 8.3,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                if(userData.data?.data()!['online']??false)
                  const CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.green,
                  ),
              ],
            ),
            const SizedBox(
              width: 13,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${userData.data?.data()!['name']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${snapshot['lastMessage']}',
                          style: TextStyle(
                              color: !snapshot['isSeen'] ? Theme.of(context).secondaryHeaderColor : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: !snapshot['isSeen'] ? FontWeight.w600 : null
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if(!snapshot['isSeen'])
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          lastMessageTimeText,
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                          ),

                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }
  ),
);


  Widget buildChatHeadShimmer(context) => SizedBox(
     width: 74,
     child: Column(
       children: [
         const MyShimmer(
           radius: 35,
         ),
         const SizedBox(
             height:6
         ),
         MyShimmer(
           height: 6,
           width: MediaQuery.of(context).size.width*0.15,
         ),
         const SizedBox(
           height: 5,
         ),
         MyShimmer(
           height: 6,
           width: MediaQuery.of(context).size.width*0.10,
         ),
       ],
     ),
   );

  Widget buildChatItemShimmer(context) => Row(
    children: [
      const MyShimmer(
        radius: 34,
      ),
      const SizedBox(
        width: 13,
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyShimmer(
              height: 7,
              width: MediaQuery.of(context).size.width * 0.30,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyShimmer(
                  height: 7,
                  width: MediaQuery.of(context).size.width * 0.35,
                ),
                MyShimmer(
                  height: 7,
                  width: MediaQuery.of(context).size.width * 0.10,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

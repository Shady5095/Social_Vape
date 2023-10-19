import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_cubit.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_states.dart';

import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../data_layer/models/message_model.dart';
import '../../../styles/icon_broken.dart';
import '../../widgets/image_viewer.dart';

class MessageImagesScreen extends StatelessWidget {

  final MessageModel messageModel ;
  final String senderName ;


  MessageImagesScreen({
    required this.messageModel,
    required this.senderName
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit,ChatStates>(
      listener: (context,state){},
      builder: (context,state){
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            leadingWidth: double.infinity,
            leading: Row(
              children: [
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                      IconBroken.Arrow___Left_2
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      messageModel.senderId == myUid ? '${ChatCubit.get(context).userModel!.name}' : senderName,
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${messageModel.messageImages!.length} photos',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          DateFormat('yMMMMd').format((messageModel.dateTime??Timestamp.now()).toDate()),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: ListView.separated(
            physics: const BouncingScrollPhysics(),
              itemBuilder: (context,index){
                return InkWell(
                    onTap: (){
                      navigateToAnimated(
                        context: context,
                        widget: ImageViewer(
                            photosList: messageModel.messageImages,
                          photosListIndex: index,
                        )
                      );
                    },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.network(
                        '${messageModel.messageImages![index]}'
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0 ,vertical: 7),
                        child: Text(
                          DateFormat('jm').format((messageModel.dateTime??Timestamp.now()).toDate()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context,index)=>const SizedBox(
                height: 10,
              ),
              itemCount: messageModel.messageImages!.length
          ),
        );
      },
    );
  }
}

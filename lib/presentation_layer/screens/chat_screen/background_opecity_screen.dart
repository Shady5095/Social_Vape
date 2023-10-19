import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_cubit.dart';

import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';

class BackGroundOpacityScreen extends StatefulWidget {
  File backgroundImage ;
  String receiverId ;

  BackGroundOpacityScreen({
    required this.backgroundImage,
    required this.receiverId
  });

  @override
  State<BackGroundOpacityScreen> createState() => _BackGroundOpacityScreenState();
}

class _BackGroundOpacityScreenState extends State<BackGroundOpacityScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        var chatCubit = ChatCubit.get(context);
        return Scaffold(
          appBar: deafaultAppBar(
            context: context,
            title: '',
            actions: [
              TextButton(
                  onPressed: (){
                    chatCubit.uploadChatBackgroundImage(receiverId: widget.receiverId).then((value) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                        color: Colors.purple,
                        fontSize: 19
                    ),
                  )
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Image(
                    fit: BoxFit.cover,
                    opacity:  AlwaysStoppedAnimation((chatCubit.chatBackgroundImageOpacity??100)/100),
                    image: FileImage(
                      widget.backgroundImage,
                    )),
              ),
              if(state is CoverImageUploadLoadingState)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  color: Colors.purple,
                  backgroundColor: Color.fromARGB(255, 35, 34, 34),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Slider(
                    value: chatCubit.chatBackgroundImageOpacity??100,
                    min: 0,
                    max: 100,
                    onChanged: (value){
                      setState(() {
                        chatCubit.chatBackgroundImageOpacity = value ;
                      });
                    }
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

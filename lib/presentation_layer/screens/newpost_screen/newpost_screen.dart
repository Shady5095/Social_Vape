import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../styles/icon_broken.dart';

class NewPostScreen extends StatelessWidget {

  final postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){
        if(state is CreatePostSuccessState){
          Navigator.pop(context);
        }
      },
      builder: (context,state){
        var cubit = SocialCubit.get(context);
        return Scaffold(
          appBar: deafaultAppBar(
              context: context,
              title: 'Create Post',
              actions: [
                TextButton(
                    onPressed: (){
                      if(postController.text.isNotEmpty ||cubit.postImagePicker.isNotEmpty) {
                        cubit.createPost(
                          dateTime: myDateTime().toString(),
                          text: postController.text,
                        );
                      }
                      else {
                        null ;
                      }
                    },
                    child: const Text(
                      'Post',
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 19
                      ),
                    )
                ),
                const SizedBox(
                  width: 15,
                ),
              ]
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                if(state is CreatePostLoadingState)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: LinearProgressIndicator(
                    backgroundColor: Color.fromARGB(255, 35, 34, 34),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                        radius: 25,
                        backgroundColor: Theme.of(context).highlightColor,
                        backgroundImage: NetworkImage(
                            '${cubit.userModel?.image}'
                        )
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cubit.userModel?.name}',
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontSize: 20,
                                height: 1.3
                            ),
                          ),
                          const Text(
                            'Public',
                            style: TextStyle(
                                color: Color.fromARGB(255, 128, 123, 123),
                                fontSize: 15,
                                height: 1.3
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: TextFormField(
                    controller: postController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder:InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 20,
                        height: 1,
                      ),
                      hintText: 'What\'s on your mind ?',
                    ),

                  ),
                ),
                if(cubit.postImagePicker.isNotEmpty)
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                      itemBuilder:(context,index)=> selectedPhotos(cubit.postImagePicker[index],index,cubit),
                      separatorBuilder: (context,index)=>const SizedBox(
                        width: 7,
                      ),
                      itemCount: cubit.postImagePicker.length
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          cubit.pickPostImage();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              IconBroken.Image,
                              color: Colors.green,
                              size: 35,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Photo',
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 20
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget selectedPhotos(XFile? postPhoto,int index,SocialCubit cubit) =>
      Stack(
        alignment: Alignment.topRight,
        children: [
          InkWell(
            onTap: (){
              cubit.editPostPhoto(postPhoto?.path, index);
            },
            child: SizedBox(
              width: 160,
              height: 160,
              child: Image(
                image: FileImage(File((postPhoto?.path)!)),
                fit: BoxFit.cover,
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
              onTap: (){
                cubit.removePostPhotoFromList(index);
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
        ],
      );
}

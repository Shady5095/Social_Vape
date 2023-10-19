
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../data_layer/models/post_model.dart';


class EditPostScreen extends StatelessWidget {

  final postController = TextEditingController();
  final PostModel? postModel ;
  final List<dynamic> postImagesNameInStorage =[];

  EditPostScreen(this.postModel);

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
        postController.text = (postModel?.text)!;

        List<dynamic>? postImages = (postModel?.postImages);
        return Scaffold(
          appBar: deafaultAppBar(
              context: context,
              title: 'Edit Post',
              actions: [
                TextButton(
                    onPressed: (){
                      cubit.editPost(
                        context: context,
                          postId: postModel?.postId,
                        text: postController.text,
                        postImages: postImages,
                        postImagesNameInStorage: postModel?.postImagesNameInStorage
                      );
                      cubit.deletePhotoFromStorage(postImagesNameInStorage: postImagesNameInStorage);
                     },
                    child: const Text(
                      'Update',
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
                        backgroundColor: Colors.grey[800],
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
                if((postModel?.postImages?.isNotEmpty)!)
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                      key: const Key('removeIndex'),
                      itemBuilder:(context,index)=> selectedPhotos(postModel?.postImages![index],index,cubit,postImages,postImagesNameInStorage),
                      separatorBuilder: (context,index)=>const SizedBox(
                        width: 7,
                      ),
                      itemCount: (postModel?.postImages?.length)!
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget selectedPhotos(String image , int index,SocialCubit cubit,List<dynamic>? postImages,List<dynamic> postImagesNameInStorage) =>
      Stack(
        alignment: Alignment.topRight,
        children: [
          InkWell(
            onTap: (){
            },
            child: SizedBox(
              width: 160,
              height: 160,
              child: Image(
                image: NetworkImage(
                  image,
                ),
                fit: BoxFit.cover,
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
              onTap: (){
                postImagesNameInStorage.add(postModel?.postImagesNameInStorage![index]) ;
                if (kDebugMode) {
                  print(postImagesNameInStorage);
                }
                postImages?.removeAt(index);
                postModel?.postImagesNameInStorage?.removeAt(index);
                if (kDebugMode) {
                  print(postModel?.postImagesNameInStorage);
                }
              },
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.close,
                  size: 16,

                ),
              ),
            ),
          ),
        ],
      );
}

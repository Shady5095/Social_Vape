import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:social_vape/presentation_layer/screens/post_card/replays_screen.dart';
import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../data_layer/models/comment_model.dart';
import '../../../styles/icon_broken.dart';
import '../user_profile_screen/user_profile_screen.dart';

class CommentsScreen extends StatelessWidget {

  final String? postId ;
  final commentController = TextEditingController();
  bool isUpdateComment =false ;
  String? commentIdToEdit ;

  var commentTextFocusNode = FocusNode();
  CommentsScreen(this.postId, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context, state){},
      builder: (context, state){
        return Scaffold(
          appBar: deafaultAppBar(
              context: context,
            title: 'Comments',
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore
                      .instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
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
                              'No comments yet...',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context,index) {
                          CommentModel commentModel = CommentModel.fromJson((snapshot.data?.docs[index].data())!);

                          return buildCommentItem(
                          context: context,
                          commentModel: commentModel,
                        );
                        },
                        separatorBuilder: (context,index) => const SizedBox(height: 0,),
                        itemCount: (snapshot.data?.docs.length)!
                    );
                  },
                ),
              ),
              Column(
                children: [
                  if(SocialCubit.get(context).commentImagePicker != null)
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
                              image: FileImage((SocialCubit.get(context).commentImagePicker)!),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: InkWell(
                          onTap: (){
                            SocialCubit.get(context).removeCommentImage();
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
                  ),
                  if(state is CreatePostLoadingState)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 8.0),
                      child: LinearProgressIndicator(
                        backgroundColor: Color.fromARGB(255, 35, 34, 34),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            focusNode: commentTextFocusNode,
                            controller: commentController,
                            maxLines: null,
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(9),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:  BorderSide(
                                      color: Theme.of(context).secondaryHeaderColor
                                  )
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                                height: 0.8,
                              ),
                              hintText: 'Write a comment',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),

                              ),
                            ),
                          ),
                        ),
                         IconButton(
                          onPressed: (){
                            SocialCubit.get(context).pickCommentImage();
                          },
                          splashColor: Colors.transparent,
                          icon: const Icon(
                            IconBroken.Image,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                         IconButton(
                          onPressed: (){
                            if (commentController.text.isNotEmpty ||SocialCubit.get(context).commentImagePicker != null)
                            {
                              if(isUpdateComment)
                              {
                                SocialCubit.get(context).editComment(
                                    postId: postId!,
                                    commentId: commentIdToEdit!,
                                    text: commentController.text
                                );
                                commentController.text = '' ;
                                FocusManager.instance.primaryFocus?.unfocus();
                                isUpdateComment = false ;
                                commentIdToEdit = '' ;
                              }
                              else {
                                SocialCubit.get(context).commentPost(
                                  text: commentController.text,
                                  postId: postId!,
                                  dateTime: DateTime.now().toString(),
                                );
                                commentController.text = '' ;
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            }
                          },
                          splashColor: Colors.transparent,
                          icon: const Icon(
                            IconBroken.Send,
                            color: Colors.purple,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  Widget buildCommentItem({
  required BuildContext context,
    required CommentModel commentModel,
})=>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 12),
        child: InkWell(
          onLongPress: (){
            if(commentModel.uId == myUid){
              showModalBottomSheet(context: context,
                builder: (context)=> myBottomSheet(
                    context: context,
                    items: [
                      firstBottomSheetItem(),
                      bottomSheetItem(
                          onTap: (){
                            commentController.text = commentModel.text! ;
                            Navigator.pop(context);
                            commentIdToEdit = commentModel.commentId ;
                            commentTextFocusNode.requestFocus();
                            isUpdateComment = true ;
                          },
                          icon: Icon(
                            IconBroken.Edit,
                            color: Theme.of(context).secondaryHeaderColor,
                            size: 30,
                          ),
                          title: 'Edit',
                          titleColor: Theme.of(context).secondaryHeaderColor,
                      ),
                      bottomSheetItem(
                          onTap: (){
                            SocialCubit.get(context).deleteComment(
                                postId: postId!,
                                commentId: (commentModel.commentId)!,
                                commentImageNameInStorage: (commentModel.commentImageNameInStorage)!
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Comment deleted successfully'),
                            ));
                          },
                          icon: const Icon(
                            IconBroken.Delete,
                            color: Colors.red,
                            size: 30,
                          ),
                          title: 'Delete',
                          titleColor: Colors.red
                      ),

                    ]
                ),
              );
            }
          },
          splashColor: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: (){
                  if(commentModel.uId != myUid){
                    navigateToAnimated(
                      context: context,
                      animation: PageTransitionType.leftToRight,
                      widget: UserProfileScreen(
                        userUid: (commentModel.uId)!,
                        userName: (commentModel.name)!,
                      ),
                    );
                  }
                  else
                  {
                    SocialCubit.get(context).changeBottomNav(3);
                    Navigator.pop(context);
                  }
                },
                child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).highlightColor,
                    backgroundImage: NetworkImage('${commentModel.image}')
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: (){
                                  if(commentModel.uId != myUid){
                                    navigateToAnimated(
                                      context: context,
                                      animation: PageTransitionType.leftToRight,
                                      widget: UserProfileScreen(
                                        userUid: (commentModel.uId)!,
                                        userName: (commentModel.name)!,
                                      ),
                                    );
                                  }
                                  else
                                  {
                                    SocialCubit.get(context).changeBottomNav(3);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  '${commentModel.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:  TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '${commentModel.text}',
                                style:  TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 20
                                ),
                              ),
                              if(commentModel.commentImage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0,right: 7,left: 7),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      '${commentModel.commentImage}',
                                      width: MediaQuery.of(context).size.width,
                                      height: 350,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                      child: Row(
                        children: [
                          Text(
                            myTimeAgo(context , DateTime.parse((commentModel.dateTime)!),full: false),
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          TextButton(
                              onPressed: (){
                                SocialCubit.get(context).likeComment(
                                    postId: postId!,
                                    commentId: (commentModel.commentId)!,
                                    likes: (commentModel.likes)!
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize:  const Size(40, 20),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Like',
                                style: TextStyle(
                                  color: (commentModel.likes?.contains(myUid))! ? Colors.red : Theme.of(context).secondaryHeaderColor,
                                ),
                              )
                          ),
                          TextButton(
                              onPressed: (){
                                navigateToAnimated(
                                  context: context,
                                  widget: ReplaysScreen(
                                      postId: postId,
                                      commentId: commentModel.commentId,
                                    commentModel: commentModel,
                                  ),
                                  animation: PageTransitionType.rightToLeft,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(40, 20),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child:  Text(
                                'Replay',
                                style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              )
                          ),
                          const Spacer(),
                          if((commentModel.likes?.isNotEmpty)!)
                            Row(
                              children: [
                                Text(
                                  '${commentModel.likes?.length}',
                                  style:  TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor
                                  ),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                const Icon(
                                  IconBroken.Heart,
                                  color: Colors.red,
                                  size: 22,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if(commentModel.noOfReplays != 0 && commentModel.noOfReplays != null)
                    TextButton(
                        onPressed: (){
                          navigateToAnimated(
                            context: context,
                            widget: ReplaysScreen(
                              postId: postId,
                              commentId: commentModel.commentId,
                              commentModel: commentModel,
                            ),
                            animation: PageTransitionType.rightToLeft,
                          );
                        },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 15,right: 25),
                        minimumSize:  const Size(40, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                        child: Text(
                          commentModel.noOfReplays == 1 ? 'View ${commentModel.noOfReplays} replay' : 'View ${commentModel.noOfReplays} replays',
                          style:  TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

}

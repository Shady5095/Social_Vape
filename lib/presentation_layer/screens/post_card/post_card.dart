import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:like_button/like_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../data_layer/local/cache_helper.dart';
import '../../../data_layer/models/post_model.dart';
import '../../../data_layer/models/user_model.dart';
import '../../../styles/icon_broken.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/like_animation.dart';
import '../edit_post_screen/edit_post_screen.dart';
import '../user_profile_screen/user_profile_screen.dart';
import 'comments_screen.dart';
import 'likes_screen.dart';

class PostCard extends StatefulWidget {
  final UserModel? userModel ;
  final dynamic snapshot;
  final int postNo;
  const PostCard({
    Key? key,
    this.userModel,
    required this.snapshot,
    required this.postNo,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isAnimating = false ;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        PostModel? postModel = PostModel.fromJson(widget.snapshot);
        Future<bool> onLikeChange(bool isLiked)  async {
          SocialCubit.get(context).likePost(
            postId: postModel.postId,
            uId: widget.userModel?.uId,
            likes: (postModel.likes)!,
          );
          return !isLiked;
        }
        return Card(
          color: Theme.of(context).primaryColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0 ,left: 10 ,top: 10),
                child: InkWell(
                  onTap: (){
                    if(postModel.uId != myUid){
                      navigateToAnimated(
                          widget: UserProfileScreen(
                            userUid: (postModel.uId)!,
                            userName: (postModel.name)!,
                          ),
                          context: context,
                          animation: PageTransitionType.rightToLeft
                      );
                    }
                    else
                    {
                      SocialCubit.get(context).changeBottomNav(3);
                    }
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Theme.of(context).highlightColor,
                        backgroundImage: CachedNetworkImageProvider(
                          '${postModel.image}',
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${postModel.name}',
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 20,
                                  height: 1.3
                              ),
                            ),
                            Text(
                              myTimeAgo(context , DateTime.parse((postModel.dateTime)!),full: false),
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 128, 123, 123),
                                  fontSize: 15,
                                  height: 1.3
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            showModalBottomSheet(context: context, builder: (context)=>FittedBox(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Center(
                                        child: Container(
                                          height: 5,
                                          width: 45,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[500],
                                              borderRadius: BorderRadius.circular(30)
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.grey[600],
                                      onTap: (){
                                        SocialCubit.get(context).savePost((postModel.postId)!, (postModel.savedBy)!);
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Row(
                                          children:  [
                                            Stack(
                                              alignment: AlignmentDirectional.center,
                                              children: [
                                                FaIcon(
                                                  IconBroken.Bookmark,
                                                  color: Theme.of(context).secondaryHeaderColor,
                                                ),
                                                if((postModel.savedBy?.contains(myUid))??false)
                                                  RotationTransition(
                                                    turns: const AlwaysStoppedAnimation(330 / 360),
                                                    child: Container(
                                                      height: 33,
                                                      width: 1,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).secondaryHeaderColor,

                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: Text(
                                                (postModel.savedBy?.contains(myUid))??false ? 'Unsave post' : 'Save post',
                                                style:  TextStyle(
                                                    color: Theme.of(context).secondaryHeaderColor,
                                                    fontSize: 20
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if(postModel.uId == myUid)
                                      InkWell(
                                        onTap: (){
                                          navigateToAnimated(
                                              context: context,
                                              widget: EditPostScreen(
                                                  postModel
                                              ),
                                              animation: PageTransitionType.fade
                                          );
                                        },
                                        child:  Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                IconBroken.Edit,
                                                color: Theme.of(context).secondaryHeaderColor,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Edit post',
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 20
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if(postModel.uId == myUid)
                                      InkWell(
                                        onTap: (){
                                          SocialCubit.get(context).
                                          deletePost(
                                              context: context,
                                              postId: (postModel.postId)!,
                                              postImagesNameInStorage: (postModel.postImagesNameInStorage)!
                                          ).then((value) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                              content: Text('Post deleted successfully'),
                                            ));
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(15.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                IconBroken.Delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Delete post',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 20
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ));

                          },
                          splashColor: Colors.transparent,
                          icon: Icon(
                            IconBroken.More_Circle,
                            color: Theme.of(context).secondaryHeaderColor,
                          )
                      ),
                    ],
                  ),
                ),
              ),
              if(postModel.text != '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: SelectableText(
                    '${postModel.text}',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 18
                    ),
                  ),
                ),
              if(postModel.text == '')
                const SizedBox(
                  height: 8,
                ),
              if((postModel.postImages?.isNotEmpty)!)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    InkWell(
                      onTap: (){
                        navigateToAnimated(
                          context: context,
                          widget: ImageViewer(
                            photosList: postModel.postImages,
                            photosListIndex: (CacheHelper.getInt(key: '${widget.postNo}')) != null ? (CacheHelper.getInt(key: '${widget.postNo}'))!-1 : 0,
                          ),
                        );
                      },
                      onDoubleTap: (){
                        if(!(postModel.likes?.contains(myUid))!){
                          onLikeChange((postModel.likes?.contains(myUid))! ? true : false);
                        }
                        setState(() {
                          isAnimating = true ;
                        });
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          CarouselSlider(
                            items: postModel.postImages?.map((e) =>
                                ClipRRect(
                                  child: FadeInImage(
                                    width: double.infinity,
                                    fadeInDuration: const Duration(milliseconds: 300),
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      e,
                                    ), placeholder: MemoryImage(kTransparentImage),
                                  ),
                                ),
                            ).toList(),
                            options: CarouselOptions(
                                initialPage: 0,
                                aspectRatio: 1/1,
                                enableInfiniteScroll: false,
                                enlargeCenterPage: false,
                                reverse: false,
                                viewportFraction: 1.0,
                                autoPlay: false,
                                scrollDirection: Axis.horizontal,
                                scrollPhysics: const BouncingScrollPhysics(),
                                onPageChanged: (index,reason){
                                  SocialCubit.get(context).changePostPhotoIndex(widget.postNo,index);
                                  CacheHelper.putData(key: '${widget.postNo}', value: SocialCubit.get(context).postPhotoIndex[widget.postNo]!) ;
                                }
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: isAnimating ? 1 : 0,
                            duration: const Duration(milliseconds: 600),
                            child: LikeAnimation(
                              isAnimating: isAnimating,
                              duration: const Duration(milliseconds: 800),
                              onEnd: (){
                                setState(() {
                                  isAnimating = false ;
                                });
                              },
                              child: const Icon(
                                Icons.favorite,
                                size: 120,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    if(postModel.postImages?.length != 1)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: 45,
                          height: 29,
                          decoration: BoxDecoration(
                            color: CupertinoColors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '${CacheHelper.getInt(key: '${widget.postNo}')??1}/${postModel.postImages?.length}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              if(postModel.postImages?.length != 1 && (postModel.postImages?.isNotEmpty)! )
                Center(
                  child: DotsIndicator(
                    decorator: DotsDecorator(
                      activeColor: Colors.purple,
                      color: (Colors.grey[700])!,
                      shape:  OvalBorder(
                          eccentricity: 0.9,
                          side: BorderSide(
                              width: 1,
                              color: Theme.of(context).primaryColor
                          )
                      ),
                      size: const Size.square(9.0),
                      activeSize: const Size(16.0, 9.0),
                      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    ),
                    dotsCount: (postModel.postImages?.length)!,
                    position: (CacheHelper.getInt(key: '${widget.postNo}')?.toDouble()) != null ? (CacheHelper.getInt(key: '${widget.postNo}')?.toDouble())!-1 : 0,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){},
                    onLongPress: (){
                      navigateToAnimated(
                        context: context,
                        widget: LikesScreen(
                          postModel.postId,
                        ),
                        animation: PageTransitionType.fade,
                      );
                    },
                    splashColor: Colors.transparent,
                    child: Row(
                      children: [
                        LikeButton(
                          size: 35,
                          padding: const EdgeInsets.all(10),
                          onTap: onLikeChange,
                          isLiked: (postModel.likes?.contains(myUid))! ? true : false,
                          circleColor:
                          const CircleColor(start: Color(0xffe3266a), end: Color(
                              0xfff15414)),
                          bubblesColor: const BubblesColor(
                            dotPrimaryColor: Color(0xfffd059c),
                            dotSecondaryColor: Color(0xff07ffa3),
                          ),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              IconBroken.Heart,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 35,
                            );
                          },
                          likeCount: postModel.likes?.length??0,
                          countBuilder: (int? count, bool isLiked, String text) {
                            var color = isLiked ? Colors.red : Colors.grey;
                            Widget result;
                            if (count == 0) {
                              result = Text(
                                "Like",
                                style: TextStyle(color: color),
                              );
                            } else {
                              result = Text(
                                text,
                                style: TextStyle(color: color),
                              );
                            }
                            return result;
                          },
                        ),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: (){
                        navigateToAnimated(
                            context: context,
                            widget: CommentsScreen(
                              postModel.postId,
                            ),
                            animation: PageTransitionType.bottomToTop
                        );
                      },
                      splashColor: Colors.transparent,
                      child: Row(
                        children: [
                          const Icon(
                            IconBroken.Chat,
                            color: Colors.amber,
                            size: 35,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${postModel.noOfComments??0}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 128, 123, 123),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: (){
                  navigateToAnimated(
                      context: context,
                      widget: CommentsScreen(
                        postModel.postId,
                      ),
                      animation: PageTransitionType.bottomToTop
                  );
                },
                splashColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 15),
                  child: Row(
                    children: [
                      CircleAvatar(
                          radius: 17,
                          backgroundColor: Theme.of(context).highlightColor,
                          backgroundImage: NetworkImage('${widget.userModel?.image}')
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          'Write a comment...',
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

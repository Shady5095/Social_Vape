import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../data_layer/models/user_model.dart';
import '../../../styles/icon_broken.dart';
import '../../widgets/image_viewer.dart';
import '../chat_screen/chat_details_screen.dart';
import '../my_profile_screen/following_followers.dart';
import '../post_card/post_card.dart';

class UserProfileScreen extends StatelessWidget {

  final String userUid ;
  final String userName ;
  const UserProfileScreen({
    Key? key,
    required this.userUid,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SocialCubit.get(context).clearPostIndex();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName,
          style: const TextStyle(
            fontSize: 25,
          ),
        ),
        leading:IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(
              IconBroken.Arrow___Left_2,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        titleSpacing: 5,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(userUid).snapshots(),
              builder: (context,snapshot){
                if(snapshot.hasError){
                  return const Icon(
                    Icons.warning_amber,
                    color: Colors.red,
                    size: 100,
                  );
                }
                if(!snapshot.hasData){
                  return const Center(child: CircularProgressIndicator(color: Colors.transparent,));
                }
                if(snapshot.hasData){
                  UserModel profileModel = UserModel.fromJson((snapshot.data?.data())!);
                  return Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 260,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: (){
                                  navigateToAnimated(
                                      context: context,
                                      widget: ImageViewer(
                                          photo: NetworkImage('${profileModel.coverImage}')
                                      ),
                                      animation: PageTransitionType.fade
                                  );
                                },
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      '${profileModel.coverImage}',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              radius: 74,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: (){
                                  navigateToAnimated(
                                      context: context,
                                      widget: ImageViewer(
                                        photo:
                                        CachedNetworkImageProvider(
                                          '${profileModel.image}',
                                        ),
                                      ),
                                      animation: PageTransitionType.fade
                                  );
                                },
                                child: Hero(
                                  tag: '$userUid+profile',
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Theme.of(context).highlightColor,
                                    backgroundImage: NetworkImage('${profileModel.image}'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${profileModel.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontSize: 30
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if(profileModel.bio != 'Write your bio here...')
                      Text(
                        '${profileModel.bio}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${profileModel.posts}',
                                  style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'Posts',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                navigateToAnimated(
                                    context: context,
                                    widget: FollowingFollowersScreen(
                                      isFollowers: true,
                                      uId: userUid,
                                    ),
                                    animation: PageTransitionType.rightToLeft
                                );
                              },
                              child: Column(
                                children: [
                                  Text(
                                    '${profileModel.followers?.length}',
                                    style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Followers',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                navigateToAnimated(
                                    context: context,
                                    widget: FollowingFollowersScreen(
                                      isFollowers: false,
                                      uId: userUid,
                                    ),
                                    animation: PageTransitionType.rightToLeft
                                );
                              },
                              child: Column(
                                children: [
                                  Text(
                                    '${profileModel.following?.length}',
                                    style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Following',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child:  Row(
                          children: [
                            Expanded(
                              child: deafultButton(
                                  fun: (){
                                    SocialCubit.get(context).followUser(
                                      userId: (profileModel.uId)!,
                                      userFollowersList: (profileModel.followers)!,
                                      userName: (profileModel.name)!,
                                      userImage: (profileModel.image)!,
                                    );
                                  },
                                  text: (profileModel.followers?.contains(myUid))! ? 'Following' : 'Follow',
                                  width: double.infinity,
                                  height: 45,
                                  textColor: (profileModel.followers?.contains(myUid))! ? Theme.of(context).secondaryHeaderColor : Colors.white,
                                  fontSize: 15,
                                  decoration: BoxDecoration(
                                      color: (profileModel.followers?.contains(myUid))! ? Theme.of(context).highlightColor : Colors.purple,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  isUppercase: false
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap : (){
                                navigateToAnimated(
                                  context: context,
                                  widget: ChatsDetailsScreen(userModel: profileModel),
                                  animation: PageTransitionType.rightToLeft,
                                );
                              },
                              child: Container(
                                width: 60,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                   borderRadius: BorderRadius.circular(20)
                                ),
                                child: const Icon(
                                  IconBroken.Chat,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator(color: Colors.transparent,));
              },
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('posts').where('uId',isEqualTo: userUid).orderBy('dateTime',descending: true).snapshots(),
              builder: (context,snapshot){
                if(snapshot.hasError){
                  return const Icon(
                    Icons.warning_amber,
                    color: Colors.red,
                    size: 100,
                  );
                }
                if(!snapshot.hasData){
                  return const Center(child: CircularProgressIndicator(color: Colors.transparent,));
                }
                return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context,index) => PostCard(
                      userModel: SocialCubit.get(context).userModel,
                      snapshot: snapshot.data?.docs[index].data(),
                      postNo: index,
                    ),
                    separatorBuilder: (context,index) =>const SizedBox(height: 10,),
                    itemCount: (snapshot.data?.docs.length)!
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

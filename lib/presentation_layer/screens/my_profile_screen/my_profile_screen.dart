import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../data_layer/local/cache_helper.dart';
import '../../../data_layer/models/user_model.dart';
import '../../../styles/icon_broken.dart';
import '../../widgets/image_viewer.dart';
import '../dark_mode_screen/dark_mode_screen.dart';
import '../login_screen/login_screen.dart';
import '../newpost_screen/newpost_screen.dart';
import '../../widgets/post_card_shimmer.dart';
import '../post_card/post_card.dart';
import '../saved_posts_screen/saved_posts_screen.dart';
import 'following_followers.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        var userModel = SocialCubit.get(context).userModel;
        return ConditionalBuilder(
          condition: userModel != null,
          builder: (context)=> Scaffold(
            appBar: AppBar(
              title: Text(
                '${userModel?.name}',
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: (){
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
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: InkWell(
                                onTap: (){
                                  navigateToAnimated(
                                      context: context,
                                      widget: const SavedPostsScreen(),
                                      animation: PageTransitionType.leftToRightWithFade
                                  );
                                },
                                child: Row(
                                  children:  [
                                    Icon(
                                      IconBroken.Bookmark,
                                      color: Theme.of(context).secondaryHeaderColor,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Saved posts',
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
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: InkWell(
                                onTap: (){
                                  navigateToAnimated(
                                      context: context,
                                      widget: const DarkModeScreen(),
                                      animation: PageTransitionType.leftToRightWithFade
                                  );
                                },
                                child: Row(
                                  children:  [
                                    Icon(
                                      Icons.dark_mode_outlined,
                                      color: Theme.of(context).secondaryHeaderColor,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Dark mode',
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
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: InkWell(
                                onTap: () async {
                                  FirebaseAuth.instance.signOut();
                                  await FirebaseMessaging.instance.unsubscribeFromTopic('$myUid');
                                  SocialCubit.get(context).userOnlineStatus(false);
                                  SocialCubit.get(context).userLastSeen();
                                  CacheHelper.removeData(
                                      key: 'uId'
                                  )?.then((value) {
                                    if (value) {
                                      Navigator.pushReplacement(context, PageTransition(
                                          type: PageTransitionType.rightToLeftWithFade,
                                          child: LoginScreen(),
                                          duration: const Duration(milliseconds: 500)
                                      ),
                                      );
                                    }
                                  });
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      IconBroken.Logout,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Logout',
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
                          ],
                        ),
                      ),
                    ));
                  },
                  icon: const Icon(
                      IconBroken.More_Circle
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
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
                        UserModel userModel = UserModel.fromJson((snapshot.data?.data())!);
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
                                                photo: NetworkImage('${userModel.coverImage}')
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
                                            '${userModel.coverImage}',
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
                                                '${userModel.image}',
                                              ),
                                            ),
                                            animation: PageTransitionType.fade
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 70,
                                        backgroundColor: Theme.of(context).highlightColor,
                                        backgroundImage: NetworkImage('${userModel.image}'),
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
                              '${userModel.name}',
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
                            Text(
                              '${userModel.bio}',
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
                                        '${userModel.posts}',
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
                                          uId: myUid,
                                        ),
                                        animation: PageTransitionType.rightToLeft
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          '${userModel.followers?.length}',
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
                                            uId: myUid,
                                          ),
                                          animation: PageTransitionType.rightToLeft
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          '${userModel.following?.length}',
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
                              child: Row(
                                children: [
                                  Expanded(
                                    child: deafultButton(
                                        fun: (){
                                          navigateToAnimated(
                                              context: context,
                                              widget: NewPostScreen(),
                                              animation: PageTransitionType.fade
                                          );
                                        },
                                        text: 'Add post',
                                        width: double.infinity,
                                        height: 40,
                                        textColor: Theme.of(context).secondaryHeaderColor,
                                        fontSize: 17,
                                        decoration: BoxDecoration(
                                            color:  Theme.of(context).highlightColor,
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        isUppercase: false
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: deafultButton(
                                        fun: (){
                                          Navigator.pushNamed(context, 'EditProfile');
                                        },
                                        text: 'Edit profile',
                                        width: double.infinity,
                                        height: 40,
                                        textColor: Theme.of(context).secondaryHeaderColor,
                                        fontSize: 17,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).highlightColor,
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        isUppercase: false
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
                    stream: FirebaseFirestore.instance.collection('posts').where('uId',isEqualTo: myUid).orderBy('dateTime',descending: true).snapshots(),
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
                            userModel: userModel!,
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
          ),
          fallback: (context)=> const Center(child: CircularProgressIndicator(color: Colors.purple,)),
        );
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/app_locale.dart';
import '../../../components/components.dart';
import '../../../styles/icon_broken.dart';
import '../newpost_screen/newpost_screen.dart';
import '../../widgets/post_card_shimmer.dart';
import '../post_card/post_card.dart';
import '../search_screen/search_screen.dart';

class FeedsScreen extends StatelessWidget {
  const FeedsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state) {},
      builder: (context,state) {
        var userModel = SocialCubit.get(context).userModel;
        return Scaffold(
          body: ConditionalBuilder(
            condition: SocialCubit.get(context).userModel != null,
            builder: (context) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  title: const Text(
                    'Social Vape',
                    style: TextStyle(
                      fontFamily: 'Dancing',
                      fontSize: 28,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: (){
                        navigateToAnimated(
                          widget: const SearchScreen(),
                          context: context,
                          animation: PageTransitionType.topToBottom
                        );
                      },
                      icon: const Icon(
                          IconBroken.Search
                      ),
                    ),
                  ],
                  floating: true,
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0 , right: 10 , top: 10),
                              child: Row(
                                children: [
                                  InkWell(
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Theme.of(context).highlightColor,
                                      backgroundImage: CachedNetworkImageProvider(
                                        '${userModel?.image}',
                                      ),
                                    ),
                                    onTap: (){
                                      SocialCubit.get(context).changeBottomNav(3);
                                    },
                                  ),
                                  const SizedBox(
                                    width:10,
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 40,
                                      child: TextFormField(
                                        readOnly: true,
                                        onTap: (){
                                          navigateToAnimated(
                                              context: context,
                                              widget: NewPostScreen(),
                                              animation: PageTransitionType.fade
                                          );
                                        },
                                        style: TextStyle(
                                            color: Theme.of(context).secondaryHeaderColor
                                        ),
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              borderSide:  BorderSide(
                                                  color: Theme.of(context).secondaryHeaderColor,
                                              )
                                          ),
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 15,
                                            height: 0.8,
                                          ),
                                          hintText: '${getLang(context, 'Whats on your mind ?')}',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),

                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: (){
                                      navigateToAnimated(
                                          context: context,
                                          widget: NewPostScreen(),
                                          animation: PageTransitionType.fade
                                      );
                                      SocialCubit.get(context).pickPostImage();
                                    },
                                    icon: const Icon(
                                      IconBroken.Image,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('posts').orderBy('dateTime',descending: true).snapshots(),
                              builder: (context,snapshot){
                                SocialCubit.get(context).postsLength = (snapshot.data?.docs.length) ?? 0 ;
                                if(snapshot.hasError){
                                  return const Icon(
                                    Icons.warning_amber,
                                    color: Colors.red,
                                    size: 100,
                                  );
                                }
                                if(!snapshot.hasData){
                                  return ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context,index) => const PostCardShimmer(),
                                      separatorBuilder: (context,index) => Container(
                                        height: 7,
                                        color: Theme.of(context).highlightColor,
                                      ),
                                      itemCount: 15
                                  );
                                }
                                return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context,index) => PostCard(
                                      userModel: userModel!,
                                      snapshot: snapshot.data?.docs[index].data(),
                                      postNo: index,
                                    ),
                                    separatorBuilder: (context,index) => Container(
                                      height: 7,
                                      color: Theme.of(context).highlightColor,
                                    ),
                                    itemCount: (snapshot.data?.docs.length)!
                                );
                              },
                            ),
                          ],
                        ),
                      ]
                    )
                )
              ],
            ),
            fallback: (context) => const Center(child: CircularProgressIndicator(color: Colors.purple,)),
          ),
        );
      },
    );
  }


}

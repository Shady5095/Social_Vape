import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../styles/icon_broken.dart';
import '../user_profile_screen/user_profile_screen.dart';

class LikesScreen extends StatelessWidget {
  final String? postId;

  LikesScreen(this.postId);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: deafaultAppBar(
            context: context,
            title: 'Likes',
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .collection('likes')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Icon(
                    Icons.warning_amber,
                    color: Colors.red,
                    size: 100,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.purple,
                ));
              }
              if ((snapshot.data?.docs.isEmpty)!) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        IconBroken.Heart,
                        size: 150,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'No likes yet...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) => likesBy(
                      context: context,
                      snap: snapshot.data?.docs[index].data()),
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                  itemCount: (snapshot.data?.docs.length)!);
            },
          ),
        );
      },
    );
  }

  Widget likesBy({
    required BuildContext context,
    required snap,
  }) =>
      InkWell(
        onTap: () {
          if (snap['uId'] != myUid) {
            navigateToAnimated(
              context: context,
              animation: PageTransitionType.rightToLeft,
              widget: UserProfileScreen(
                userUid: snap['uId'],
                userName: snap['name'],
              ),
            );
          } else {
            SocialCubit.get(context).changeBottomNav(3);
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).highlightColor,
                backgroundImage: NetworkImage(snap['image']),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snap['name'],
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 20,
                          height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

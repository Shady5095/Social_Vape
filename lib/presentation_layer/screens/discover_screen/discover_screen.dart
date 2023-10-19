import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_vape/presentation_layer/widgets/shimmer.dart';

import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../data_layer/models/user_model.dart';
import '../user_profile_screen/user_profile_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Discover People',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('uId', isNotEqualTo: myUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return usersShimmer(context);
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                            height: 10,
                          ),
                      itemCount: 12
                  );
                }
                return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      UserModel userModel = UserModel.fromJson(
                          (snapshot.data?.docs[index].data())!);
                      return users(context: context, userModel: userModel);
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 10,
                        ),
                    itemCount: (snapshot.data?.docs.length)!);
              },
            ),
          ),
        );
      },
    );
  }

  Widget users({
    required BuildContext context,
    required UserModel userModel,
  }) =>
      InkWell(
        onTap: () {
          navigateTo(
            context: context,
            widget: UserProfileScreen(
              userName: (userModel.name)!,
              userUid: (userModel.uId)!,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Hero(
                tag: '${userModel.uId}+profile',
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).highlightColor,
                  backgroundImage: NetworkImage((userModel.image)!),
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
                      (userModel.name)!,
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 18,
                          height: 1.3),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: deafultButton(
                    fun: () {
                      SocialCubit.get(context).followUser(
                        userId: (userModel.uId)!,
                        userFollowersList: (userModel.followers)!,
                        userName: (userModel.name)!,
                        userImage: (userModel.image)!,
                      );
                    },
                    text: (userModel.followers?.contains(myUid))!
                        ? 'Following'
                        : 'Follow',
                    width: 95,
                    height: 35,
                    textColor: (userModel.followers?.contains(myUid))!
                        ? Theme.of(context).secondaryHeaderColor
                        : Colors.white,
                    fontSize: 15,
                    decoration: BoxDecoration(
                        color: (userModel.followers?.contains(myUid))!
                            ? Theme.of(context).highlightColor
                            : Colors.purple,
                        borderRadius: BorderRadius.circular(20)),
                    isUppercase: false),
              ),
            ],
          ),
        ),
      );

  Widget usersShimmer(context) => ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyShimmer(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.30,
            ),
            MyShimmer(
              height: 30,
              width: MediaQuery.of(context).size.width * 0.22,
            ),
          ],
        ),
        leading: const MyShimmer(
          radius: 30,
        ),
      );
}

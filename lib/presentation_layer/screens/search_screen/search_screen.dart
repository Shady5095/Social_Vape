import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../user_profile_screen/user_profile_screen.dart';

class SearchScreen extends StatefulWidget {


  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: deafaultAppBar(
            context: context,
            title: 'Search',
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                TextFormField(
                  controller: searchController,
                  keyboardType: TextInputType.text,
                  style:
                      TextStyle(color: Theme.of(context).secondaryHeaderColor),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    prefixIconColor: Theme.of(context).secondaryHeaderColor,
                    labelText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (text){
                    setState(() {

                    });
                  },
                  onFieldSubmitted: (text) {
                  },
                ),
              if(searchController.text.isNotEmpty)
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('name',isNotEqualTo: SocialCubit.get(context).userModel?.name)
                        .where('name', isGreaterThanOrEqualTo: searchController.text.trim().toTitleCase())
                        .where('name', isLessThan: '${searchController.text.trim().toTitleCase()}z')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Colors.purple,
                        ));
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search_outlined,
                                size: 125.sp,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                               SizedBox(
                                height: 12.h,
                              ),
                              Text(
                                'No users found !',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 17.sp
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) => users(
                              context: context,
                              snap: snapshot.data?.docs[index].data()),
                          separatorBuilder: (context, index) => const SizedBox(
                                height: 10,
                              ),
                          itemCount: (snapshot.data?.docs.length)!);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget users({
    required BuildContext context,
    required snap,
  }) =>
      InkWell(
        onTap: (){
          navigateTo(
            widget: UserProfileScreen(
                userUid: snap['uId'],
                userName: snap['name'],
            ),
            context: context,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Hero(
                tag: '${snap['uId']}+profile',
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: NetworkImage(snap['image']),
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
extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

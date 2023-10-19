import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../components/constans.dart';
import '../../../styles/icon_broken.dart';
import '../../widgets/post_card_shimmer.dart';
import '../post_card/post_card.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        return Scaffold(
          appBar: deafaultAppBar(
              context: context,
            title: 'Saved posts',
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore
                .instance
                .collection('posts')
                .where('savedBy',arrayContains: myUid)
                .snapshots(),
            builder: (context,snapshot){
              if(snapshot.hasError){
                return const Icon(
                  Icons.warning_amber,
                  color: Colors.red,
                  size: 100,
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
                        IconBroken.Bookmark,
                        size: 150,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'No saved posts yet...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context,index) => PostCard(
                    snapshot: snapshot.data?.docs[index].data(),
                    postNo: index,
                    userModel: SocialCubit.get(context).userModel,
                  ),
                  separatorBuilder: (context,index) =>const SizedBox(height: 10,),
                  itemCount: (snapshot.data?.docs.length)!
              );
            },
          ),
        );
      },
    );
  }
}

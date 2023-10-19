import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_vape/presentation_layer/widgets/shimmer.dart';
import '../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../business_logic_layer/social_cubit/social_states.dart';

class PostCardShimmer extends StatefulWidget {
  const PostCardShimmer({Key? key,}) : super(key: key);

  @override
  State<PostCardShimmer> createState() => _PostCardState();
}

class _PostCardState extends State<PostCardShimmer> {
  bool isAnimating = false ;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        return Card(
          color: Theme.of(context).primaryColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0 ,left: 10 ,top: 10),
                child: Row(
                  children: [
                    const MyShimmer(
                      radius: 25,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyShimmer(
                            height: 9,
                            width: MediaQuery.of(context).size.width*0.35 ,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          MyShimmer(
                            height: 7,
                            width: MediaQuery.of(context).size.width*0.10
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: MyShimmer(
                    height: 9,
                    width: MediaQuery.of(context).size.width*0.50,
                  ),
                ),
              const SizedBox(
                  height: 8,
                ),
              const MyShimmer(
                width: double.infinity,
                height: 270,
                isBorderRadius: false,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 15),
                child: Row(
                  children: [
                    const MyShimmer(
                      radius: 17,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    MyShimmer(
                      height: 5,
                      width: MediaQuery.of(context).size.width*0.25,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

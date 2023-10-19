import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_vape/data_layer/local/cache_helper.dart';

import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';

class DarkModeScreen extends StatelessWidget {
  const DarkModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context, state){},
      builder: (context, state){
        return Scaffold(
          appBar: deafaultAppBar(
              context: context,
            title: 'Dark mode',
          ),
          body: Column(
            children: [
              ListTile(
                onTap: (){
                  SocialCubit.get(context).darkModeLightMode(
                    isDarkMode: true
                  );
                },
                leading: Icon(
                  CacheHelper.getBool(key: 'isDark') != null && CacheHelper.getBool(key: 'isDark')!
                      ? CupertinoIcons.checkmark_alt_circle_fill
                      : CupertinoIcons.circle,
                  color: CacheHelper.getBool(key: 'isDark') != null && CacheHelper.getBool(key: 'isDark')!
                      ? Colors.purple
                      : Theme.of(context).secondaryHeaderColor,
                ),
                title: Text(
                  'On',
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 20
                  ),
                ),
              ),
              ListTile(
                onTap: (){
                  SocialCubit.get(context).darkModeLightMode(
                      isDarkMode: false
                  );
                },
                leading: Icon(
                  CacheHelper.getBool(key: 'isDark') != null && !CacheHelper.getBool(key: 'isDark')!
                      ? CupertinoIcons.checkmark_alt_circle_fill
                      : CupertinoIcons.circle,
                  color: CacheHelper.getBool(key: 'isDark') != null && !CacheHelper.getBool(key: 'isDark')!
                      ? Colors.purple
                      : Theme.of(context).secondaryHeaderColor,
                ),
                title: Text(
                  'Off',
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 20
                  ),
                ),
              ),
              ListTile(
                onTap: (){
                  SocialCubit.get(context).darkModeLightMode();
                },
                leading: Icon(
                  CacheHelper.getBool(key: 'isDark') == null
                      ? CupertinoIcons.checkmark_alt_circle_fill
                      : CupertinoIcons.circle,
                  color: CacheHelper.getBool(key: 'isDark') == null
                      ? Colors.purple
                      : Theme.of(context).secondaryHeaderColor,
                ),
                title: Text(
                  'Use system settings',
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 20
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

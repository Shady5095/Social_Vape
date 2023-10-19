import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_cubit.dart';
import '../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../business_logic_layer/social_cubit/social_states.dart';
import '../../components/components.dart';
import '../../components/constans.dart';
import '../../styles/icon_broken.dart';
import '../screens/chat_screen/chat_details_screen.dart';


class SocialLayout extends StatefulWidget {
  const SocialLayout({super.key});

  @override
  State<SocialLayout> createState() => _SocialLayoutState();
}

class _SocialLayoutState extends State<SocialLayout> with WidgetsBindingObserver {


  void getInit() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    SocialCubit.get(context).getUserDataWithUid(initialMessage!.data['uId']).then((value){
      navigateToAnimated(
        context: context,
        widget: ChatsDetailsScreen(
            userModel: value!
        ),
      );
    });
  }

@override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      SocialCubit.get(context).getUserDataWithUid(event.data['uId']).then((value){
        navigateToAnimated(
          context: context,
          widget: ChatsDetailsScreen(
              userModel: value!
          ),
        );
      });
    });
    FirebaseMessaging.instance.subscribeToTopic('$myUid');
    WidgetsBinding.instance.addObserver(this);
    if(myUid != null)SocialCubit.get(context).userOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
     switch (state) {
      case AppLifecycleState.resumed:
        {
          if(myUid != null)SocialCubit.get(context).userOnlineStatus(true);
        }
        break;
      case AppLifecycleState.inactive:
        {
          if(myUid != null) {
            SocialCubit.get(context).userLastSeen();
            SocialCubit.get(context).userOnlineStatus(false);
          }
          if (SocialCubit.get(context).chatUserUid != null) {
            SocialCubit.get(context).chatTyping(
                receiverId: (SocialCubit.get(context).chatUserUid)!,
                isMessageSent: true
            );
          }
        }
        break;
      case AppLifecycleState.paused:
        {
          if(myUid != null) {
            SocialCubit.get(context).userLastSeen();
            SocialCubit.get(context).userOnlineStatus(false);
          }
          if (SocialCubit.get(context).chatUserUid != null) {
            SocialCubit.get(context).chatTyping(
                receiverId: (SocialCubit.get(context).chatUserUid)!,
                isMessageSent: true);
          }
        }
        break;
      case AppLifecycleState.detached:
        break;
       case AppLifecycleState.hidden:
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(
          value: BlocProvider.of<SocialCubit>(context)..getProfileData()..clearPostIndex(),
          ),
          BlocProvider.value(
          value: BlocProvider.of<ChatCubit>(context)..getProfileData(),
          ),
        ],
          child: BlocConsumer<SocialCubit,SocialStates>(
        listener: (context, state){
          if (state is ChangeBottomNavState){
            SocialCubit.get(context).clearPostIndex();
          }
        },
        builder: (context, state){
          var cubit = SocialCubit.get(context);
          return Scaffold(
            body: cubit.screens[cubit.currentIndex],
            bottomNavigationBar: SalomonBottomBar(
              currentIndex: cubit.currentIndex,
              backgroundColor: Theme.of(context).primaryColor,
              selectedColorOpacity: 0.3,
              curve: Curves.linearToEaseOut,
              duration: const Duration(milliseconds: 250),
              unselectedItemColor: Theme.of(context).secondaryHeaderColor,
              onTap: (index){
                cubit.changeBottomNav(index);
              },
              items: [
                SalomonBottomBarItem(
                  selectedColor: Colors.purple,
                  icon: const Icon(
                      IconBroken.Home
                  ),
                  title: const Text(
                      'Home'
                  ),
                ),
                SalomonBottomBarItem(
                  selectedColor: Colors.blue,
                  icon: const Icon(
                      IconBroken.Chat
                  ),
                  title: const Text(
                      'Chats'
                  ),
                ),
                SalomonBottomBarItem(
                  selectedColor: Colors.pinkAccent,
                  icon: const Icon(
                      IconBroken.Add_User
                  ),
                  title: const Text(
                      'Discover'
                  ),
                ),
                SalomonBottomBarItem(
                  selectedColor: const Color.fromARGB(255, 20, 196, 170),
                  icon: const Icon(
                      IconBroken.Profile
                  ),
                  title: const Text(
                      'Profile'
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

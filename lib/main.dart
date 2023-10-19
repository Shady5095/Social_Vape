
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_vape/business_logic_layer/chat_cubit/chat_cubit.dart';
import 'package:social_vape/presentation_layer/layout/social_vape_layout.dart';
import 'package:social_vape/presentation_layer/screens/login_screen/login_screen.dart';
import 'package:social_vape/presentation_layer/screens/my_profile_screen/edit_profile_screen.dart';
import 'package:social_vape/components/bloc_observer.dart';
import 'package:social_vape/data_layer/network/dio_helper.dart';
import 'package:social_vape/data_layer/local/cache_helper.dart';
import 'package:social_vape/presentation_layer/widgets/restart.dart';
import 'package:social_vape/styles/themes.dart';
import 'business_logic_layer/social_cubit/social_cubit.dart';
import 'business_logic_layer/social_cubit/social_states.dart';
import 'components/app_locale.dart';
import 'components/constans.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DioHelper.init();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();

  Widget? myHomeWidget ;

  myUid = CacheHelper.getString(key: 'uId');
  bool? isDark = CacheHelper.getBool(key: 'isDark');
  if (kDebugMode) {
    print(myUid);
  }

  if (myUid == null){
    myHomeWidget = LoginScreen();
  }
  else {
    myHomeWidget = const SocialLayout();
  }

  runApp(RestartWidget(child: MyApp(
      myHomeWidget: myHomeWidget,
    isDark: isDark,
  )
  ));

}

class MyApp extends StatelessWidget {

  final Widget? myHomeWidget;
  bool? isDark ;
  MyApp({
    required this.myHomeWidget,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return  MultiBlocProvider(
      providers: [
        BlocProvider<SocialCubit>(
          create: (BuildContext context) => SocialCubit()..darkModeLightMode(fromShared: isDark),
        ),
        BlocProvider<ChatCubit>(
          create: (BuildContext context) => ChatCubit()..getProfileData(),
        ),
      ],
      child: BlocConsumer<SocialCubit,SocialStates>(
        listener: (context,state){},
        builder: (context,state){
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            // Use builder only if you need to use library outside ScreenUtilInit context
            builder: (_ , child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                showPerformanceOverlay: true,
                localizationsDelegates: const [
                  AppLocale.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('ar'), // Arabic
                ],
                locale: const Locale('en'),
                theme: lightTheme(context),
                darkTheme: darkTheme(context),
                themeMode: SocialCubit.get(context).isDark != null ? (SocialCubit.get(context).isDark! ? ThemeMode.dark : ThemeMode.light) : ThemeMode.system,
                routes: {
                  'EditProfile': (context)=> EditProfile(),
                },
                home: child,
              );
            },
            child: myHomeWidget,
          );
        },
      ),
    );
  }
}

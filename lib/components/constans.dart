
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import '../../data_layer/local/cache_helper.dart';
import '../presentation_layer/screens/login_screen/login_screen.dart';
import 'app_locale.dart';
import 'components.dart';

String? token = '';
String? myUid = '';

void signOut(context) {
  CacheHelper.removeData(
      key: 'uId'
  )?.then((value) {
    if (value) {
      navigateAndFinish(
          context: context,
          widget: LoginScreen(),
          animation: PageTransitionType.rightToLeftWithFade
      );
    }
  });
}

String myDateTime(){
  DateTime dt = DateTime.now();
  var formattedTime = DateFormat("hh:mm a").format(
      DateTime.now());
  String myDateTime = '${dt.year}-${dt.month}-${dt.day} at $formattedTime' ;
  return myDateTime;
}



String myTimeAgo(BuildContext context ,DateTime datetime, {bool full = true}) {
  DateTime now = DateTime.now();
  DateTime ago = datetime;
  Duration dur = now.difference(ago);
  int days = dur.inDays;
  int years = (days / 365).toInt();
  int months =  ((days - (years * 365)) / 30).toInt();
  int weeks = ((days - (years * 365 + months * 30)) / 7).toInt();
  int rdays = days - (years * 365 + months * 30 + weeks * 7).toInt();
  int hours = (dur.inHours % 24).toInt();
  int minutes = (dur.inMinutes % 60).toInt();
  int seconds = (dur.inSeconds % 60).toInt();
  var diff = {
    "d":rdays,
    "w":weeks,
    "m":months,
    "y":years,
    "s":seconds,
    "i":minutes,
    "h":hours
  };

  Map str = {
    'y':'${getLang(context, 'Y')}',
    'm':'${getLang(context, 'M')}',
    'w':'${getLang(context, 'w')}',
    'd':'${getLang(context, 'd')}',
    'h':'${getLang(context, 'h')}',
    'i':'${getLang(context, 'm')}',
    's':'${getLang(context, 's')}',
  };

  str.forEach((k, v){
    if (diff[k]! > 0) {
      str[k] = diff[k].toString()  +  '' + v.toString() +  (diff[k]! > 1 ? '' : '');
    } else {
      str[k] = "";
    }
  });
  str.removeWhere((index, ele)=>ele == "");
  List<String> tlist = [];
  str.forEach((k, v){
    tlist.add(v);
  });
  if(full){
    return str.length > 0?tlist.join(", ") + "":"Just Now";
  }else{
    return str.length > 0?tlist[0] + "":"Just Now";
  }
}

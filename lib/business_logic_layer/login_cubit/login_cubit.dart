import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:social_vape/business_logic_layer/login_cubit/login_states.dart';

import '../../components/components.dart';
import '../../components/constans.dart';
import '../../data_layer/local/cache_helper.dart';
import '../../presentation_layer/layout/social_vape_layout.dart';


class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(IntState());

  static LoginCubit get(context) => BlocProvider.of(context);

  bool isPassword = true ;
  IconData suffix = Icons.visibility_off_outlined;

  void changeSuffixIcon(){
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(PasswordChange());
  }
  Future<void> userLogin({
  required String email,
  required String password,
    required BuildContext context,
}) async {
    emit(LoginLoadingState());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).then((userCredential)  async {
        emit(LoginSuccessState(userCredential));
        await CacheHelper.putData(key: 'uId', value: userCredential.user?.uid)
            .then((value) async {
          myUid = userCredential.user?.uid;
          navigateAndFinish(
              context: context,
              widget: const SocialLayout(),
              animation: PageTransitionType.rightToLeftWithFade,
          );
        });

      });
    }
    on FirebaseAuthException catch (e) {
      emit(LoginErrorState());
      String? errorText ;
       switch (e.message){
        case 'There is no user record corresponding to this identifier. The user may have been deleted.' : {
          errorText = 'User not exist' ;
        }
        break ;
         case 'We have blocked all requests from this device due to unusual activity. Try again later.' : {
          errorText = 'This account has been temporarily disabled due to many failed login attempts. try again later' ;
        }
        break ;
         case 'The password is invalid or the user does not have a password.' : {
          errorText = 'Password is incorrect' ;
        }
        break ;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$errorText'),
        backgroundColor: Colors.red,
      ));
    }

  }
  void resetPassword({
  required String email,
  required BuildContext context,
}){

    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value) {
      emit(ResetPasswordState());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset link was sent to $email'),
      ));
    }).catchError((error){
      if(error.toString() == '[firebase_auth/channel-error] Unable to establish connection on channel.'){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.red,
        ));
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$email was not exist'),
          backgroundColor: Colors.red,
        ));
      }
    });
  }
}
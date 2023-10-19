import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:social_vape/business_logic_layer/register_cubit/register_states.dart';

import '../../components/components.dart';
import '../../components/constans.dart';
import '../../data_layer/local/cache_helper.dart';
import '../../data_layer/models/user_model.dart';
import '../../presentation_layer/layout/social_vape_layout.dart';


class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(IntStateRegister());

  static RegisterCubit get(context) => BlocProvider.of(context);

  bool isPassword = true ;
  IconData suffix = Icons.visibility_off_outlined;

  void changeSuffixIcon(){
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(PasswordChangeRegister());
  }
  Future<void> userRegister({
    required String email,
    required String password,
    required String name,
    required String phone,
    required BuildContext context,
  }) async {
    emit(RegisterLoadingState());
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((userCredential) async {
        emit(RegisterSuccessState());
       await userCreate(
            email: email,
            name: name,
            phone: phone,
            uId: (userCredential.user?.uid)!
        );
        CacheHelper.putData(key: 'uId', value: userCredential.user!.uid).then((value) {
          myUid = userCredential.user?.uid;
          navigateAndFinish(
              context: context,
              widget: SocialLayout(),
              animation: PageTransitionType.rightToLeftWithFade
          );
        });
      });
    }
    on FirebaseAuthException catch (e) {
      print(e.message);
      emit(RegisterErrorState());
      String? errorText ;
      if(e.message == 'The email address is already in use by another account.'){
        errorText = 'The email address is already in use by another account.';
      }
      else {
        errorText = 'Error';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$errorText'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> userCreate({
    required String email,
    required String name,
    required String phone,
    required String uId,
}) async {
    UserModel model = UserModel(
      name : name,
      email : email,
      phone : phone,
      uId: uId,
      bio: 'Write your bio here...',
      coverImage: 'https://img.freepik.com/free-photo/liquid-purple-art-painting-abstract-colorful-background-with-color-splash-paints-modern-art_1258-97771.jpg?w=1800&t=st=1690208070~exp=1690208670~hmac=7731124b86b22b3a9bb7d6b7b7b1ccdedcc14236fd4cfd19db33904ea3196327',
      image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png',
        followers: [] ,
        following: [] ,
      posts: 0 ,

    );
    FirebaseFirestore.instance.collection('users')
        .doc(uId).
    set(model.toMap()).then((value) {
      emit(UserCreateSuccessState(model));
    }).catchError((error){
      print(error);
      emit(UserCreateErrorState(error.toString()));
    });
}


}
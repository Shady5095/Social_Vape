

import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginStates {}

class IntState extends LoginStates {}

class PasswordChange extends LoginStates {}

class LoginLoadingState extends LoginStates {}

class ResetPasswordState extends LoginStates {}

class LoginSuccessState extends LoginStates {
final UserCredential? userCredential ;

LoginSuccessState(this.userCredential);
}

class LoginErrorState extends LoginStates {}

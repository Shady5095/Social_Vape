
import '../../data_layer/models/user_model.dart';

abstract class RegisterStates {}

class IntStateRegister extends RegisterStates {}

class PasswordChangeRegister extends RegisterStates {}

class RegisterLoadingState extends RegisterStates {}

class RegisterSuccessState extends RegisterStates {}

class RegisterErrorState extends RegisterStates {}

class UserCreateSuccessState extends RegisterStates {
  final UserModel? model ;

  UserCreateSuccessState(this.model);
}

class UserCreateErrorState extends RegisterStates {
  late final String error ;

  UserCreateErrorState(this.error);
}

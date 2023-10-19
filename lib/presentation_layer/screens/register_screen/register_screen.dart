import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../business_logic_layer/register_cubit/register_states.dart';
import '../../../components/components.dart';
import '../../widgets/restart.dart';
import '../../../business_logic_layer/register_cubit/register_cubit.dart';


class RegisterScreen extends StatelessWidget {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit,RegisterStates>(
          listener: (context,state) {
            if(state is UserCreateSuccessState){

            }
          },
          builder : (context,state) {
            var cubit = RegisterCubit.get(context);
            return Scaffold(
              body : Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: <Color>[
                                HexColor('#fc00ff'),
                                HexColor('#333399'),
                              ]
                          ),
                        ),
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 85.h,
                        left: 22.w,
                        child:  Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ClipPath(
                    clipper: WaveClipperOne(reverse: true),
                    child: Container(
                      height: 460.h,
                      width: double.infinity  ,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: SingleChildScrollView(
                          //physics: BouncingScrollPhysics(),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                 SizedBox(
                                  height: 37.h,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: firstNameController,
                                        keyboardType: TextInputType.name,
                                        textCapitalization: TextCapitalization.words,
                                        style: TextStyle(
                                            color: Theme.of(context).secondaryHeaderColor,
                                            fontSize: 13.sp
                                        ),
                                        decoration: InputDecoration(
                                          labelStyle: TextStyle(
                                            color: Theme.of(context).secondaryHeaderColor,
                                          ),
                                          prefixIconColor: Theme.of(context).secondaryHeaderColor,
                                          labelText: 'First Name',
                                          prefixIcon: const Icon(
                                              Icons.person
                                          ),

                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),

                                          ),
                                        ),
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        validator: (value){
                                          if (value==null || value.isEmpty){
                                            return 'Name Must Not Be Empty';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: lastNameController,
                                        keyboardType: TextInputType.name,
                                        textCapitalization: TextCapitalization.words,
                                        style: TextStyle(
                                            color: Theme.of(context).secondaryHeaderColor,
                                            fontSize: 13.sp
                                        ),
                                        decoration: InputDecoration(
                                          labelStyle: TextStyle(
                                            color: Theme.of(context).secondaryHeaderColor,
                                          ),
                                          prefixIconColor: Theme.of(context).secondaryHeaderColor,
                                          labelText: 'Last Name',
                                          prefixIcon: const Icon(
                                              Icons.person
                                          ),

                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),

                                          ),
                                        ),
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        validator: (value){
                                          if (value==null || value.isEmpty){
                                            return 'Name Must Not Be Empty';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                 SizedBox(
                                  height: 12.h,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 13.sp
                                  ),
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                    ),
                                    prefixIconColor: Theme.of(context).secondaryHeaderColor,
                                    suffixIconColor: Theme.of(context).secondaryHeaderColor,
                                    labelText: 'Email Address',
                                    prefixIcon: const Icon(
                                        Icons.email_outlined
                                    ),

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),

                                    ),
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if (value==null || value.isEmpty){
                                      return 'Email Address Must Not Be Empty';
                                    }
                                    else if(!EmailValidator.validate(value, true)){
                                      return 'Email Address invalid';
                                    }
                                    return null;
                                  },
                                ),
                                 SizedBox(
                                  height: 12.h,
                                ),
                                TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 13.sp
                                  ),
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                    ),
                                    prefixIconColor: Theme.of(context).secondaryHeaderColor,
                                    suffixIconColor: Theme.of(context).secondaryHeaderColor,
                                    labelText: 'Phone',
                                    prefixIcon: const Icon(
                                        Icons.phone
                                    ),

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),

                                    ),
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if (value==null || value.isEmpty){
                                      return 'Phone Must Not Be Empty';
                                    }
                                    else if(value.length < 11) {
                                      return 'Phone is invalid';
                                    }
                                    return null;
                                  },
                                ),
                                 SizedBox(
                                  height: 12.h,
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: cubit.isPassword,
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 13.sp
                                  ),
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                    ),
                                    prefixIconColor: Theme.of(context).secondaryHeaderColor,
                                    suffixIconColor: Theme.of(context).secondaryHeaderColor,
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        cubit.changeSuffixIcon();
                                      },
                                      icon: Icon(
                                        cubit.suffix,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                        CupertinoIcons.lock
                                    ),

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),

                                    ),
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if (value==null || value.isEmpty){
                                      return 'Password Must Not Be Empty';
                                    }
                                    else if(value.length < 8) {
                                      return 'Password is to short';
                                    }
                                    null;
                                    return null;
                                  },
                                ),
                                 SizedBox(
                                  height: 12.h,
                                ),
                                TextFormField(
                                  controller: confirmPasswordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: cubit.isPassword,
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 13.sp
                                  ),
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                    ),
                                    prefixIconColor: Theme.of(context).secondaryHeaderColor,
                                    suffixIconColor: Theme.of(context).secondaryHeaderColor,
                                    labelText: 'Confirm Password',
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        cubit.changeSuffixIcon();
                                      },
                                      icon: Icon(
                                        cubit.suffix,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                        Icons.lock
                                    ),

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),

                                    ),
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if (value==null || value.isEmpty){
                                      return 'Password Must Not Be Empty';
                                    }
                                    else if(value.length < 8) {
                                      return 'Password is to short';
                                    }
                                    else if(passwordController.text!=confirmPasswordController.text)
                                    {
                                      return 'Passwords Doesn\'t Match';
                                    }
                                    return null;
                                  },
                                ),
                                 SizedBox(
                                  height: 14.h,
                                ),
                                ConditionalBuilder(
                                  condition: state is !RegisterLoadingState,
                                  builder: (context) => deafultButton(
                                    fun: (){
                                      if (formKey.currentState!.validate()){
                                        cubit.userRegister(
                                          email: emailController.text,
                                          password: passwordController.text,
                                          name: '${firstNameController.text} ${lastNameController.text}',
                                          phone: phoneController.text,
                                          context: context
                                        );
                                      }
                                    },
                                    text: 'Register',
                                    height: 45.h,
                                    textColor: Theme.of(context).secondaryHeaderColor,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                          colors: <Color>[
                                            HexColor('#fc00ff'),
                                            HexColor('#00dbde'),
                                          ]
                                      ),
                                    ),
                                  ),
                                  fallback: (context) => const Center(child: CircularProgressIndicator(color: Colors.purple,)),
                                ),
                                SizedBox(
                                  height: 14.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account ?',
                                      style: TextStyle(
                                        color: Theme.of(context).secondaryHeaderColor,
                                        fontSize: 14.sp
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child:  Text(
                                        'LOGIN',
                                        style: TextStyle(
                                            fontSize: 13.sp
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

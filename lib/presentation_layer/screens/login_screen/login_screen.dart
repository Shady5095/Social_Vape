import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:page_transition/page_transition.dart';
import '../../../business_logic_layer/login_cubit/login_states.dart';
import '../../../components/components.dart';
import '../../../business_logic_layer/login_cubit/login_cubit.dart';
import '../register_screen/register_screen.dart';

class LoginScreen extends StatelessWidget {
  final passController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          if (state is ResetPasswordState) {}
        },
        builder: (context, states) {
          var cubit = LoginCubit.get(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: <Color>[
                              HexColor('#fc00ff'),
                              HexColor('#333399'),
                            ]),
                          ),
                          height: double.infinity,
                        ),
                        Positioned(
                          top: 70.h,
                          left: 23.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome!',
                                style: TextStyle(
                                  fontSize: 39.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Sign in to continue...',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ClipPath(
                      clipper: WaveClipperOne(reverse: true),
                      child: Container(
                        height: 440.h,
                        width: double.infinity,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 38.h,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontSize: 14.sp),
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                    labelText: 'Email Address',
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email address must not be empty';
                                    } else if (!EmailValidator.validate(
                                        value, true)) {
                                      return 'Email address invalid';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 11.h,
                                ),
                                TextFormField(
                                  controller: passController,
                                  keyboardType: TextInputType.visiblePassword,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontSize: 14.sp),
                                  obscureText: cubit.isPassword,
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        cubit.changeSuffixIcon();
                                      },
                                      icon: Icon(
                                        cubit.suffix,
                                      ),
                                    ),
                                    prefixIcon: const Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password must not be empty';
                                    } else if (value.length < 8) {
                                      return 'Password is invalid';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                ConditionalBuilder(
                                  condition: states is! LoginLoadingState,
                                  builder: (context) => deafultButton(
                                    fun: () {
                                      if (formKey.currentState!.validate()) {
                                        cubit.userLogin(
                                            email: emailController.text,
                                            password: passController.text.trim(),
                                            context: context);
                                      }
                                    },
                                    height: 45.h,
                                    text: 'Login',
                                    textColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(colors: <Color>[
                                        HexColor('#fc00ff'),
                                        HexColor('#00dbde'),
                                      ]),
                                    ),
                                  ),
                                  fallback: (context) => const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.purple,
                                  )),
                                ),
                                SizedBox(
                                  height: 7.h,
                                ),
                                deafultButton(
                                  fun: () {
                                    navigateToAnimated(
                                        context: context,
                                        widget: RegisterScreen(),
                                        animation: PageTransitionType
                                            .rightToLeftWithFade);
                                  },
                                  height: 45.h,
                                  text: 'Register',
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(colors: <Color>[
                                      HexColor('#D7DDE8'),
                                      HexColor('#757F9A'),
                                    ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 11.h,
                                ),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      cubit.resetPassword(
                                          email: emailController.text,
                                          context: context);
                                    },
                                    child:  Text(
                                      'FORGOT PASSWORD ?',
                                      style: TextStyle(
                                        fontSize: 13.sp
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

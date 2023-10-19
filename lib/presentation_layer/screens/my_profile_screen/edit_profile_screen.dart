import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import '../../../business_logic_layer/social_cubit/social_cubit.dart';
import '../../../business_logic_layer/social_cubit/social_states.dart';
import '../../../components/components.dart';
import '../../../styles/icon_broken.dart';
import '../../widgets/image_viewer.dart';

class EditProfile extends StatelessWidget {

  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var bioController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit,SocialStates>(
      listener: (context,state){},
      builder: (context,state){
        var cubit = SocialCubit.get(context);
        var userModel = cubit.userModel;
        var profileImagePicker = cubit.profileImagePicker;
        var coverImagePicker = cubit.coverImagePicker;
        nameController.text = (userModel?.name)!;
        phoneController.text = (userModel?.phone)!;
        bioController.text = (userModel?.bio)!;
        return Scaffold(
          appBar: deafaultAppBar(
              context: context,
            title: 'Edit Profile',
            actions: [
              TextButton(
                  onPressed: () async {
                    if ((formKey.currentState?.validate())!){
                      if(coverImagePicker==null &&profileImagePicker==null){
                        cubit.updateUserData(
                            name: nameController.text,
                            phone: phoneController.text,
                            bio: bioController.text,
                          context: context,
                        );
                      }
                      else if(coverImagePicker==null && profileImagePicker!=null) {
                        cubit.uploadProfileImage(
                          name: nameController.text,
                          phone: phoneController.text,
                          bio: bioController.text,
                          context: context,
                        );
                      }
                      else if(coverImagePicker!=null && profileImagePicker==null) {
                        cubit.uploadCoverImage(
                          name: nameController.text,
                          phone: phoneController.text,
                          bio: bioController.text,
                          profileAndCover: false,
                          context: context,
                        );
                      }
                      else if(coverImagePicker!=null && profileImagePicker!=null) {
                        cubit.profileAndCover(
                          name: nameController.text,
                          phone: phoneController.text,
                          bio: bioController.text,
                          profileAndCover: true,
                          context: context,
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 19
                    ),
                  )
              ),
              const SizedBox(
                width: 15,
              ),
            ]
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                if(state is UpdateProfileLoadingState ||
                    state is ProfileImageUploadLoadingState ||
                    state is GetProfileLoadingState ||
                    state is CoverImageUploadLoadingState)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: LinearProgressIndicator(
                    color: Colors.purple,
                    backgroundColor: Color.fromARGB(255, 35, 34, 34),
                  ),
                ),
                SizedBox(
                  height: 260,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: (){

                                  navigateToAnimated(
                                    context: context,
                                    widget: ImageViewer(
                                      photo: coverImagePicker == null ? NetworkImage('${userModel?.coverImage}') : FileImage(coverImagePicker) as ImageProvider,
                                    ),
                                    animation: PageTransitionType.fade
                                );

                              },
                              child: SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image(
                                  fit: BoxFit.cover,
                                  image: coverImagePicker == null ? NetworkImage('${userModel?.coverImage}') : FileImage(coverImagePicker) as ImageProvider,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: InkWell(
                                onTap: (){
                                  cubit.showCustomDialog(
                                    context: context,
                                    galleryOnTap: (){
                                      Navigator.pop(context);
                                      cubit.pickCoverImage(openCamera: false);
                                    },
                                    cameraOnTap: (){
                                      Navigator.pop(context);
                                      cubit.pickCoverImage(openCamera: true);
                                    },
                                  );
                                },
                                child: const CircleAvatar(
                                  radius: 20,
                                  child: Icon(
                                    IconBroken.Edit
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            radius: 74,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              onTap: (){
                                if(userModel?.image != null) {
                                  navigateToAnimated(
                                    context: context,
                                    widget: ImageViewer(
                                      photo: coverImagePicker == null ? NetworkImage('${userModel?.image}') : FileImage(coverImagePicker) as ImageProvider,
                                    ),
                                    animation: PageTransitionType.fade
                                );
                                }
                              },
                              child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.white,
                                  backgroundImage: profileImagePicker == null ? NetworkImage('${userModel?.image}') : FileImage(profileImagePicker) as ImageProvider
                              ),
                            ),
                          ),
                           InkWell(
                            onTap: (){
                              cubit.showCustomDialog(
                                context: context,
                                galleryOnTap: (){
                                  Navigator.pop(context);
                                  cubit.pickProfileImage(openCamera: false);
                                },
                                cameraOnTap: (){
                                  Navigator.pop(context);
                                  cubit.pickProfileImage(openCamera: true);
                                },
                              );
                            },
                            child: const CircleAvatar(
                              radius: 20,
                              child: Icon(
                                  IconBroken.Edit
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            label: const Text(
                              'Name'
                            ),
                            prefixIcon: const Icon(
                              IconBroken.User
                            ),
                            labelStyle: TextStyle(
                                color: Colors.grey[500]
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor,
                              )
                            )
                          ),
                          validator: (value){
                            if (value==null || value.isEmpty){
                              return 'Name must not be empty';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style:  TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          decoration: InputDecoration(
                            label: const Text(
                              'Phone'
                            ),
                            labelStyle: TextStyle(
                                color: Colors.grey[500]
                            ),
                              prefixIcon: const Icon(
                                  IconBroken.Call
                              ),
                            enabledBorder:  UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor,
                              )
                            )
                          ),
                          validator: (value){
                            if (value==null || value.isEmpty){
                              return 'Phone must not be empty';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: bioController,
                          style:  TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                          ),
                          decoration: InputDecoration(
                              label: const Text(
                                  'Bio'
                              ),
                              labelStyle: TextStyle(
                                  color: Colors.grey[500]
                              ),
                              prefixIcon: const Icon(
                                  IconBroken.Info_Square
                              ),
                              enabledBorder:  UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).secondaryHeaderColor,
                                  )
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/routes/routes.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/contacts/cubit/user_contact_cubit.dart';


import '../../../../models/db/user.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../widget/custom_button.dart';


class ContactsScreen extends StatefulWidget {

  bool emptyFormations = false;

  ContactsScreen({super.key});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    getUserContactCubit().getUserContacts();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<UserContactCubit, UserContactState>(
              bloc: getUserContactCubit(),
              builder: (context, state) {
                if (state.userContactList == null || state.userContactList!.isEmpty) {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Center(
                            child: Container(
                              child: Text(
                                  "You don't have contacts, add new contact to start doing payments!",
                                  textAlign: TextAlign.center,
                                  style: context.bodyTextMedium.copyWith(
                                      fontSize: 18
                                    ),
                              ),
                            ),
                          ),
                        ),
                        getAddContactButton()
                      ],
                    ),
                  );
                }
                if (state.status == UserContactStatus.loading) {
                  return Expanded(
                    child: Center(
                      child: Container(
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: state.userContactList!.map((e) {

                              return Dismissible(
                                key: Key(e.email),
                                background: Container(
                                  color: AppColors.dissmisableBgColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Delete",
                                    style: context.bodyTextMedium.copyWith(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  OkCancelResult? isDeletedConfirmed = await showOkCancelAlertDialog(
                                      context: context,
                                      okLabel: "Delete",
                                      cancelLabel: "Cancel",
                                      canPop: true,
                                      title: "Delete user",
                                      message: "Are you sure that you want to delete this contact?",
                                      style: Platform.isIOS ? AdaptiveStyle.iOS :  AdaptiveStyle.material,
                                      fullyCapitalizedForMaterial: false
                                  );
                                  if (isDeletedConfirmed.index == 0) {
                                    //todo delete from database
                                    User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");

                                    if (currUser != null) {
                                      if (currUser.id != null && e.id != null) {
                                        int? deletedResponse = await getDbHelper().deleteUserContact(e.id!, currUser.id!);
                                        print(deletedResponse);
                                        getUserContactCubit().getUserContacts();
                                        return true;
                                      }
                                    }
                                  }
                                  return false;
                                },
                                direction: DismissDirection.endToStart,
                                dismissThresholds: const {DismissDirection.endToStart: 0.1},
                                child: InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(color: AppColors.primaryColor),
                                              borderRadius: BorderRadius.circular(50)
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(50.0),
                                            //make border radius more than 50% of square height & width
                                            child: Image.asset(
                                              "assets/nano.jpg",
                                              height: 42.0,
                                              width: 42.0,
                                              fit: BoxFit.cover, //change image fill type
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.username,
                                              style: context.bodyTextMedium.copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            Text(
                                              e.email,
                                              style: context.bodyTextMedium.copyWith(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            if (AppConstants.trimAddress(e.address).isNotEmpty) ...[
                                              Text(
                                                AppConstants.trimAddress(e.address),
                                                style: context.bodyTextMedium.copyWith(
                                                    fontSize: 16,
                                                    overflow: TextOverflow.ellipsis,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      getAddContactButton()
                    ],
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget getAddContactButton() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            buttonText: "Add Contact",
            radius: 15,
            padding: const EdgeInsets.symmetric(vertical: 10),
            onTap: () {
              AppRouter.pushNamed(RouteNames.AddContactsScreenRoute.name, onBack: () {
                getUserContactCubit().getUserContacts();
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

// @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   switch (state) {
//     case AppLifecycleState.resumed:
//       setState(() {
//       });
//       break;
//     case AppLifecycleState.inactive:
//       break;
//     case AppLifecycleState.paused:
//       break;
//     case AppLifecycleState.detached:
//       break;
//   }
// }
}

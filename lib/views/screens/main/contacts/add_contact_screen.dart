import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/db/user_contact.dart';
import 'package:social_wallet/utils/app_colors.dart';
import 'package:social_wallet/utils/app_constants.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/contacts/cubit/search_contact_cubit.dart';
import 'package:social_wallet/views/screens/main/contacts/cubit/user_contact_cubit.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';
import 'package:social_wallet/views/widget/top_toolbar.dart';

import '../../../../models/db/user.dart';

class AddContactScreen extends StatefulWidget {

  bool emptyFormations = false;

  AddContactScreen({super.key});

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> with WidgetsBindingObserver {

  ToggleStateCubit cubit = getToggleStateCubit();
  TextEditingController textFieldController = TextEditingController();
  late List<UserContact> userContactsList;
  String currUserEmail = getKeyValueStorage().getUserEmail() ?? "";
  
  @override
  void initState() {
    //getSearchContactCubit().getCustomerCustiodedWallets();
    getSearchContactCubit().getAppUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userContactsList = getUserContactCubit().state.userContactList ?? [];
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: TopToolbar(enableBack: true, toolbarTitle: "Add Contact"),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: textFieldController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintText: "test_srs_33@invalidmail.com",
                    hintStyle: context.bodyTextMedium.copyWith(
                      fontSize: 16,
                      color: Colors.grey
                    ),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                            color: AppColors.primaryColor
                        )
                    ),
                    prefixIcon: const Icon(Icons.search, size: 32, color: AppColors.primaryColor),
                  ),
                  style: context.bodyTextMedium.copyWith(
                    fontSize: 18,
                  ),
                  onChanged: (text) {
                    getSearchContactCubit().getAppUser(userEmail: text);
                  },
                ),
                const SizedBox(height: 10),
                BlocListener<UserContactCubit, UserContactState>(
                  bloc: getUserContactCubit(),
                  listener: (context, state) {
                    // TODO: implement listener
                    userContactsList = state.userContactList ?? [];
                  },
                  child: BlocBuilder<SearchContactCubit, SearchContactState>(
                    bloc: getSearchContactCubit(),
                    builder: (context, state) {
                      if (state.userList == null) {
                        return Container();
                      }
                      if (state.userList!.isEmpty) {
                        return const Center(
                          child: Text("Search contact by username or email"),
                        );
                      }
                      if (state.status == SearchContactStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }


                      return Expanded(child: SingleChildScrollView(
                        child: Column(
                          children: state.userList!.map((e) {
                            bool contactExist = false;
                            for (var element in userContactsList) {
                              if (element.id == e.id) {
                                contactExist = true;
                              }
                            }
                            return InkWell(
                              onTap: () async {
                                User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");

                                for (var element in userContactsList) {
                                  if (element.id == e.id) {
                                    contactExist = true;
                                  }
                                }

                                if (currUser != null) {
                                  if (!contactExist) {
                                    int? response = await getDbHelper().insertUserContact(
                                        UserContact(
                                            id: e.id,
                                            email: e.userEmail,
                                            userId: currUser.id,
                                            username: e.username ?? "",
                                            address: e.accountHash
                                        )
                                    );
                                    if (response != null) {
                                      await getUserContactCubit().getUserContacts();
                                      getSearchContactCubit().getAppUser(userEmail: textFieldController.text);
                                      if (mounted) {
                                        AppConstants.showToast(context, "Contact saved");
                                      }
                                    }
                                  } else {
                                    if (mounted) {
                                      AppConstants.showToast(context, "Contact already added");
                                    }
                                  }
                                }
                              },
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
                                          height: 45.0,
                                          width: 45.0,
                                          fit: BoxFit.cover, //change image fill type
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.username ?? "",
                                            style: context.bodyTextMedium.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          Text(
                                            e.userEmail,
                                            style: context.bodyTextMedium.copyWith(
                                                fontSize: 16,
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          if (AppConstants.trimAddress(e.accountHash).isNotEmpty) ...[
                                            Text(
                                              AppConstants.trimAddress(e.accountHash),
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
                                    ),
                                    if (contactExist) ...{
                                      const Icon(Icons.check, color: Colors.green)
                                    },
                                  ],
                                ),
                              ),
                            );
                          }
                          ).toList(),
                        ),
                      )
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

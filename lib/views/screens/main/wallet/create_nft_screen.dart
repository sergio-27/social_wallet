import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/main.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/models/deploy_smart_contract_model.dart';
import 'package:social_wallet/models/deployed_sc_response_model.dart';
import 'package:social_wallet/models/shared_contact_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/config/config_props.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/utils/helpers/extensions/string_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_contacts_cubit.dart';
import 'package:social_wallet/views/screens/main/shared_payments/shared_contact_item.dart';
import 'package:social_wallet/views/screens/main/shared_payments/shared_payment_verification_code_bottom_dialog.dart';
import 'package:social_wallet/views/widget/top_toolbar.dart';

import '../../../../models/db/shared_payment.dart';
import '../../../../models/db/user.dart';
import '../../../../models/send_tx_request_model.dart';
import '../../../../models/send_tx_response_model.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/select_contact_bottom_dialog.dart';

class CreateNftScreen extends StatefulWidget {


  double allSumAmount = 0.0;

  SharedPaymentContactsCubit sharedPayContactsCubit = getSharedPaymentContactsCubit();

  CreateNftScreen({super.key,});

  @override
  _CreateNftScreenState createState() =>
      _CreateNftScreenState();
}

class _CreateNftScreenState extends State<CreateNftScreen> with WidgetsBindingObserver {

  bool isCreatingSharedPayment = false;

  @override
  void initState() {

    super.initState();
  }


  //TODO PASS A BLOC
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: TopToolbar(enableBack: true, toolbarTitle: "Create NFT",),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(text: ''),
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
                  getSearchContactCubit().getAppUser(searchText: text);
                },
              ),
            ],
          ),
        ),
      ),
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

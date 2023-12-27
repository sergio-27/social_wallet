import 'dart:io';


import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/models/shared_contact_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/shared_contact_item.dart';
import 'package:social_wallet/views/widget/top_toolbar.dart';

import '../../../../models/db/shared_payment.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../widget/custom_button.dart';
import '../direct_payment/select_contact_bottom_dialog.dart';

class SharedPaymentSelectContactsScreen extends StatefulWidget {

  double totalAmountDouble = 0.0;
  double allSumAmount = 0.0;
  SharedPayment sharedPayment;

  SharedPaymentSelectContactsScreen({
    super.key,
    required this.sharedPayment
  }) {
    totalAmountDouble = sharedPayment.totalAmount;
  }

  @override
  _SharedPaymentSelectContactsScreenState createState() => _SharedPaymentSelectContactsScreenState();
}

class _SharedPaymentSelectContactsScreenState extends State<SharedPaymentSelectContactsScreen> with WidgetsBindingObserver {

  bool showAddUserButton = true;
  bool showCompleteButton = false;

  List<SharedContactModel> selectedContactsList = List.empty(growable: true);

  //TODO PASS A BLOC
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: TopToolbar(enableBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: selectedContactsList.map((e) =>
                         SharedContactItem(
                             sharedContactModel: e,
                             onClick: () {

                             }
                         )
                      ).toList()
                    ),
                  )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                                "Total amount: ${widget.totalAmountDouble}",
                                style: context.bodyTextMedium.copyWith(
                                  fontSize: 18
                                ),
                            )
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                              "Pending amount: ${widget.totalAmountDouble - widget.allSumAmount}",
                              style: context.bodyTextMedium.copyWith(
                                  fontSize: 18
                              ),
                            )
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showAddUserButton,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: "Add User",
                        radius: 15,
                        elevation: 5,
                        backgroundColor: AppColors.lightPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onTap: () async {
                          AppConstants.showBottomDialog(
                              context: context,
                              isScrollControlled: false,
                              body: SelectContactsBottomDialog(
                                isShowedAddUserButton: showAddUserButton,
                                  onClickContact: onClickContact
                              )
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showCompleteButton,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: "Start Payment",
                        radius: 15,
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onTap: () async {
                          createSharedPayment();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              //FundedByComponent(),
            ]
          ),
        ),
      ),
    );
  }

  void createSharedPayment() async {
    //todo cubit to add
    int? entityId = await getDbHelper().createSharedPayment(widget.sharedPayment);
    if (entityId != null) {
      List<SharedPaymentUsers> sharedPaymentUsers = List.empty(growable: true);

      for (var element in selectedContactsList) {
        sharedPaymentUsers.add(
            SharedPaymentUsers(
                userId: element.userId,
                sharedPaymentId: entityId,
                username: element.contactName,
                userAddress: element.userAddress,
                userAmountToPay: element.amountToPay
            )
        );
      }

      int? result = await getDbHelper().insertSharedPaymentUser(sharedPaymentUsers);
      if (result != null) {
        AppRouter.pop();
      } else {
        //delete created shared payment
        int? result = await getDbHelper().deleteSharedPayment(entityId, widget.sharedPayment.ownerId);
        if (result != null) {
          //todo show error message from delete shared payment
        } else {
          //total chaos xD
        }
      }
    } else {
      //todo show feedback error on create shared payment
    }


  }

  void onClickContact(int userId, String contactName, String? address) async {
    List<String>? results = await showTextInputDialog(
        context: context,
        title: "Amount for $contactName",
        message: "Introduce amount for $contactName",
        okLabel: "Proceed",
        cancelLabel: "Cancel",
        fullyCapitalizedForMaterial: false,
        style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
        textFields: [
          const DialogTextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true)
          )
        ]
    );

    if (results != null) {
      if (results.isNotEmpty) {
        if (results.first.isNotEmpty) {
          double amountToPay = 0.0;
          try {

            amountToPay = double.parse(results.first);
            widget.allSumAmount += amountToPay;

            if (widget.allSumAmount > widget.totalAmountDouble) {
              widget.allSumAmount -= amountToPay;
              return;
            }

          } on Exception catch (e) {
            print(e.toString());
          }

          //todo show dialog with amount for user and currency
          SharedContactModel sharedContactModel = SharedContactModel(
              userId: userId,
              contactName: contactName,
              imagePath: "",
              userAddress: address ?? "",
              amountToPay: amountToPay
          );

          if (!selectedContactsList.contains(sharedContactModel)) {
            setState(() {
              selectedContactsList.add(
                  sharedContactModel
              );

              if (widget.allSumAmount == widget.totalAmountDouble) {
                showAddUserButton = false;
                showCompleteButton = true;
              }
            });
          }
        }
      }
    }

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

import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/models/deploy_smart_contract_model.dart';
import 'package:social_wallet/models/deployed_sc_response_model.dart';
import 'package:social_wallet/models/shared_contact_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/config/config_props.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_contacts_cubit.dart';
import 'package:social_wallet/views/screens/main/shared_payments/shared_contact_item.dart';
import 'package:social_wallet/views/widget/top_toolbar.dart';

import '../../../../models/db/shared_payment.dart';
import '../../../../models/db/user.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/select_contact_bottom_dialog.dart';

class SharedPaymentSelectContactsScreen extends StatefulWidget {

  double totalAmountDouble = 0.0;
  double allSumAmount = 0.0;
  SharedPayment sharedPayment;
  SharedPaymentContactsCubit sharedPayContactsCubit = getSharedPaymentContactsCubit();

  SharedPaymentSelectContactsScreen({super.key, required this.sharedPayment}) {
    totalAmountDouble = sharedPayment.totalAmount;
  }

  @override
  _SharedPaymentSelectContactsScreenState createState() =>
      _SharedPaymentSelectContactsScreenState();
}

class _SharedPaymentSelectContactsScreenState extends State<SharedPaymentSelectContactsScreen> with WidgetsBindingObserver {

  bool isCreatingSharedPayment = false;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      List<String>? results = await showTextInputDialog(
          context: context,
          title: "Total amount",
          message: "Introduce total amount to pay",
          okLabel: "Proceed",
          cancelLabel: "Cancel",
          fullyCapitalizedForMaterial: false,
          barrierDismissible: false,
          style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
          textFields: [
            const DialogTextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true)),
          ]);
      if (results != null) {
        if (results.isNotEmpty) {
          if (results.first.isNotEmpty) {
            double totalAmount = 0.0;
            try {
              totalAmount = double.parse(results.first);
            } on Exception catch (e) {
              print(e.toString());
            }
            widget.sharedPayment = widget.sharedPayment.copyWith(totalAmount: totalAmount);
            widget.sharedPayContactsCubit.updateAmount(totalAmount);
          } else {
            if (mounted) {
              AppConstants.showToast(context, "Total amount cannot be empty");
            }
            AppRouter.pop();
          }
        }
        User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");
        if (mounted) {
          if (currUser?.id != widget.sharedPayment.ownerId) {
            List<String>? resultsCurrUserAmount = await showTextInputDialog(
                context: context,
                title: "Your amount",
                message: "Introduce your total amount to pay",
                okLabel: "Proceed",
                cancelLabel: "Cancel",
                fullyCapitalizedForMaterial: false,
                barrierDismissible: false,
                style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
                textFields: [
                  const DialogTextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true)),
                ]);
            if (resultsCurrUserAmount != null) {
              if (resultsCurrUserAmount.isNotEmpty) {
                if (resultsCurrUserAmount.first.isNotEmpty) {
                  double currUserAmount = 0.0;
                  try {
                    currUserAmount = double.parse(resultsCurrUserAmount.first);
                    if (currUserAmount > (widget.sharedPayment.tokenSelectedBalance ?? 0.0) ) {
                      currUserAmount = 0.0;
                      if (mounted) {
                        AppConstants.showToast(context, "Exceeded amount of your wallet");
                      }
                    } else {
                      widget.allSumAmount += currUserAmount;

                      if (widget.allSumAmount > (widget.sharedPayContactsCubit.state.totalAmount ?? 0.0)) {
                        widget.allSumAmount -= currUserAmount;
                      }
                      widget.sharedPayContactsCubit.updatePendingAmount(widget.allSumAmount);
                    }

                  } on Exception catch (e) {
                    print(e.toString());
                  }

                  insertCurrUser(currUserAmount);
                }else {
                  insertCurrUser(0.0);
                }
              }
            } else {
              insertCurrUser(0.0);
            }
          }

        }
      } else {
        AppRouter.pop();
      }
    });
    super.initState();
  }

  void insertCurrUser(double totalAmount) async {
    User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");
    if (currUser != null) {
      if ((getKeyValueStorage().getUserEmail() ?? "") != widget.sharedPayment.ownerEmail) {
        widget.sharedPayContactsCubit.updateSelectedContactsList(
            [SharedContactModel(
                userId: currUser.id ?? 0,
                contactName: currUser.username ?? "",
                userAddress: currUser.accountHash ?? "",
                imagePath: "",
                amountToPay: 0.0
            )]
        );

      }
    }
  }

  //TODO PASS A BLOC
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: TopToolbar(enableBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<SharedPaymentContactsCubit,
              SharedPaymentContactsState>(
            bloc: widget.sharedPayContactsCubit,
            builder: (context, state) {
              List<SharedContactModel> sharedContactsList = state.selectedContactsList ?? [];
              return Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                          children: sharedContactsList
                              .map((e) => SharedContactItem(sharedContactModel: e, onClick: () async {
                                if (e.amountToPay == 0.0) {
                                  List<String>? resultsCurrUserAmount = await showTextInputDialog(
                                      context: context,
                                      title: "Your amount",
                                      message: "Introduce your total amount to pay",
                                      okLabel: "Proceed",
                                      cancelLabel: "Cancel",
                                      fullyCapitalizedForMaterial: false,
                                      barrierDismissible: false,
                                      style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
                                      textFields: [
                                        const DialogTextField(keyboardType: TextInputType.numberWithOptions(decimal: true)),
                                      ]);
                                  if (resultsCurrUserAmount != null) {
                                    if (resultsCurrUserAmount.isNotEmpty) {
                                      if (resultsCurrUserAmount.first.isNotEmpty) {
                                        double totalAmount = 0.0;
                                        try {
                                          totalAmount = double.parse(resultsCurrUserAmount.first);
                                        } on Exception catch (e) {
                                          print(e.toString());
                                        }
                                        if (totalAmount > (widget.sharedPayment.totalAmount)) {
                                          totalAmount = 0.0;
                                          if (mounted) {
                                            AppConstants.showToast(context, "Exceeded total amount");
                                          }
                                        } else {
                                          //todo pending substract curr user introduced amount
                                          SharedContactModel sharedAux = e.copyWith(amountToPay: totalAmount);
                                          List<SharedContactModel> newList = List.empty(growable: true);

                                          state.selectedContactsList?.forEach((element) {
                                            if (element.contactName == sharedAux.contactName) {
                                              newList.add(sharedAux);
                                            } else {
                                              newList.add(element);
                                            }
                                          });

                                          widget.sharedPayContactsCubit.updateSelectedContactsList(
                                              newList
                                          );
                                          widget.allSumAmount += totalAmount;

                                          if (widget.allSumAmount > (widget.sharedPayContactsCubit.state.totalAmount ?? 0.0)) {
                                            widget.allSumAmount -= totalAmount;
                                          }
                                          widget.sharedPayContactsCubit.updatePendingAmount(widget.allSumAmount);
                                        }
                                      }
                                    }
                                  }
                                }
                              })).toList()),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Total amount: ${state.totalAmount ?? 0.0}",
                                style: context.bodyTextMedium
                                    .copyWith(fontSize: 18),
                              ))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Pending amount: ${state.totalAmount != null ? (state.totalAmount! - (state.allSumAmount ?? 0.0)) : 0.0}",
                                style: context.bodyTextMedium
                                    .copyWith(fontSize: 18),
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: state.allSumAmount != state.totalAmount || state.allSumAmount == 0.0 || state.allSumAmount == null,
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
                                        excludedId: widget.sharedPayment.ownerId,
                                        onClickContact: (userId, username, userAddress) {
                                          onClickContact(state, userId, username, userAddress,  state.selectedContactsList ?? []);
                                        }
                                    ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (state.allSumAmount != null && state.totalAmount != null) && (state.allSumAmount == state.totalAmount && state.totalAmount != 0.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              buttonText: "Start Payment",
                              radius: 15,
                              elevation: 5,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onTap: () async {
                                createSharedPayment(state.selectedContactsList ?? []);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    //FundedByComponent(),
                  ]);
            },
          ),
        ),
      ),
    );
  }

  void createSharedPayment(List<SharedContactModel> selectedContactsList) async {
    //todo pass to cubit
    int? entityId = await getDbHelper().createSharedPayment(widget.sharedPayment);

    if (entityId != null) {
      List<SharedPaymentUsers> sharedPaymentUsers = List.empty(growable: true);

      for (var element in selectedContactsList) {
        sharedPaymentUsers.add(SharedPaymentUsers(
            userId: element.userId,
            sharedPaymentId: entityId,
            username: element.contactName,
            userAddress: element.userAddress,
            userAmountToPay: element.amountToPay));
      }

      int? result = await getDbHelper().insertSharedPaymentUser(sharedPaymentUsers);
      if (result != null) {
        List<String> userAddressList = List.empty(growable: true);

        userAddressList.add(widget.sharedPayment.ownerAddress ?? "");

        for (var element in selectedContactsList) {
          userAddressList.add(element.userAddress);
        }

        //todo deploy smart contract multisig
        DeployedSCResponseModel? response = await getWeb3CoreRepository().createSmartContractSharedPayment(DeploySmartContractModel(
                contractSpecsId: ConfigProps.contractSpecsId,
                sender: ConfigProps.adminAddress,
                blockchainNetwork: widget.sharedPayment.networkId,
                gasLimit: 4000000,
                params: [
              userAddressList,
              userAddressList.length
            ]));

        if (response != null) {
          int? updateSharedPayResponse = await getDbHelper().updateSharedPayment(entityId, widget.sharedPayment.ownerId, response.contractAddress, response.txHash);
          if (updateSharedPayResponse != null) {
            /*SendTxRequestModel sendTxRequestModel = SendTxRequestModel(
              blockchainNetwork: widget.sharedPayment.networkId,
            );*/

            AppRouter.pop();
          }
        }
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

  void onClickContact(SharedPaymentContactsState state, int userId, String contactName, String? address, List<SharedContactModel> selectedContactsList) async {
    List<String>? results = await showTextInputDialog(
        context: context,
        title: "Amount for $contactName",
        message: "Introduce amount for $contactName",
        okLabel: "Proceed",
        cancelLabel: "Cancel",
        canPop: false,
        barrierDismissible: false,

        fullyCapitalizedForMaterial: false,
        style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
        textFields: [
          const DialogTextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true))
        ]);

    if (results != null) {
      if (results.isNotEmpty) {
        if (results.first.isNotEmpty) {
          double amountToPay = 0.0;
          try {
            amountToPay = double.parse(results.first);
            widget.allSumAmount += amountToPay;

            if (widget.allSumAmount > (state.totalAmount ?? 0.0)) {
              widget.allSumAmount -= amountToPay;
              widget.sharedPayContactsCubit.updatePendingAmount(widget.allSumAmount);
              return;
            }
            widget.sharedPayContactsCubit.updatePendingAmount(widget.allSumAmount);
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

           selectedContactsList.add(sharedContactModel);
           widget.sharedPayContactsCubit.updateSelectedContactsList(selectedContactsList);
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

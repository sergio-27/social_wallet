import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/send_tx_response_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/app_constants.dart';
import 'package:social_wallet/utils/config/config_props.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/end_shared_payment_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/verification_code_component.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';

import '../../../../di/injector.dart';
import '../../../../models/db/shared_payment_response_model.dart';
import '../../../../models/db/user.dart';
import '../../../widget/custom_button.dart';

class SharedPaymentDetailsBottomDialog extends StatelessWidget {
  SharedPaymentResponseModel sharedPaymentResponseModel;

  // TxStatusResponseModel txResponse;
  bool isOwner;
  Function() onBackFromCreateDialog;
  EndSharedPaymentCubit endSharedPaymentCubit = getEndSharedPaymentCubit();
  String userAddress = getKeyValueStorage().getUserAddress() ?? "";
  SharedPaymentUsers? sharedPaymentUsers;
  User? currUser;
  ToggleStateCubit toggleInitPaymentCubit = getToggleStateCubit();

  String pin = "";

  SharedPaymentDetailsBottomDialog(
      {super.key,
      required this.isOwner,
      //required this.txResponse,
      required this.onBackFromCreateDialog,
      required this.sharedPaymentResponseModel});

  @override
  Widget build(BuildContext context) {
    sharedPaymentResponseModel.sharedPaymentUser?.forEach((element) {
      if (element.userAddress == userAddress) {
        sharedPaymentUsers = element;
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DefaultTabController(
        length: 1,
        child: Column(
          children: [
            TabBar(
              labelStyle: context.bodyTextMedium.copyWith(
                fontSize: 21,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "Tx Details"),
                //Tab(text: "Tx History"),
              ],
            ),
            Expanded(
                child: TabBarView(
              children: [
                BlocBuilder<EndSharedPaymentCubit, EndSharedPaymentState>(
                  bloc: endSharedPaymentCubit,
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          !isOwner
                                              ? "${sharedPaymentResponseModel.sharedPayment.ownerUsername} has requested you to PAY ${sharedPaymentResponseModel.sharedPayment.totalAmount} ${sharedPaymentResponseModel.sharedPayment.currencySymbol} (x€). \n\nReason: ${sharedPaymentResponseModel.sharedPayment.currencyName}"
                                              : "Requested ${sharedPaymentResponseModel.sharedPayment.totalAmount} ${sharedPaymentResponseModel.sharedPayment.currencySymbol} (x€) to: ${sharedPaymentResponseModel.sharedPaymentUser?.map((e) => e.username).join(", ")}\n\nReason: ${sharedPaymentResponseModel.sharedPayment.currencyName}",
                                          textAlign: TextAlign.start,
                                          maxLines: 20,
                                          style: context.bodyTextMedium.copyWith(fontSize: 18, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (sharedPaymentResponseModel.sharedPayment.status == "CONFIRMED") ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "You have payed: 50 EUROSH",
                                            textAlign: TextAlign.start,
                                            style: context.bodyTextMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  //if (isOwner && sharedPaymentResponseModel.sharedPayment.status == "INIT") ...[
                                    const SizedBox(height: 10),
                                    VerificationCodeComponent(
                                        strategy: currUser?.strategy ?? 0,
                                        onWriteCode: (value) {
                                          if (value != null) {
                                            pin = value;
                                            toggleInitPaymentCubit.toggleState();
                                          }
                                        }
                                    ),
                                 // ]
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              //if (isOwner && txResponse.status == "confirmed" && sharedPaymentResponseModel.sharedPayment.status == "INIT") ...[
                              if (isOwner && sharedPaymentResponseModel.sharedPayment.status == "INIT") ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (state.status == EndSharedPaymentStatus.loading) ...[
                                      const CircularProgressIndicator()
                                    ] else ...[
                                      BlocBuilder<ToggleStateCubit, ToggleStateState>(
                                        bloc: toggleInitPaymentCubit,
                                        builder: (context, state) {
                                          return Expanded(
                                            child: CustomButton(
                                              buttonText: "Init shared payment",
                                              elevation: 3,
                                              enabled: state.isEnabled,
                                              backgroundColor: Colors.green,
                                              radius: 10.0,
                                              onTap: () async {
                                                SendTxResponseModel? sendTxResponseModel = await endSharedPaymentCubit.submitTxReq(
                                                  SendTxRequestModel(
                                                      contractAddress: sharedPaymentResponseModel.sharedPayment.contractAddress ?? "",
                                                      sender: getKeyValueStorage().getUserAddress() ?? "",
                                                      blockchainNetwork: sharedPaymentResponseModel.sharedPayment.networkId,
                                                      //todo get decimals
                                                      //value: AppConstants.parseTokenBalanceBigInt((sharedPaymentUsers?.userAmountToPay.toInt() ?? 0).toString(), 18).toInt(),
                                                      contractSpecsId: ConfigProps.contractSpecsId,
                                                      method: "initTransaction",
                                                      value: 0,
                                                      params: [
                                                        sharedPaymentResponseModel.sharedPayment.id,
                                                        //total shared payment xvalue
                                                        AppConstants.toWei(sharedPaymentResponseModel.sharedPayment.totalAmount, 18).toInt(),
                                                        getKeyValueStorage().getUserAddress() ?? ""
                                                      ],
                                                      pin: pin
                                                  ));

                                                if (sendTxResponseModel != null) {
                                                  int? resultDb = await getDbHelper().updateSharedPaymentStatus(
                                                      sharedPaymentResponseModel.sharedPayment.id ?? 0, sharedPaymentResponseModel.sharedPayment.ownerId, "IN PROGRESS");
                                                  if (resultDb != null) {
                                                    AppRouter.pop();
                                                    onBackFromCreateDialog();
                                                  }
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ] else if (!isOwner) ...[
                                if (sharedPaymentResponseModel.sharedPayment.status == "CONFIRMED") ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (state.status == EndSharedPaymentStatus.loading) ...[
                                        const CircularProgressIndicator()
                                      ] else ...{
                                        Expanded(
                                          child: CustomButton(
                                            buttonText: "Confirm Transaction",
                                            elevation: 3,
                                            radius: 10.0,
                                            backgroundColor: Colors.green,
                                            onTap: () {
                                              /*endSharedPaymentCubit.submitTx(
                                                  SendTxRequestModel(
                                                      contractAddress: sharedPaymentResponseModel.sharedPayment.contractAddress ?? "",
                                                      sender: getKeyValueStorage().getUserAddress() ?? "",
                                                      blockchainNetwork: sharedPaymentResponseModel.sharedPayment.networkId,
                                                      //todo get decimals
                                                      value: AppConstants.parseTokenBalanceBigInt((sharedPaymentUsers?.userAmountToPay.toInt() ?? 0).toString(), 18).toInt(),
                                                      contractSpecsId: 12018,
                                                      method: "submitTransaction",
                                                      params: [
                                                        "",
                                                        sharedPaymentUsers?.userAmountToPay.toInt() ?? 0,
                                                        ""
                                                      ]
                                                  )
                                              );*/
                                            },
                                          ),
                                        ),
                                      },
                                    ],
                                  ),
                                ] else ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (state.status == EndSharedPaymentStatus.loading) ...[
                                        const CircularProgressIndicator()
                                      ] else ...{
                                        Expanded(
                                          child: CustomButton(
                                            buttonText: "Submit Tx",
                                            elevation: 3,
                                            inverseColors: true,
                                            radius: 10.0,
                                            onTap: () async {
                                              SendTxResponseModel? sendTxResponseModel = await endSharedPaymentCubit.submitTxReq(
                                                  SendTxRequestModel(
                                                      contractAddress: sharedPaymentResponseModel.sharedPayment.contractAddress ?? "",
                                                      sender: getKeyValueStorage().getUserAddress() ?? "",
                                                      blockchainNetwork: sharedPaymentResponseModel.sharedPayment.networkId,
                                                      //todo get decimals
                                                      value: AppConstants.parseTokenBalanceBigInt((sharedPaymentUsers?.userAmountToPay.toInt() ?? 0).toString(), 18).toInt(),
                                                      contractSpecsId: ConfigProps.contractSpecsId,
                                                      method: "submitTransaction",
                                                      params: [
                                                        sharedPaymentResponseModel.sharedPayment.id,
                                                        sharedPaymentUsers?.userAmountToPay.toInt() ?? 0,
                                                        ""
                                                      ]
                                                  )
                                              );
                                            },
                                          ),
                                        ),
                                      },
                                    ],
                                  ),
                                ],
                              ],
                            ],
                          ),
                          //todo pending check other params to show init transaction button
                        ],
                      ),
                    );
                  },
                ),
                /*Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      buttonText: "Submit Tx",
                                      elevation: 3,
                                      radius: 10.0,
                                      onTap: () {

                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      buttonText: "Submit Tx",
                                      elevation: 3,
                                      inverseColors: true,
                                      radius: 10.0,
                                      onTap: () {

                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )

                        ],
                      ),
                    ),*/
              ],
            ))
          ],
        ),
      ),
    );
  }
}

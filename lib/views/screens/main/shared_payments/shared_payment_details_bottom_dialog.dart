import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

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
  ToggleStateCubit toggleSubmitPaymentCubit = getToggleStateCubit();
  ToggleStateCubit toggleExecutePaymentCubit = getToggleStateCubit();

  String pin = "";

  SharedPaymentDetailsBottomDialog(
      {super.key,
      required this.isOwner,
      required this.currUser,
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

    if (isOwner) {
      endSharedPaymentCubit.getTxNumConfirmations(
          (sharedPaymentResponseModel.sharedPayment.id ?? 0) - 1, sharedPaymentResponseModel.sharedPayment.networkId);
    }

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
                    if (state.status == EndSharedPaymentStatus.loading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
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
                                        child: RichText(
                                            text: TextSpan(
                                                text: "Status: ",
                                                style: context.bodyTextMedium
                                                    .copyWith(fontSize: 18, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500),
                                                children: [
                                              TextSpan(
                                                text: sharedPaymentResponseModel.sharedPayment.status,
                                                style: context.bodyTextMedium.copyWith(fontSize: 18, overflow: TextOverflow.ellipsis),
                                              )
                                            ])),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          !isOwner
                                              ? "${sharedPaymentResponseModel.sharedPayment.ownerUsername} has requested you to PAY ${sharedPaymentUsers?.userAmountToPay ?? 0.0} ${sharedPaymentResponseModel.sharedPayment.currencySymbol} (x€). \n\nReason: ${sharedPaymentResponseModel.sharedPayment.currencyName}"
                                              : "Requested ${sharedPaymentResponseModel.sharedPayment.totalAmount} ${sharedPaymentResponseModel.sharedPayment.currencySymbol} (x€) to: ${sharedPaymentResponseModel.sharedPaymentUser?.map((e) => e.username).join(", ")}\n\nReason: ${sharedPaymentResponseModel.sharedPayment.currencyName}",
                                          textAlign: TextAlign.start,
                                          maxLines: 20,
                                          style: context.bodyTextMedium
                                              .copyWith(fontSize: 18, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (sharedPaymentResponseModel.sharedPayment.status == "PAYED" && !isOwner) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "You have payed: ${sharedPaymentUsers?.userAmountToPay ?? 0.0} ${sharedPaymentResponseModel.sharedPayment.currencySymbol}",
                                            textAlign: TextAlign.start,
                                            style: context.bodyTextMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (isOwner) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                              text: TextSpan(
                                                  text: "Num confirmations: ",
                                                  style: context.bodyTextMedium
                                                      .copyWith(fontSize: 18, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500),
                                                  children: [
                                                TextSpan(
                                                  text: state.txCurrentNumConfirmations.toString(),
                                                  style: context.bodyTextMedium.copyWith(fontSize: 18, overflow: TextOverflow.ellipsis),
                                                )
                                              ])),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                              text: TextSpan(
                                                  text: "Total required confirmations: ",
                                                  style: context.bodyTextMedium
                                                      .copyWith(fontSize: 18, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500),
                                                  children: [
                                                TextSpan(
                                                  text: sharedPaymentResponseModel.sharedPayment.numConfirmations.toString(),
                                                  style: context.bodyTextMedium.copyWith(fontSize: 18, overflow: TextOverflow.ellipsis),
                                                )
                                              ])),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (sharedPaymentResponseModel.sharedPayment.status == "READY" && isOwner) ...[
                                    const SizedBox(height: 10),
                                    VerificationCodeComponent(
                                        strategy: currUser?.strategy ?? 0,
                                        onWriteCode: (value) {
                                          if (value != null) {
                                            pin = value;
                                            toggleInitPaymentCubit.toggleState();
                                          }
                                        }),
                                  ] else if ((sharedPaymentResponseModel.sharedPayment.status == "PENDING" ||
                                          sharedPaymentResponseModel.sharedPayment.status == "PAYED") &&
                                      !isOwner) ...[
                                    const SizedBox(height: 10),
                                    VerificationCodeComponent(
                                        strategy: currUser?.strategy ?? 0,
                                        onWriteCode: (value) {
                                          if (value != null) {
                                            pin = value;
                                            toggleSubmitPaymentCubit.toggleState();
                                          }
                                        }),
                                  ]
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              if (!isOwner) ...[
                                if (sharedPaymentResponseModel.sharedPayment.status == "PAYED") ...[
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
                                            onTap: () async {
                                              SendTxResponseModel? sendTxResponseModel = await endSharedPaymentCubit.sendTxToSmartContract(
                                                  networkId: sharedPaymentResponseModel.sharedPayment.networkId,
                                                  methodName: "confirmSharedPayment",
                                                  params: [(sharedPaymentResponseModel.sharedPayment.id ?? 0) - 1],
                                                  pin: pin
                                              );
                                              if (sendTxResponseModel != null) {
                                                AppRouter.pop();
                                                onBackFromCreateDialog();
                                              }
                                            },
                                          ),
                                        ),
                                      },
                                    ],
                                  ),
                                  // ] else if (sharedPaymentResponseModel.sharedPayment.status == "PENDING" && !isOwner) ...[
                                ] else if (sharedPaymentResponseModel.sharedPayment.status == "PENDING") ...[
                                  BlocBuilder<ToggleStateCubit, ToggleStateState>(
                                    bloc: toggleSubmitPaymentCubit,
                                    builder: (context, submitState) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (state.status == EndSharedPaymentStatus.loading) ...[
                                            const CircularProgressIndicator()
                                          ] else ...{
                                            Expanded(
                                              child: CustomButton(
                                                buttonText: "Submit Tx",
                                                elevation: 1,
                                                enabled: submitState.isEnabled,
                                                inverseColors: true,
                                                radius: 10.0,
                                                onTap: () async {
                                                  //todo pending know if it is native token and bound it to smart contract
                                                  User? currUser = AppConstants.getCurrentUser();

                                                  SendTxResponseModel? sendTxResponseModel = await endSharedPaymentCubit.sendTxToSmartContract(
                                                      networkId: sharedPaymentResponseModel.sharedPayment.networkId,
                                                      methodName: "submitSharedPayment",
                                                      params: [
                                                        (sharedPaymentResponseModel.sharedPayment.id ?? 0) - 1,
                                                        AppConstants.toWei(sharedPaymentUsers?.userAmountToPay ?? 0.0, 18).toInt()
                                                      ],
                                                      pin: pin
                                                  );

                                                  if (sendTxResponseModel != null && currUser != null) {
                                                    if (sharedPaymentResponseModel.sharedPaymentUser != null) {
                                                      SharedPaymentUsers? spUser = sharedPaymentResponseModel.sharedPaymentUser
                                                          ?.where((element) => element.userId == currUser.id)
                                                          .firstOrNull;

                                                      if (spUser != null) {
                                                        int? updateSharedPaymentUser =
                                                            await getDbHelper().updateSharedPaymentUser(spUser.id ?? 0, spUser.copyWith(hasPayed: 1));

                                                        if (updateSharedPaymentUser != null) {
                                                          AppRouter.pop();
                                                          onBackFromCreateDialog();
                                                        }
                                                      }
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          },
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ] else if (sharedPaymentResponseModel.sharedPayment.status == "READY") ...[
                                BlocBuilder<ToggleStateCubit, ToggleStateState>(
                                  bloc: toggleExecutePaymentCubit,
                                  builder: (context, submitState) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (state.status == EndSharedPaymentStatus.loading) ...[
                                          const CircularProgressIndicator()
                                        ] else ...{
                                          Expanded(
                                            child: CustomButton(
                                              buttonText: "Execute Tx",
                                              elevation: 1,
                                              enabled: true,
                                              backgroundColor: Colors.blueAccent,
                                              radius: 10.0,
                                              onTap: () async {
                                                //todo pending know if it is native token and bound it to smart contract
                                                User? currUser = AppConstants.getCurrentUser();

                                                SendTxResponseModel? sendTxResponseModel = await endSharedPaymentCubit.submitTxReq(SendTxRequestModel(
                                                    sender: getKeyValueStorage().getUserAddress() ?? "",
                                                    blockchainNetwork: sharedPaymentResponseModel.sharedPayment.networkId,
                                                    //todo check why not accepting value param for native token transaction to sc
                                                    //value: AppConstants.toWei(sharedPaymentUsers?.userAmountToPay ?? 0.0, sharedPaymentResponseModel.sharedPayment.tokenDecimals ?? 0).toInt(),
                                                    contractSpecsId: ConfigProps.contractSpecsId,
                                                    method: "executeSharedPayment",
                                                    params: [
                                                      (sharedPaymentResponseModel.sharedPayment.id ?? 0) - 1
                                                    ],
                                                    pin: pin));
                                                if (sendTxResponseModel != null && currUser != null) {
                                                  AppRouter.pop();
                                                  onBackFromCreateDialog();
                                                }
                                              },
                                            ),
                                          ),
                                        },
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                          //todo pending check other params to show init transaction button
                        ],
                      ),
                    );
                  },
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

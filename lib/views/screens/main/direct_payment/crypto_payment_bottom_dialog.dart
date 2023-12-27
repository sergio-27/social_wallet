import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/send_tx_response_model.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/models/transfer_request_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/direct_payment/cubit/direct_payment_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/balance_cubit.dart';


import '../../../../models/db/user.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../widget/custom_button.dart';


class CryptoPaymentBottomDialog extends StatefulWidget {

  SendTxRequestModel sendTxRequestModel;
  List<String> amountToSendResult;
  DirectPaymentState state;
  TokensInfoModel tokenInfoModel;

  CryptoPaymentBottomDialog({super.key, 
    required this.sendTxRequestModel,
    required this.amountToSendResult,
    required this.tokenInfoModel,
    required this.state,
  });

  @override
  _CryptoPaymentBottomDialogState createState() => _CryptoPaymentBottomDialogState();
}

class _CryptoPaymentBottomDialogState extends State<CryptoPaymentBottomDialog>
    with WidgetsBindingObserver {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(
                        "Payment Summary",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: context.bodyTextLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            overflow: TextOverflow.ellipsis
                        ),
                      )
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "From: ",
                      maxLines: 1,
                      style: context.bodyTextLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ),
                  Expanded(flex: 2,child: Text(
                    AppConstants.trimAddress(widget.sendTxRequestModel.sender),
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: context.bodyTextLarge.copyWith(
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis
                    ),
                  ))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "To: ",
                      maxLines: 1,
                      style: context.bodyTextLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ),
                  Expanded(flex: 2,child: Text(
                    AppConstants.trimAddress(widget.state.selectedContactAddress),
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: context.bodyTextLarge.copyWith(
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis
                    ),
                  ))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Amount to sent: ",
                      maxLines: 1,
                      style: context.bodyTextLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ),
                  Expanded(child: Text(
                    widget.amountToSendResult.first,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: context.bodyTextLarge.copyWith(
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis
                    ),
                  ))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Network: ",
                      maxLines: 1,
                      style: context.bodyTextLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ),
                  Expanded(flex: 2,child: Text(
                    widget.tokenInfoModel.tokenName,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: context.bodyTextLarge.copyWith(
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis
                    ),
                  ))
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        AppRouter.pop();
                      },
                      child: Text(
                          "Cancelar",
                          textAlign: TextAlign.end,
                          style: context.bodyTextMedium.copyWith(
                              fontSize: 18,
                              color: Colors.blue
                          )
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: "PAY",
                      radius: 15,
                      elevation: 5,
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onTap: () async {

                        User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");

                        if (currUser != null) {
                          if (currUser.strategy != null) {
                            //2FA
                            if (currUser.strategy == 2) {

                            } else if (currUser.strategy == 3) {
                              //otp
                              /*String? response = await getWalletRepository().sendOTPCode(userEmail: currUser.userEmail);
                              if (mounted && response != null) {
                                AppConstants.showToast(context, "We have send a code to your email");
                                List<String>? amountToSendResult = await showTextInputDialog(
                                    context: context,
                                    title: "Verification Code",
                                    cancelLabel: "Cancel",
                                    okLabel: "Pay",
                                    fullyCapitalizedForMaterial: false,
                                    style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
                                    textFields: [
                                      const DialogTextField(
                                          keyboardType: TextInputType.number
                                      )
                                    ]
                                );

                                if (amountToSendResult == null) {
                                  //todo show button resend?
                                } else {
                                  String verificationCode = amountToSendResult.first;

                                  /*SendTxRequestModel sendReqModel = widget.sendTxRequestModel.copyWith(
                                    pin: verificationCode
                                  );*/
                                }
                              }*/
                              SendTxResponseModel? responseBody = await getDirectPaymentCubit().transferERC20From(
                                  TransferRequestModel(
                                      contractAddress: widget.tokenInfoModel.tokenAddress ?? "",
                                      sender: getKeyValueStorage().getUserAddress() ?? "",
                                      recipient: widget.state.selectedContactAddress ?? "",
                                      //network: widget.tokenInfoModel.networkId,
                                      network: 80001, //todo problem, token balance show goerli network but not bumbai
                                      amount: 5000000000000000000,
                                      gasLimit: 6000000
                                  )
                              );

                            }
                          }
                        }

                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}

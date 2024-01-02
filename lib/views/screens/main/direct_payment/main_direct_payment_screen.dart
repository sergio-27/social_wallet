import 'dart:io';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_wallet/models/owned_token_account_info_model.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/direct_payment/crypto_payment_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/direct_payment/direct_payment_history_screen.dart';
import 'package:social_wallet/views/screens/main/direct_payment/direct_payment_screen.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';


import '../../../../di/injector.dart';
import '../../../../utils/app_constants.dart';
import '../wallet/cubit/balance_cubit.dart';


class MainDirectPaymentScreen extends StatefulWidget {

  bool emptyFormations = false;
  String? imagePath = "euro.svg";
  String contactName = "Search in contacts";


  MainDirectPaymentScreen({super.key});

  @override
  _MainDirectPaymentScreenState createState() => _MainDirectPaymentScreenState();
}

class _MainDirectPaymentScreenState extends State<MainDirectPaymentScreen>
    with WidgetsBindingObserver {

  String? userAddress;
  ToggleStateCubit cubit = getToggleStateCubit();
  BalanceCubit balanceCubit = getBalanceCubit();

  @override
  void initState() {
    userAddress = getKeyValueStorage().getUserAddress();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TabBar(
                  labelStyle: context.bodyTextMedium.copyWith(
                    fontSize: 20
                  ),
                  tabs: [
                    Tab(text: "DirPayment"),
                    Tab(text: "History")
                  ]
              ),
              Expanded(
                child: TabBarView(
                    children: [
                      DirectPaymentScreen(),
                      DirectPaymentHistoryScreen()
                    ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startFiatPayment() {

  }

  void startCryptoPayment(TokensInfoModel? tokensInfoModel) async {
    //todo pending get contract address of selected crypto
    if (getKeyValueStorage().getUserAddress() != null &&
        getDirectPaymentCubit().state.selectedNetwork != null &&
        getDirectPaymentCubit().state.selectedContactAddress != null) {

      if (getKeyValueStorage().getUserAddress()!.isNotEmpty) {

        List<String>? amountToSendResult = await showTextInputDialog(
            context: context,
            title: "Amount to sent",
            cancelLabel: "Cancel",
            okLabel: "Continue",
            fullyCapitalizedForMaterial: false,
            style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
            textFields: [
              const DialogTextField(
                 keyboardType: TextInputType.numberWithOptions(decimal: true)
              )
            ]
        );

        if (amountToSendResult != null) {
          if (amountToSendResult.isNotEmpty) {
            if (amountToSendResult.first.isNotEmpty) {
              try {
                String amountString = amountToSendResult.first;
                if (amountToSendResult.first.contains(",")) {
                  amountString = amountToSendResult.first.replaceFirst(RegExp(","), ".");
                }
                double parsedValue = double.parse(amountString);
                //parsedValue.toInt().modPow(10, state.selectedNetwork.de)

                if (parsedValue <= (double.parse(tokensInfoModel!.balance)) && parsedValue > 0.0) {
                  SendTxRequestModel sendTxRequestModel = SendTxRequestModel(
                      contractAddress: tokensInfoModel.tokenAddress ?? "", //MATIC ??
                      sender: getKeyValueStorage().getUserAddress() ?? "",
                      blockchainNetwork: getDirectPaymentCubit().state.selectedNetwork!.id,
                      //todo change value to wei, figure it out
                      //value: AppConstants.parseTokenBalanceBigInt(amountString, tokensInfoModel.decimals), //son 0.01 matic
                      method: "transfer",
                      //check which method use
                      params: [
                        //todo params of method transfer
                        //state.selectedContactAddress ?? "",
                        getDirectPaymentCubit().state.selectedContactAddress,
                        pow(parsedValue.toInt()*10, tokensInfoModel.decimals),
                      ]
                  );
                  if (mounted) {
                    AppConstants.showBottomDialog(
                        context: context,
                        body: CryptoPaymentBottomDialog(
                            sendTxRequestModel: sendTxRequestModel,
                            amountToSendResult: amountToSendResult,
                            recipientAddress: getDirectPaymentCubit().state.selectedContactAddress ?? "",
                            state: getDirectPaymentCubit().state,
                            tokenInfoModel: tokensInfoModel,
                        )
                    );
                  }
                } else {
                  if (parsedValue == 0.0) {
                    if (mounted) {
                      AppConstants.showToast(context, "Amount cannot be 0");
                    }
                  } else {
                    if (mounted) {
                      AppConstants.showToast(context, "Exceeded your wallet balance. add funds");
                    }
                  }

                }
              } catch(exception) {
                print(exception);
              }
            }
          }
        }
      } else {
        AppConstants.showToast(context, "Create a wallet first");
      }
    } else {
      if (getKeyValueStorage().getUserAddress() == null) {
        AppConstants.showToast(context, "Create a wallet first");
      }
      if (getDirectPaymentCubit().state.selectedNetwork == null) {
        AppConstants.showToast(context, "Select a network first");
      }
      if (getDirectPaymentCubit().state.selectedContactAddress == null) {
        AppConstants.showToast(context, "Select a contact first");
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

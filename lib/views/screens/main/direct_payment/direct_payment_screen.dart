import 'dart:io';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/models/network_info_model.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/direct_payment/crypto_payment_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/direct_payment/cubit/direct_payment_cubit.dart';
import 'package:social_wallet/views/widget/select_contact_bottom_dialog.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';
import 'package:social_wallet/views/widget/network_selector.dart';
import '../../../../di/injector.dart';
import '../../../../models/db/user.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/helpers/form_validator.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/custom_text_field.dart';

class DirectPaymentScreen extends StatefulWidget {
  bool emptyFormations = false;
  String? imagePath = "euro.svg";
  String contactName = "Search in contacts";
  NetworkInfoModel? netInfoModel;
  Function(NetworkInfoModel networkInfoModel) onClickSelectedNetwork;

  DirectPaymentScreen({super.key, required this.onClickSelectedNetwork, this.netInfoModel}) {}

  @override
  _DirectPaymentScreenState createState() => _DirectPaymentScreenState();
}

class _DirectPaymentScreenState extends State<DirectPaymentScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<DirectPaymentScreen> {
  String? userAddress;
  ToggleStateCubit cubit = getToggleStateCubit();

  bool isCryptoSelected = true;

  @override
  void initState() {
    userAddress = getKeyValueStorage().getUserAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          BlocBuilder<DirectPaymentCubit, DirectPaymentState>(
            bloc: getDirectPaymentCubit(),
            builder: (context, state) {
              if (state.selectedCurrencyModel != null) {
                isCryptoSelected = state.selectedCurrencyModel!.isCrypto;
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            AppConstants.showBottomDialog(
                                context: context,
                                body: SelectContactsBottomDialog(onClickContact: (_, contactName, address) {
                                  getDirectPaymentCubit().setContactInfo(contactName, address ?? "");
                                }));
                          },
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(border: Border.all(color: AppColors.primaryColor), borderRadius: BorderRadius.circular(50)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      //make border radius more than 50% of square height & width
                                      child: Image.asset(
                                        "assets/nano.jpg",
                                        height: 100.0,
                                        width: 100.0,
                                        fit: BoxFit.cover, //change image fill type
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text(state.selectedContactName ?? "Search in contacts")],
                              ),
                              if (state.selectedContactAddress != null) ...[
                                if (state.selectedContactAddress!.isNotEmpty) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Text(
                                        AppConstants.trimAddress(state.selectedContactAddress ?? ""),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: context.bodyTextMedium.copyWith(overflow: TextOverflow.ellipsis),
                                      ))
                                    ],
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    //TODO PENDING GET CURRENCIES SYMBOL , NETOWRK ID AND CURRENCY NAME
                  ],
                ),
              );
            },
          ),
          Flexible(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelStyle: context.bodyTextMedium.copyWith(
                      fontSize: 21,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: "Crypto"),
                      Tab(text: "Fiat"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        //todo pendiente mostrar redes disponibles al seleccionar la moneda
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NetworkSelector(
                            selectedNetworkInfoModel: widget.netInfoModel,
                            onClickNetwork: (selectedNetwork) {
                              if (selectedNetwork != null) {
                                widget.netInfoModel = selectedNetwork;
                                widget.onClickSelectedNetwork(selectedNetwork);
                              }
                            },
                            onClickToken: (tokenInfoModel) {
                              startCryptoPayment(tokenInfoModel);
                            },
                          ),
                        ),
                        BlocBuilder<ToggleStateCubit, ToggleStateState>(
                          bloc: cubit,
                          builder: (context, toggleSate) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: CustomTextField(
                                          labelText: "Write amount to send",
                                          inputStyle: context.bodyTextLarge,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          textInputAction: TextInputAction.next,
                                          validator: FormValidator.emptyValidator,
                                          onTap: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          buttonText: "Start payment",
                                          radius: 15,
                                          elevation: 0,
                                          backgroundColor: !cubit.state.isEnabled ? Colors.grey : AppColors.primaryColor,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          onTap: () async {
                                            startFiatPayment();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startFiatPayment() {}

  void startCryptoPayment(TokensInfoModel? tokensInfoModel) async {
    //todo pending get contract address of selected crypto
    if (getKeyValueStorage().getUserAddress() != null &&
        widget.netInfoModel != null &&
        getDirectPaymentCubit().state.selectedContactAddress != null
    ) {
      User? currUser = AppConstants.getCurrentUser();

      if (getKeyValueStorage().getUserAddress()!.isNotEmpty && currUser != null) {
        if (mounted) {
          List<String>? amountToSendResult = await AppConstants.showCustomTextInputDialog(
              context: context,
              title: "Amount to sent",
              okLabel: "Continue",
              cancelLabel: "Cancel",
              textFields: [
                const DialogTextField(keyboardType: TextInputType.numberWithOptions(decimal: true))
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

                  if (parsedValue <= (double.parse(tokensInfoModel!.balance)) && parsedValue > 0.0) {
                    SendTxRequestModel sendTxRequestModel = SendTxRequestModel(
                        contractAddress: tokensInfoModel.tokenAddress ?? "",
                        //MATIC ??
                        sender: getKeyValueStorage().getUserAddress() ?? "",
                        blockchainNetwork: widget.netInfoModel!.id,
                        params: [
                          getDirectPaymentCubit().state.selectedContactAddress,
                          (parsedValue * pow(10, tokensInfoModel.decimals).toInt()).toInt(),
                        ]);
                    if (mounted) {
                      AppConstants.showBottomDialog(
                          context: context,
                          body: CryptoPaymentBottomDialog(
                            strategy: currUser.strategy ?? 0,
                            sendTxRequestModel: sendTxRequestModel,
                            amountToSendResult: amountToSendResult,
                            recipientAddress: getDirectPaymentCubit().state.selectedContactAddress ?? "",
                            state: getDirectPaymentCubit().state,
                            tokenInfoModel: tokensInfoModel,
                          ));
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
                } catch (exception) {
                  print(exception);
                  if (mounted) {
                    AppConstants.showToast(context, "Something went wrong. Thanks for your patience :)");
                  }
                }
              }
            }
          }
        }
      } else {
        if (mounted) {
          AppConstants.showToast(context, "Create a wallet first");
        }
      }
    } else {
      if (getKeyValueStorage().getUserAddress() == null) {
        AppConstants.showToast(context, "Create a wallet first");
      }
      if (widget.netInfoModel == null) {
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

  @override
  bool get wantKeepAlive => true;

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

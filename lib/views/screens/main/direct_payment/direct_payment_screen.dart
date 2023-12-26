import 'dart:io';

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
import 'package:social_wallet/views/screens/main/direct_payment/cubit/direct_payment_cubit.dart';
import 'package:social_wallet/views/screens/main/direct_payment/select_contact_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/direct_payment/select_currency_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/wallet/balance_item.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';
import 'package:social_wallet/views/widget/network_selector.dart';


import '../../../../di/injector.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/helpers/form_validator.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/custom_text_field.dart';
import '../wallet/cubit/balance_cubit.dart';


class DirectPaymentScreen extends StatefulWidget {

  bool emptyFormations = false;
  String? imagePath = "euro.svg";
  String contactName = "Search in contacts";


  DirectPaymentScreen({super.key});

  @override
  _DirectPaymentScreenState createState() => _DirectPaymentScreenState();
}

class _DirectPaymentScreenState extends State<DirectPaymentScreen>
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BlocBuilder<DirectPaymentCubit, DirectPaymentState>(
              bloc: getDirectPaymentCubit(),
              builder: (context, state) {
                bool isCryptoSelected = false;
                String? imagePath;
                if (state.selectedCurrencyModel != null) {
                  isCryptoSelected = state.selectedCurrencyModel!.isCrypto;
                  imagePath = state.selectedCurrencyModel!.imagePath;
                }
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(

                        children: [
                          InkWell(
                            onTap: () {
                              AppConstants.showBottomDialog(
                                  context: context,
                                  isScrollControlled: false,
                                  body: SelectContactsBottomDialog(
                                      onClickContact: (contactName, address) {
                                        getDirectPaymentCubit().setContactInfo(contactName, AppConstants.trimAddress(address));
                                        AppRouter.pop();
                                      }
                                  )
                              );
                            },
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  children: [
                                    Text(state.selectedContactName ?? "Search in contacts")
                                  ],
                                ),
                                if (state.selectedContactAddress != null) ...[
                                  if (state.selectedContactAddress!.isNotEmpty) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(state.selectedContactAddress ?? "")
                                      ],
                                    ),
                                  ],
                                ],

                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          InkWell(
                            onTap: () {
                              AppConstants.showBottomDialog(
                                  context: context,
                                  body: SelectCurrencyBottomDialog(
                                      isUserAddressNull: userAddress == null || userAddress!.isEmpty,
                                      onClickCurrency: (selectedCurrency) {
                                        cubit.toggleState();
                                        getDirectPaymentCubit().setSelectedCurrencyModel(selectedCurrency);
                                      }
                                  )
                              );
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: SvgPicture.asset("assets/${imagePath ?? 'euro.svg'}", height: 48, width: 48),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Visibility(
                            visible: !isCryptoSelected,
                            child: Row(
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
                          ),
                          const SizedBox(height: 10),
                          //todo pendiente mostrar redes disponibles al seleccionar la moneda
                          Visibility(
                            visible: isCryptoSelected,
                            child: Column(
                              children: [
                                NetworkSelector(
                                  balanceCubit: balanceCubit,
                                  selectedNetwork: state.selectedNetwork,
                                  showDefaultSelected: true,
                                  onClickNetwork: (networkInfo) {
                                    if (networkInfo != null) {
                                      getDirectPaymentCubit().setSelectedNetwork(networkInfo);
                                      balanceCubit.getAccountBalance(
                                          accountToCheck: getKeyValueStorage().getUserAddress() ?? "",
                                          networkInfoModel: networkInfo,
                                          networkId: networkInfo.id
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //TODO PENDING GET CURRENCIES SYMBOL , NETOWRK ID AND CURRENCY NAME
                      Visibility(
                        visible: isCryptoSelected,
                        child: BlocBuilder<BalanceCubit, BalanceState>(
                          bloc: balanceCubit,
                          builder: (context, balanceState) {
                            switch (balanceState.status) {
                              case BalanceStatus.initial:
                                return Container();
                              case BalanceStatus.loading:
                                return const Expanded(child: Center(
                                  child: CircularProgressIndicator(),
                                ));
                              case BalanceStatus.success:
                                return Expanded(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                                "Select currency to do the payment",
                                              style: context.bodyTextMedium.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: List.generate(1, (index) =>
                                                  BalanceItem(
                                                      tokenWalletItem: balanceState.walletTokenItemList!,
                                                      onClickToken: (tokenInfo) {
                                                        startCryptoPayment(state, tokenInfo);
                                                      },
                                                  )
                                              ),
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                );
                              case BalanceStatus.error:
                                return const Expanded(child: Center(
                                  child: Text("Error"),
                                ));
                            }
                            return const Column(
                              children: [],
                            );

                          },
                        ),
                      ),
                      Visibility(
                        visible: !isCryptoSelected,
                        child: BlocBuilder<ToggleStateCubit, ToggleStateState>(
                          bloc: cubit,
                          builder: (context, toggleSate) {
                            return Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    buttonText: "Start payment",
                                    radius: 15,
                                    elevation: 5,
                                    backgroundColor: !cubit.state.isEnabled ? Colors.grey : AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    onTap: () async {
                                      startFiatPayment();
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
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

  void startFiatPayment() {

  }

  void startCryptoPayment(DirectPaymentState state, TokensInfoModel? tokensInfoModel) async {
    //todo pending get contract address of selected crypto
    if (getKeyValueStorage().getUserAddress() != null &&
        state.selectedNetwork != null &&
        state.selectedContactAddress != null) {

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

                if (parsedValue <= (double.parse(tokensInfoModel!.balance)) && parsedValue > 0.0) {
                  SendTxRequestModel sendTxRequestModel = SendTxRequestModel(
                      contractAddress: tokensInfoModel.tokenAddress ?? "", //MATIC ??
                      sender: getKeyValueStorage().getUserAddress() ?? "",
                      blockchainNetwork: state.selectedNetwork!.id,
                      //todo change value to wei, figure it out
                      value: 10000000000000000, //son 0.01 matic
                      method: "transfer",
                      //check which method use
                      params: [
                        //todo params of method transfer
                        //state.selectedContactAddress ?? "",
                        state.selectedContactAddress,
                        10000000000000000
                      ],
                      pin: "" //todo figure it out how to get 2FA pin
                  );
                  if (mounted) {
                    AppConstants.showBottomDialog(
                        context: context,
                        body: CryptoPaymentBottomDialog(
                            sendTxRequestModel: sendTxRequestModel,
                            amountToSendResult: amountToSendResult,
                            state: state,
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
      if (state.selectedNetwork == null) {
        AppConstants.showToast(context, "Select a network first");
      }
      if (state.selectedContactAddress == null) {
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

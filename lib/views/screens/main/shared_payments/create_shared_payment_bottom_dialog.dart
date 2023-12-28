
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/models/db/shared_payment.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/utils/app_constants.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/balance_item.dart';
import 'package:social_wallet/views/widget/network_selector.dart';


import '../../../../di/injector.dart';
import '../../../../models/db/shared_payment_response_model.dart';
import '../../../../models/db/user.dart';
import '../../../../routes/app_router.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../widget/custom_button.dart';
import '../wallet/cubit/balance_cubit.dart';


class CreateSharedPaymentBottomDialog extends StatelessWidget {

  BalanceCubit balanceCubit = getBalanceCubit();
  Function() onBackFromCreateDialog;

  CreateSharedPaymentBottomDialog({
    super.key,
    required this.onBackFromCreateDialog
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DefaultTabController(
        length: 1,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "Crypto"),
                //Tab(text: "Fiat"),
              ],
            ),
            Expanded(
              child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Select currency to do the payment",
                                    textAlign: TextAlign.center,
                                    style: context.bodyTextMedium.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            NetworkSelector(
                              balanceCubit: balanceCubit,
                              selectedNetwork: getSharedPaymentCubit().state.selectedNetwork,
                              onClickNetwork: (networkInfoModel) {
                                if (networkInfoModel != null) {
                                  //todo replace account
                                  getSharedPaymentCubit().setSelectedNetwork(networkInfoModel);
                                  balanceCubit.getAccountBalance(
                                      accountToCheck: getKeyValueStorage().getUserAddress() ?? "",
                                      networkInfoModel: networkInfoModel,
                                      networkId: networkInfoModel.id
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            BlocBuilder<BalanceCubit, BalanceState>(
                              bloc: balanceCubit,
                              builder: (context, state) {
                                switch (state.status) {
                                  case BalanceStatus.initial:
                                    return Container();
                                  case BalanceStatus.loading:
                                    return const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                      ],
                                    );
                                  case BalanceStatus.success:
                                    return Column(
                                      //todo change to get all tokens from user from given network
                                      children: List.generate(1, (index) =>
                                          BalanceItem(
                                            tokenWalletItem: state.walletTokenItemList!,
                                            onClickToken: (tokenInfo) async {
                                              List<String>? results = await showTextInputDialog(
                                                  context: context,
                                                  title: "Total amount",
                                                  message: "Introduce total amount to pay",
                                                  okLabel: "Proceed",
                                                  cancelLabel: "Cancel",
                                                  fullyCapitalizedForMaterial: false,
                                                  style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
                                                  textFields: [
                                                    const DialogTextField(keyboardType: TextInputType.numberWithOptions(decimal: true)),
                                                  ]);

                                              if (results != null) {
                                                if (results.isNotEmpty) {
                                                  if (results.first.isNotEmpty) {

                                                    User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");

                                                    if (currUser != null) {
                                                      double totalAmount = 0.0;
                                                      try {
                                                        totalAmount = double.parse(results.first);
                                                      } on Exception catch (e) {
                                                        print(e.toString());
                                                      }
                                                      SharedPayment sharedPayment = SharedPayment(
                                                          ownerId: currUser.id ?? 0,
                                                          totalAmount: totalAmount,
                                                          ownerUsername: currUser.username ?? "",
                                                          status: "INIT",
                                                          currencyName: tokenInfo?.tokenName ?? "",
                                                          currencySymbol: tokenInfo?.tokenSymbol ?? "",
                                                          networkId: tokenInfo?.networkId ?? 0,
                                                          creationTimestamp: DateTime.now().millisecondsSinceEpoch
                                                      );
                                                      AppRouter.pop();
                                                      AppRouter.pushNamed(
                                                          RouteNames.SharedPaymentSelectContacsScreenRoute.name,
                                                          args: sharedPayment,
                                                          onBack: () {
                                                            onBackFromCreateDialog();
                                                          }
                                                      );
                                                    }
                                                  }
                                                }
                                              }
                                            },
                                          )
                                      ),
                                    );
                                  case BalanceStatus.error:
                                    return const Expanded(child: Center(
                                      child: Text("Error"),
                                    ));
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    /*SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Select currency to do the payment",
                                                            textAlign: TextAlign.center,
                                                            style: context.bodyTextMedium.copyWith(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w700
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 15),

                                                  ],
                                                ),
                                              ),*/
                  ]
              ),
            ),
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
                            fontSize: 20,
                            color: Colors.blue
                        )
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

      ),
    );
  }
}

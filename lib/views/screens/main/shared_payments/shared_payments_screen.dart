
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/utils/app_constants.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_cubit.dart';
import 'package:social_wallet/views/widget/network_selector.dart';


import '../../../../di/injector.dart';
import '../../../../routes/app_router.dart';
import '../../../../utils/app_colors.dart';
import '../../../widget/custom_button.dart';
import '../wallet/cubit/balance_cubit.dart';


class SharedPaymentsScreen extends StatefulWidget {

  bool emptyFormations = false;

  SharedPaymentsScreen({super.key});

  @override
  _SharedPaymentsScreenState createState() => _SharedPaymentsScreenState();
}

class _SharedPaymentsScreenState extends State<SharedPaymentsScreen>
    with WidgetsBindingObserver {

  BalanceCubit balanceCubit = getBalanceCubit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocBuilder<SharedPaymentCubit, SharedPaymentState>(
          bloc: getSharedPaymentCubit(),
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(50,
                              (index) =>
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  onTap: () {

                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                            height: 48.0,
                                            width: 48.0,
                                            fit: BoxFit.cover, //change image fill type
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Shared payment #$index", textAlign: TextAlign.start),
                                          Text(
                                            "User1, User2",
                                            textAlign: TextAlign.start,
                                            style: context.bodyTextMedium.copyWith(
                                                color: Colors.grey,
                                                fontSize: 13
                                            ),
                                          ),
                                        ],
                                      )),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: "Shared Payment",
                        radius: 15,
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onTap: () async {
                          AppConstants.showBottomDialog(
                              context: context,
                              body: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DefaultTabController(
                                  length: 2,
                                  child: Column(
                                    children: [
                                      const TabBar(
                                        tabs: [
                                          Tab(text: "Crypto"),
                                          Tab(text: "Fiat"),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                            children: [
                                              SingleChildScrollView(
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
                                                          balanceCubit.getCryptoNativeBalance(
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
                                                                  InkWell(
                                                                    onTap: () {

                                                                    },
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Image.asset("assets/ic_polygon.png", height: 32, width: 32),
                                                                          const SizedBox(width: 10),
                                                                          Expanded(
                                                                            child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  getSharedPaymentCubit().state.selectedNetwork != null
                                                                                      ? getSharedPaymentCubit().state.selectedNetwork!.symbol
                                                                                      : "",
                                                                                  style: context.bodyTextMedium.copyWith(
                                                                                      fontSize: 18,
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.w500
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                "${state.balance ?? 0.0} ${getSharedPaymentCubit().state.selectedNetwork != null ?
                                                                                getSharedPaymentCubit().state.selectedNetwork!.symbol : ""}",
                                                                                style: context.bodyTextMedium.copyWith(
                                                                                    color: Colors.black,
                                                                                    fontSize: 15
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                "Pending calculate...",
                                                                                style: context.bodyTextMedium.copyWith(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 14
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
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
                                              SingleChildScrollView(
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
                                              ),
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
                              )
                          );

                          /*List<String>? results = await showTextInputDialog(
                          context: context,
                          title: "Total amount",
                          message: "Introduce total amount to pay",
                          okLabel: "Proceed",
                          cancelLabel: "Cancel",
                          fullyCapitalizedForMaterial: false,
                          style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
                          textFields: [
                            const DialogTextField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true)
                            ),
                          ]
                      );

                      if (results != null) {
                        if (results.isNotEmpty) {
                          if (results.first.isNotEmpty) {
                            AppRouter.pushNamed(RouteNames.SharedPaymentSelectContacsScreenRoute.name, args: results.first);
                          }
                        }
                      }*/
                        },
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

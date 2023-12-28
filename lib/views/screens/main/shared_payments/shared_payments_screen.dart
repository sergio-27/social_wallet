import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/utils/app_constants.dart';
import 'package:social_wallet/views/screens/main/shared_payments/create_shared_payment_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_cubit.dart';
import 'package:social_wallet/views/screens/main/shared_payments/shared_payment_details_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/shared_payments/shared_payment_item.dart';


import '../../../../di/injector.dart';
import '../../../widget/custom_button.dart';



class SharedPaymentsScreen extends StatefulWidget {

  bool emptyFormations = false;

  SharedPaymentsScreen({super.key});

  @override
  _SharedPaymentsScreenState createState() => _SharedPaymentsScreenState();
}

class _SharedPaymentsScreenState extends State<SharedPaymentsScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    getSharedPaymentCubit().getUserSharedPayments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<SharedPaymentCubit, SharedPaymentState>(
              bloc: getSharedPaymentCubit(),
              builder: (context, state) {
                if (state.sharedPaymentResponseModel != null) {
                  if (state.sharedPaymentResponseModel?.isEmpty ?? true) {
                    return Text("Not created any shared payment yet! :(");
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: state.sharedPaymentResponseModel!.map((e) =>
                                SharedPaymentItem(
                                    element: e,
                                    onClickItem: (sharedPayInfo) {
                                      AppConstants.showBottomDialog(
                                          context: context,
                                          body: SharedPaymentDetailsBottomDialog(
                                            sharedPaymentResponseModel: e,
                                            onBackFromCreateDialog: () {
                                              getSharedPaymentCubit().getUserSharedPayments();
                                            },
                                          )
                                      );
                                    },
                                )
                            ).toList()
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    buttonText: "Request Shared Payment",
                    radius: 15,
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onTap: () {
                      AppConstants.showBottomDialog(
                          context: context,
                          body: CreateSharedPaymentBottomDialog(
                            onBackFromCreateDialog: () {
                              getSharedPaymentCubit().getUserSharedPayments();
                            },
                          )
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

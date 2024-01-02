import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_item_cubit.dart';
import '../../../../models/db/shared_payment_response_model.dart';
import '../../../../utils/app_colors.dart';


class SharedPaymentItem extends StatelessWidget {

  SharedPaymentResponseModel element;
  Function(SharedPaymentResponseModel sharedPayInfo) onClickItem;
  SharedPaymentItem({super.key, required this.element, required this.onClickItem});

  SharedPaymentItemCubit cubit = getSharedPaymentItemCubit();

  @override
  Widget build(BuildContext context) {
    cubit.getSharedPaymentTxStatus(element.sharedPayment.networkId, element.sharedPayment.creationTxHash ?? "");
    return Material(
      elevation: 0,
      color: AppColors.appBackgroundColor,
      child: InkWell(
        onTap: () {
          onClickItem(element);
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
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
                    height: 60.0,
                    width: 60.0,
                    fit: BoxFit.cover, //change image fill type
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "Shared payment ${element.sharedPayment.id ?? 0} ",
                        style: context.bodyTextMedium,
                        children: [
                          TextSpan(
                            text: "#${element.sharedPayment.ownerUsername}",
                            style: context.bodyTextMediumW700
                          )
                        ]
                      )
                  ),

                  Text(
                    "Total amount: ${element.sharedPayment.totalAmount} ${element.sharedPayment.currencySymbol}",
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    style: context.bodyTextMedium.copyWith(
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 13
                    ),
                  ),
                if (element.sharedPayment.status != "INIT") ...[
                  Text(
                    "Amount to pay: ${element.sharedPaymentUser?.firstWhere((element) => true).userAmountToPay} ${element.sharedPayment.currencySymbol}",
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    style: context.bodyTextMedium.copyWith(
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 13
                    ),
                  ),
                ],
                ],
              )),
              if (element.sharedPayment.creationTxHash != null) ...[
                const SizedBox(width: 10),
                BlocBuilder<SharedPaymentItemCubit, SharedPaymentItemState>(
                  bloc: cubit,
                  builder: (context, state) {
                    switch (state.status) {

                      case SharedPaymentItemStatus.INIT:
                        return Container();
                      case SharedPaymentItemStatus.PENDING:
                        return Column(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  color:  Colors.orange,
                                  shape: BoxShape.circle),
                            ),
                            Row(
                              children: [
                                Text(
                                   "PENDING",
                                  style: context.bodyTextSmall.copyWith(
                                      color: Colors.orange
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      case SharedPaymentItemStatus.SUCCESS:
                        return Column(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  color: element.sharedPayment.status != "INIT"
                                      ? Colors.orange
                                      : Colors.blue,
                                  shape: BoxShape.circle),
                            ),
                            Row(
                              children: [
                                Text(
                                  element.sharedPayment.status != "INIT"
                                      ? "PENDING"
                                      : "INITIATED",
                                  style: context.bodyTextSmall.copyWith(
                                      color: element.sharedPayment.status != "INIT"
                                          ? Colors.orange
                                          : Colors.blue),
                                )
                              ],
                            )
                          ],
                        );
                      case SharedPaymentItemStatus.ERROR:
                        return Container();
                    }

                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

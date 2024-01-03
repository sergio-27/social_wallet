import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_item_cubit.dart';
import '../../../../models/db/shared_payment_response_model.dart';
import '../../../../utils/app_colors.dart';


class SharedPaymentItem extends StatelessWidget {

  SharedPaymentResponseModel element;
  bool isOwner;
  Function(SharedPaymentResponseModel sharedPayInfo) onClickItem;
  SharedPaymentItem({super.key, required this.element, required this.isOwner, required this.onClickItem});

  @override
  Widget build(BuildContext context) {
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
                //todo if im not the owner
                if (!isOwner) ...[
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
              Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        color: element.sharedPayment.status != "INIT" ? Colors.orange : Colors.blue,
                        shape: BoxShape.circle
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        element.sharedPayment.status != "INIT" ? "PENDING" : "TO INIT",
                        style: context.bodyTextSmall.copyWith(
                            color: element.sharedPayment.status != "INIT" ? Colors.orange : Colors.blue
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

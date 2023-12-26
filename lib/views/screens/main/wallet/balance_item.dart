
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/models/network_info_model.dart';
import 'package:social_wallet/models/token_wallet_item.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';


import '../../../../utils/helpers/form_validator.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/custom_text_field.dart';


class BalanceItem extends StatefulWidget {


  TokenWalletItem tokenWalletItem;
  Function(TokensInfoModel? tokenInfoModel)? onClickToken;

  BalanceItem({
    super.key,
    required this.tokenWalletItem,
    this.onClickToken,
  });

  @override
  _BalanceItemState createState() => _BalanceItemState();
}

class _BalanceItemState extends State<BalanceItem>
    with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (widget.onClickToken != null) {
              widget.onClickToken!(widget.tokenWalletItem.mainTokenInfoModel);
            }
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
                        widget.tokenWalletItem.mainTokenInfoModel != null ? widget.tokenWalletItem.mainTokenInfoModel!.tokenSymbol : "",
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
                      widget.tokenWalletItem.mainTokenInfoModel != null ? widget.tokenWalletItem.mainTokenInfoModel!.balance : "",
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
        ),
        if (widget.tokenWalletItem.erc20TokensList != null) ...{
          if (widget.tokenWalletItem.erc20TokensList!.isNotEmpty) ...{
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.tokenWalletItem.erc20TokensList != null ? widget.tokenWalletItem.erc20TokensList!.map((e) =>
                    InkWell(
                      onTap: () {
                        if (widget.onClickToken != null) {
                          widget.onClickToken!(e);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Image.asset("assets/ic_polygon.png", height: 26, width: 26),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      e.tokenSymbol,
                                      maxLines: 2,
                                      style: context.bodyTextMedium.copyWith(
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      e.balance,
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
                          ],
                        ),
                      ),
                    )
                ).toList() : [],
              ),
            )
          }
        }

      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}

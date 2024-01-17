import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/network_info_model.dart';
import 'package:social_wallet/models/token_wallet_item.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/app_colors.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';

import '../../../../utils/helpers/form_validator.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/custom_text_field.dart';

class NftItem extends StatefulWidget {


  Function() onClickNft;

  NftItem({
    super.key,
    required this.onClickNft,
  });

  @override
  _NftItemState createState() => _NftItemState();
}

class _NftItemState extends State<NftItem> with WidgetsBindingObserver {


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          widget.onClickNft();
        },
        child: Material(
            elevation: 3,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: AppColors.appBackgroundColor,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                "assets/ic_default_nft.jpg",
                fit: BoxFit.fitWidth,
              ),
            )
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

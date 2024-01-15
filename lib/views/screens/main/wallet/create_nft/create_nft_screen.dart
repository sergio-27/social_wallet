import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/user_nfts_model.dart';
import 'package:social_wallet/utils/app_constants.dart';

import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/utils/helpers/form_validator.dart';

import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_contacts_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/create_nft_cubit.dart';
import 'package:social_wallet/views/widget/custom_text_field.dart';
import 'package:social_wallet/views/widget/top_toolbar.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../widget/custom_button.dart';
import '../../../../widget/network_selector.dart';

class CreateNftScreen extends StatefulWidget {

  CreateNftScreen({
    super.key,
  });

  @override
  _CreateNftScreenState createState() => _CreateNftScreenState();
}

class _CreateNftScreenState extends State<CreateNftScreen> with WidgetsBindingObserver {
  bool isCreatingSharedPayment = false;
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController symbolController = TextEditingController(text: '');
  TextEditingController aliasController = TextEditingController(text: '');
  int? selectedNetworkId;
  CreateNftCubit createNftCubit = getCreateNftCubit();

  @override
  void initState() {
    super.initState();
  }

  //TODO PASS A BLOC
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NetworkSelector(
          selectedNetworkInfoModel: null,
          showMakePaymentText: false,
          showList: false,
          onClickNetwork: (selectedValue) {
            if (selectedValue != null) {
              selectedNetworkId = selectedValue.id;
            }
          },
        ),
        const SizedBox(height: 10),
        BlocBuilder<CreateNftCubit, CreateNftState>(
          bloc: createNftCubit,
          builder: (context, state) {
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: FormValidator.emptyValidator,
                        labelText: "Name",
                        controller: nameController,
                        labelStyle: context.bodyTextMedium.copyWith(fontSize: 16, color: AppColors.hintTexFieldGrey),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: FormValidator.emptyValidator,
                        labelText: "Symbol",
                        maxLines: 1,
                        controller: symbolController,
                        alignLabelWithHint: true,
                        labelStyle: context.bodyTextMedium.copyWith(fontSize: 16, color: AppColors.hintTexFieldGrey),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: FormValidator.emptyValidator,
                        labelText: "Alias",
                        maxLines: 1,
                        controller: aliasController,
                        alignLabelWithHint: true,
                        labelStyle: context.bodyTextMedium.copyWith(fontSize: 16, color: AppColors.hintTexFieldGrey),
                      ),
                    ],
                  ),
                  if (state.status == CreateNftStatus.loading) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  ] else ...{
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                              radius: 10,
                              buttonText: "Create",
                              onTap: () {
                                createERC721();
                              }),
                        )
                      ],
                    )
                  },
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void createERC721() async {
    String name = nameController.text;
    String symbol = symbolController.text;
    String alias = aliasController.text;

    if (name.isNotEmpty && symbol.isNotEmpty && alias.isNotEmpty && selectedNetworkId != null) {
      createNftCubit.createERC721(name: name, symbol: symbol, alias: alias, network: selectedNetworkId!);
    } else {
      AppConstants.showToast(context, "Complete all fields please");
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

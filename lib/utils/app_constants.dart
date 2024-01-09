
import 'dart:io';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_wallet/models/db/shared_payment.dart';
import 'package:social_wallet/models/db/shared_payment_response_model.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/models/tokens_info_model.dart';

import '../di/injector.dart';
import '../models/db/user.dart';
import 'app_colors.dart';
import 'locale/app_localization.dart';
import '../utils/helpers/extensions/context_extensions.dart';


@immutable
class AppConstants {
  const AppConstants._();

  static const double paddingHorizontalPercentage = 0.09;
  static const double percetageOfScreenHeightBottomSheet = 0.95;
  static const String vottunApi = "https://api.vottun.tech/core/v1/";

  //todo pending check actions for use email already registered in vottun service
  static const String testEmail = "test_srs_1@yopmail.com";
  static const String testUsername = "test_srs_1";
  static const String testPassword = "Doonamis.2022!";

  static String getCreateWalletUrl({required String hash, required String username}) {
    return "https://wallet.vottun.io/?hash=$hash&username=$username";
  }

  static AppLocalization getStrings(BuildContext context) {
    return AppLocalization.of(context)!;
  }
  static getHeightBoxConstraintForModalBottomSheet(BuildContext context, {double? value}) =>
      BoxConstraints(maxHeight: ContextUtils(context).screenHeight * (value ?? percetageOfScreenHeightBottomSheet));

  static EdgeInsetsGeometry getScreenPadding(BuildContext context) {
    return EdgeInsets.only(
      top: ContextUtils(context).screenHeight * 0.05,
      right: ContextUtils(context).screenWidth * paddingHorizontalPercentage,
      left: ContextUtils(context).screenWidth * paddingHorizontalPercentage,
      bottom: ContextUtils(context).screenHeight * 0.03,
    );
  }

  static User? getCurrentUser() {
    return getKeyValueStorage().getCurrentUser();
  }

  static void showBottomDialog({
    required BuildContext context,
    required Widget body,
    bool? enableDrag,
    bool? isScrollControlled,
    double? heightBoxConstraintRate
  }) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        enableDrag: enableDrag ?? false,
        //constraints: AppConstants.getHeightBoxConstraintForModalBottomSheet(context, value: heightBoxConstraintRate ?? 0.75),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
        ),
        backgroundColor: AppColors.bottomDialogBackgroundColor,
        builder: (context) {
          return Scaffold(
              resizeToAvoidBottomInset: true,
              body: body
          );
        });
  }

  static double getToolbarSize(BuildContext context) {
    return ContextUtils(context).screenHeight * 0.080;
  }

  static void showToast(BuildContext context, String message, {Function()? onError}) {
    if (onError != null) {
      onError();
    }
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 3);
  }

  static String trimAddress(String? address) {
    String userAddress = "";
    if (address != null) {
      if (address.isNotEmpty) {
        userAddress = address;
        userAddress = '${address.substring(0, 8)}...${address.substring(address.length - 8, address.length)}';
      }
    }
    return userAddress;
  }
  
  static void getTokenInfoList() {
    List<TokensInfoModel> tokenList = List.empty(growable: true);
    bool isMainnet = getKeyValueStorage().getIsMainnetEnabled();
    
    if (isMainnet) {
      tokenList.addAll([
        TokensInfoModel(networkId: 1, tokenName: "Ethereum Mainnet", tokenSymbol: "ETH", tokenAddress: "", balance: "", decimals: 18, isNative: true)
      ]);
    } else {
      
    }
  }

  static String parseTokenBalanceFromHex(String tokenBalance, int decimals) {
    BigInt intValue = BigInt.parse(tokenBalance);
    String result = (intValue / BigInt.from(10).pow(decimals)).toStringAsFixed(2);
    return result;
  }

  static BigInt parseTokenBalanceBigInt(String tokenBalance, int decimals) {
    BigInt intValue = BigInt.parse(tokenBalance);
    String result = (intValue / BigInt.from(10).pow(decimals)).toStringAsFixed(2);
    return BigInt.parse(result);
  }

  static BigInt toWei(double tokenBalance, int decimals) {
    //String result = (tokenBalance * BigInt.from(10).pow(decimals)).toString();
    String result = (tokenBalance * pow(10, decimals)).toInt().toString();
    return BigInt.parse(result);
  }

  static String parseTokenBalance(String tokenBalance, int decimals) {
    double parsedValue = double.parse(tokenBalance);
    if (parsedValue == 0.0) {
      return "";
    }
    BigInt intValue = BigInt.parse(parsedValue.toInt().toString());
    String result = (intValue / BigInt.from(10).pow(decimals)).toStringAsFixed(2);
    return result;
  }

  static int getNumDecimalsAfterPoint(double value) {
    int numDecimals = value.toString().split(".")[1].length;
    if (numDecimals < 2) {
      numDecimals = 2;
    }
    return numDecimals;
  }

  static Future<List<String>?> showCustomTextInputDialog({
    required BuildContext context,
    required String title,
    String? message,
    bool? barrierDismissible,
    bool? canPop,
    required String okLabel,
    required String cancelLabel,
    required List<DialogTextField> textFields,
    bool? fullyCapitalizedForMaterial
  }) async {
    List<String>? result = await showTextInputDialog(
        context: context,
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        okLabel: okLabel,
        canPop: canPop ?? true,
        barrierDismissible: barrierDismissible ?? true,
        fullyCapitalizedForMaterial: fullyCapitalizedForMaterial ?? false,
        style: Platform.isIOS ? AdaptiveStyle.iOS : AdaptiveStyle.material,
        textFields: textFields
    );
    return result;

  }

  static String getSharedPaymentStatus({
    required SharedPaymentResponseModel sharedPayment,
    required int txCurrNumConfirmation,
    required bool hasUserConfirmedTx,
    required bool isExecuted,
  }) {
    bool isOwner = (sharedPayment.sharedPayment.ownerAddress ?? '') == getKeyValueStorage().getUserAddress();
    int totalConfirmations = sharedPayment.sharedPayment.numConfirmations;
    SharedPaymentUsers? sharedPaymentUsers;

    if (!isOwner && sharedPayment.sharedPaymentUser != null) {
      sharedPaymentUsers = sharedPayment.sharedPaymentUser!.where((element) => (element.userAddress == getKeyValueStorage().getUserAddress()) && (getKeyValueStorage().getUserAddress()?.isNotEmpty ?? false)).firstOrNull;
    }

    if (txCurrNumConfirmation == 0) {
      if (sharedPaymentUsers != null) {
        if (!hasUserConfirmedTx && sharedPaymentUsers.hasPayed == 1) {
          return "PAYED";
        }
      }
      return 'PENDING';
    }

    if (txCurrNumConfirmation < totalConfirmations) {
      if (isOwner) {
        return "STARTED";
      } else {
        if (sharedPaymentUsers != null && !hasUserConfirmedTx) {
          if (sharedPaymentUsers.hasPayed == 0) {
            return "PENDING";
          } else if (sharedPaymentUsers.hasPayed == 1) {
            return "PAYED";
          }
        }
        if (hasUserConfirmedTx) {
          return "CONFIRMED";
        }
        return "PENDING";
      }
    } else if (txCurrNumConfirmation == totalConfirmations) {
      if (isOwner) {
        if (isExecuted) {
          return "FINISH";
        }
        return "READY";
      } else {
        return "FINISH";
      }
    }
    return "ERROR";
  }

  static Color getSharedPaymentStatusColor({
    required String status
  }) {
    switch (status) {
    //only for owner
      case "STARTED":
        return Colors.blue;
      case "PENDING":
        return Colors.orange;
      case "SUBMITTED":
        return Colors.pink;
      case "CONFIRMED":
        return Colors.blueAccent;
      case "FINISH":
        return Colors.blueGrey;
      case "PAYED":
      case "READY":
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  /*static void openAppInStore({
    required bool isAndroid,
    required String packageName,
    required String appStoreId
  }) {
    if (isAndroid) {
      OpenStore.instance.open(
        androidAppBundleId: packageName,
      );
    } else {
      final url = Uri.parse(
        "https://apps.apple.com/es/app/id$appStoreId"
      );
      launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static double getToolbarSize() {
    return 110;
  }*/
}

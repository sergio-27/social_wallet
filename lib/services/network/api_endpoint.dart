import 'package:flutter/cupertino.dart';
import 'package:social_wallet/utils/config/config_props.dart';

import '../../utils/app_constants.dart';

@immutable
class ApiEndpoint {
  const ApiEndpoint._();

/// It is supplied at the time of building the apk or running the app:
/// ------------------------
/// BUILD CONFIGS
/// ------------------------
/// -- PRE --
/// flutter build apk --debug --flavor pre --dart-define=PROD=false
/// flutter build apk --release --flavor pre --dart-define=PROD=false
/// flutter build appbundle --debug --flavor pre --dart-define=PROD=false
/// flutter build ipa --debug --dart-define=PROD=false
/// flutter build ipa --release --dart-define=PROD=false
/// -- PRO --
/// flutter build apk --release --flavor pro --dart-define=PROD=true
/// flutter build apk --debug --flavor pro --dart-define=PROD=true
/// flutter build appbundle --release --flavor pro --dart-define=PROD=true
/// flutter build ipa --debug --dart-define=PROD=true
/// flutter build ipa --release --dart-define=PROD=true
/// -------------------------
/// RUN (Example)
/// flutter run --debug --flavor pre --dart-define=PROD=false
/// ...
///

  static const bool isProEnvironment = bool.fromEnvironment(
    'PROD',
    defaultValue: false,
  );

  static const String baseUrl = "https://api.vottun.tech/";
  static const String corePath = "core/v1/evm";
  static const String ercApiPath = "erc/v1";
  static const String custWallPath = "cwll/v1";


  static String smartContract(SmartContractEndpoint endpoint, {String? token}) {
    var path = corePath;
    switch (endpoint) {
      case SmartContractEndpoint.deploySmartContract: return '$path/contract/deploy';
    }
  }

  static String network(NetworkEndpoint endpoint, {String? token}) {
    var path = corePath;
    switch (endpoint) {
      case NetworkEndpoint.getAvailableNetworks: return '$path/info/chains';
    }
  }

  static String alchemy({required int networkId}) {
    switch (networkId) {
      case 80001: return ConfigProps.alchemyApiKeyMumbaiUrl;
      case 5: return ConfigProps.alchemyApiKeyGoerliUrl;
      default:
        return ConfigProps.alchemyApiKeyGoerliUrl;
    }
  }

  static String balance(BalanceEndpoint endpoint, {String? accountAddress, int? networkId}) {
    var pathEvm = corePath;
    var pathErcApi = ercApiPath;

    switch (endpoint) {
      case BalanceEndpoint.getNativeBalance: return '$pathEvm/chain/$accountAddress/balance?network=$networkId';
      case BalanceEndpoint.getERC721Balance: return '$pathErcApi/erc721/balanceOf';
      case BalanceEndpoint.getNonNativeERC20Balance: return '$pathErcApi/erc20/balanceOf';
    }
  }

  static String custWallet(CustodiedWalletEndpoint endpoint, {int? strategy, String? userEmail}) {
    var path = custWallPath;
    var txPath = corePath;
    switch (endpoint) {
      case CustodiedWalletEndpoint.getNewHash: return '$path/hash/new';
      case CustodiedWalletEndpoint.getCustodiedWallets: return '$path/evm/wallet/custodied/list';
      case CustodiedWalletEndpoint.sendTransaction: return '$txPath//wallet/custodied/transact/mutable?strategy=$strategy';
      case CustodiedWalletEndpoint.sendOTP: return '$path/2fa/signature/otp/new?email=$userEmail';
      case CustodiedWalletEndpoint.sendTxFromCustodiedWallet: return '$txPath/wallet/custodied/transfer?strategy=$strategy';
    }
  }

  static String erc20(ERC20Endpoint endpoint) {
    var path = ercApiPath;
    switch (endpoint) {
      case ERC20Endpoint.transfer: return '$path/erc20/transfer';
    }
  }


}

enum AuthEndpoint {
  authorization, userInfo, resetPassword, changePassword
}

enum NetworkEndpoint {
  getAvailableNetworks
}

enum BalanceEndpoint {
  getNativeBalance, getERC721Balance, getNonNativeERC20Balance
}

enum CustodiedWalletEndpoint {
  getNewHash, getCustodiedWallets, sendTransaction, sendOTP, sendTxFromCustodiedWallet
}

enum ERC20Endpoint {
  transfer
}

enum SmartContractEndpoint {
  deploySmartContract
}
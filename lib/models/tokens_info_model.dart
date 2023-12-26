class TokensInfoModel {

  int    networkId;
  String tokenName;
  String tokenSymbol;
  String? tokenAddress;
  String balance;
  bool isNative;

  TokensInfoModel({
    required this.networkId,
    required this.tokenName,
    required this.tokenSymbol,
    required this.balance,
    required this.isNative,
    this.tokenAddress
  });

}
class TokensInfoModel {

  int    networkId;
  String tokenName;
  String tokenSymbol;
  String tokenAddress;
  bool isNative;

  TokensInfoModel({
    required this.networkId,
    required this.tokenName,
    required this.tokenSymbol,
    required this.isNative,
    required this.tokenAddress
  });

}
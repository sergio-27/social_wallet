part of 'wallet_nfts_cubit.dart';


enum WalletNFTsStatus {
  initial, loading, walletCreated, success, error
}

class WalletNFTsState {

  final WalletNFTsStatus status;
  List<OwnedNFTsData>? ownedNFTsList;

  WalletNFTsState({
    this.status = WalletNFTsStatus.initial,
    this.ownedNFTsList,
  });

  WalletNFTsState copyWith({
    List<OwnedNFTsData>? ownedNFTsList,
    WalletNFTsStatus? status
  }) {
    return WalletNFTsState(
        ownedNFTsList: ownedNFTsList ?? this.ownedNFTsList,
        status: status ?? this.status,
    );
  }
}

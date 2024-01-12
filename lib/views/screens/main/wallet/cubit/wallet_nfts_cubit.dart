import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/alchemy_repository.dart';
import 'package:social_wallet/api/repositories/balance_repository.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/owned_nfts_data.dart';
import 'package:social_wallet/models/owned_token_account_info_model.dart';
import 'package:social_wallet/models/owned_nfts_response.dart';
import 'package:social_wallet/models/wallet_hash_request_model.dart';
import 'package:social_wallet/models/wallet_hash_response_model.dart';

import '../../../../../models/custodied_wallets_info_response.dart';
import '../../../../../models/network_info_model.dart';

part 'wallet_nfts_state.dart';

class WalletNFTsCubit extends Cubit<WalletNFTsState> {

  BalanceRepository balanceRepository;
  WalletRepository walletRepository;
  AlchemyRepository alchemyRepository;

  WalletNFTsCubit({
    required this.balanceRepository,
    required this.walletRepository,
    required this.alchemyRepository
  }) : super(WalletNFTsState());


  Future<void> getAccountNFTs({required int networkId}) async {
    emit(state.copyWith(
        status: WalletNFTsStatus.loading
    ));
    try {
      String? currUserAddress = getKeyValueStorage().getUserAddress() ?? "";
      OwnedNFTsResponse? response = await alchemyRepository.getAccountNFTs(
          ownerAddress: currUserAddress,
          networkId: networkId
      );
      if (response != null) {
       emit(state.copyWith(
         ownedNFTsList: response.ownedNfts,
           status: WalletNFTsStatus.success
       ));
      } else {
        emit(state.copyWith(
            ownedNFTsList: [],
            status: WalletNFTsStatus.success
        ));
      }
    } catch (error) {
      print(error);
      emit(state.copyWith(
          ownedNFTsList: [],
          status: WalletNFTsStatus.success
      ));
    }
  }
}

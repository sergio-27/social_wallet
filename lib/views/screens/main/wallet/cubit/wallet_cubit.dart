import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/alchemy_repository.dart';
import 'package:social_wallet/api/repositories/balance_repository.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/models/owned_token_account_info_model.dart';
import 'package:social_wallet/models/wallet_hash_request_model.dart';
import 'package:social_wallet/models/wallet_hash_response_model.dart';

import '../../../../../models/custodied_wallets_info_response.dart';
import '../../../../../models/network_info_model.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {

  BalanceRepository balanceRepository;
  WalletRepository walletRepository;
  AlchemyRepository alchemyRepository;

  WalletCubit({
    required this.balanceRepository,
    required this.walletRepository,
    required this.alchemyRepository
  }) : super(WalletState());

  Future<List<CustodiedWalletsInfoResponse>?> getCustomerCustiodedWallets() async {
    try {
      List<CustodiedWalletsInfoResponse>? response = await walletRepository.getCustomerCustodiedWallets();
      if (response != null) {
        return response;
      }
      return response;
    } catch (error) {
      return null;
    }
  }

  void setSelectedNetwork(NetworkInfoModel networkInfoModel) {
    emit(
        state.copyWith(
            selectedNetwork: networkInfoModel
        )
    );
  }

  Future<WalletHashResponseModel?> createWallet(WalletHashRequestModel walletHashRequestModel) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      WalletHashResponseModel? response = await walletRepository.getNewHash(
          walletHashRequestModel: walletHashRequestModel
      );
      if (response != null) {
        emit(
            state.copyWith(
              walletHashResponseModel: response,
              status: WalletStatus.success,
            )
        );
        return response;
      }
      return null;
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(status: WalletStatus.error));
      return null;
    }
  }
}

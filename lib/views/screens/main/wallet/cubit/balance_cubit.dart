import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/balance_repository.dart';
import 'package:social_wallet/models/balance_response_model.dart';
import 'package:social_wallet/models/network_info_model.dart';
import 'package:social_wallet/models/token_metadata_model.dart';
import 'package:social_wallet/models/token_wallet_item.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/utils/app_constants.dart';

import '../../../../../api/repositories/alchemy_repository.dart';
import '../../../../../models/owned_token_account_info_model.dart';


part 'balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {

  BalanceRepository balanceRepository;
  AlchemyRepository alchemyRepository;

  BalanceCubit({
    required this.balanceRepository,
    required this.alchemyRepository
  }) : super(BalanceState());



  Future<void> getAccountBalance({
    required String accountToCheck,
    required NetworkInfoModel networkInfoModel,
    required int networkId
  }) async {
    emit(state.copyWith(status: BalanceStatus.loading));
    try {
      BalanceResponseModel? response = await balanceRepository.getNativeCryptoBalance(
          accountAddress: accountToCheck,
          networkId: networkId
      );
      TokenWalletItem tokenWalletItem = TokenWalletItem();

      if (response != null) {
        //todo native token
        TokensInfoModel tokenInfoModel = TokensInfoModel(
            networkId: networkId,
            tokenName: networkInfoModel.name,
            tokenSymbol: networkInfoModel.symbol,
            balance: response.balance.toString(),
            isNative: true
        );
        tokenWalletItem.mainTokenInfoModel = tokenInfoModel;
        tokenWalletItem.erc20TokensList = List.empty(growable: true);

        if (networkId == 5 || networkId == 1) {
          OwnedTokenAccountInfoModel? ownedTokens = await _getAccountTokenBalance(userAddress: accountToCheck);

          if (ownedTokens != null) {
            for (var element in ownedTokens.tokenBalances) {
              TokenMetadataModel? tokenMetadata = await alchemyRepository.getTokenMetadata(tokenAddress: element.contractAddress);
              if (tokenMetadata != null) {
                tokenWalletItem.erc20TokensList?.add(
                    TokensInfoModel(
                        networkId: networkId,
                        tokenName: tokenMetadata.name,
                        tokenAddress: element.contractAddress,
                        tokenSymbol: tokenMetadata.symbol,
                        balance: AppConstants.parseTokenBalance(element.tokenBalance),
                        isNative: false
                    )
                );
              }
            }
          }
        }


        emit(
            state.copyWith(
              networkInfoModel: networkInfoModel,
              walletTokenItemList: tokenWalletItem,
              status: BalanceStatus.success,
            )
        );
      }
    } catch (error) {
      emit(state.copyWith(status: BalanceStatus.error));
    }
  }

  //todo see way to get symbol and currency name
  Future<void> getCryptoNativeBalance({
    required String accountToCheck,
    required NetworkInfoModel networkInfoModel,
    required int networkId
  }) async {
    emit(state.copyWith(status: BalanceStatus.loading));
    try {
      BalanceResponseModel? response = await balanceRepository.getNativeCryptoBalance(
          accountAddress: accountToCheck,
          networkId: networkId
      );
      if (response != null) {
        emit(
            state.copyWith(
              networkInfoModel: networkInfoModel,
              balance: response.balance,
              status: BalanceStatus.success,
            )
        );
      }
    } catch (error) {
      emit(state.copyWith(status: BalanceStatus.error));
    }
  }

  Future<OwnedTokenAccountInfoModel?> _getAccountTokenBalance({required String userAddress}) async {
    try {
      OwnedTokenAccountInfoModel? response = await alchemyRepository.getTokenInfoOwnedByAddress(userAddress: userAddress);
      return response;
    } catch (error) {
      print(error);
      return null;
      //emit(state.copyWith(status: WalletStatus.error));
    }
  }
}

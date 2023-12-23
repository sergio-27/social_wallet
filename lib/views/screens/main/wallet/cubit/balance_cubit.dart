import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/balance_repository.dart';
import 'package:social_wallet/models/balance_response_model.dart';
import 'package:social_wallet/models/network_info_model.dart';


part 'balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {

  BalanceRepository balanceRepository;

  BalanceCubit({
    required this.balanceRepository
  }) : super(BalanceState());

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
}

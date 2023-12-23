part of 'balance_cubit.dart';


enum BalanceStatus {
  initial, loading, success, error
}

class BalanceState {

  final BalanceStatus status;
  //todo unify model of network info and balance
  NetworkInfoModel? networkInfoModel;
  double? balance;
  final String errorMessage;

  BalanceState({
    this.status = BalanceStatus.initial,
    this.networkInfoModel,
    this.balance,
    this.errorMessage = ""
  });


  BalanceState copyWith({
    String? errorMessage,
    NetworkInfoModel? networkInfoModel,
    double? balance,
    BalanceStatus? status
  }) {
    return BalanceState(
      networkInfoModel: networkInfoModel ?? this.networkInfoModel,
        balance: balance ?? this.balance,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

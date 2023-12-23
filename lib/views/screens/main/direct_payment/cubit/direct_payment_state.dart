part of 'direct_payment_cubit.dart';


enum DirectPaymentStatus {
  initial, loading, success, error
}

class DirectPaymentState {

  final DirectPaymentStatus status;

  CurrencyModel? selectedCurrencyModel;
  NetworkInfoModel? selectedNetwork;
  String? selectedContactName;
  String? selectedContactAddress;
  SendTxResponseModel? sendTxRespModel;

  DirectPaymentState({
    this.status = DirectPaymentStatus.initial,
    this.selectedNetwork,
    this.selectedCurrencyModel,
    this.selectedContactName,
    this.selectedContactAddress,
    this.sendTxRespModel
  });

  DirectPaymentState copyWith({
    DirectPaymentStatus? status,
    int? selectedNetworkId,
    CurrencyModel? selectedCurrencyModel,
    String? selectedContactName,
    String? selectedContactAddress,
    NetworkInfoModel? selectedNetwork,
    SendTxResponseModel? sendTxRespModel
  }) {
    return DirectPaymentState(
      status: status ?? this.status,
      selectedNetwork: selectedNetwork ?? this.selectedNetwork,
      selectedCurrencyModel: selectedCurrencyModel ?? this.selectedCurrencyModel,
      selectedContactName: selectedContactName ?? this.selectedContactName,
      selectedContactAddress: selectedContactAddress ?? this.selectedContactAddress,
      sendTxRespModel: sendTxRespModel ?? this.sendTxRespModel,
    );
  }
}

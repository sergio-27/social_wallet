part of 'shared_payment_cubit.dart';


enum SharedPaymentStatus {
  initial, loading, success, error
}

class SharedPaymentState {

  final SharedPaymentStatus status;
  NetworkInfoModel? selectedNetwork;


  SharedPaymentState({
    this.status = SharedPaymentStatus.initial,
    this.selectedNetwork
  });


  SharedPaymentState copyWith({
    SharedPaymentStatus? status,
    NetworkInfoModel? selectedNetwork,

  }) {
    return SharedPaymentState(
      status: status ?? this.status,
      selectedNetwork: selectedNetwork ?? this.selectedNetwork,
    );
  }
}

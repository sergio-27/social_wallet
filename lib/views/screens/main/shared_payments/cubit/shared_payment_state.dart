part of 'shared_payment_cubit.dart';


enum SharedPaymentStatus {
  initial, loading, success, error
}

class SharedPaymentState {

  final SharedPaymentStatus status;
  NetworkInfoModel? selectedNetwork;
  List<SharedPaymentResponseModel>? sharedPaymentResponseModel;


  SharedPaymentState({
    this.status = SharedPaymentStatus.initial,
    this.selectedNetwork,
    this.sharedPaymentResponseModel
  });


  SharedPaymentState copyWith({
    SharedPaymentStatus? status,
    NetworkInfoModel? selectedNetwork,
    List<SharedPaymentResponseModel>? sharedPaymentResponseModel
  }) {
    return SharedPaymentState(
      status: status ?? this.status,
      selectedNetwork: selectedNetwork ?? this.selectedNetwork,
      sharedPaymentResponseModel: sharedPaymentResponseModel ?? this.sharedPaymentResponseModel
    );
  }
}

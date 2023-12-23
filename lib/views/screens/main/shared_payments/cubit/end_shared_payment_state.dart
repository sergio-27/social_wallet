part of 'end_shared_payment_cubit.dart';


enum EndSharedPaymentStatus {
  initial, loading, success, error
}

class EndSharedPaymentState {

  final EndSharedPaymentStatus status;


  EndSharedPaymentState({
    this.status = EndSharedPaymentStatus.initial,

  });


  EndSharedPaymentState copyWith({
    EndSharedPaymentStatus? status,
  }) {
    return EndSharedPaymentState(
      status: status ?? this.status,
    );
  }
}

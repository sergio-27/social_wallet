import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_payment.freezed.dart';
part 'shared_payment.g.dart';

@freezed
class SharedPayment with _$SharedPayment {
  const factory SharedPayment({
    int? id,
    required int ownerId,
    required double totalAmount,
    required String status,
    required String currencyName,
    required String currencySymbol,
    required int networkId,
    required int creationTimestamp
  }) = _SharedPayment;

  factory SharedPayment.fromJson(Map<String, dynamic> json) =>
      _$SharedPaymentFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_payment.freezed.dart';
part 'shared_payment.g.dart';

@freezed
class SharedPayment with _$SharedPayment {
  const factory SharedPayment({
    int? id,
    required int ownerId,
    required double totalAmount,
    @JsonKey(includeFromJson: false, includeToJson: false)
    double? tokenSelectedBalance,
    int? tokenDecimals,
    required String status,
    required String ownerUsername,
    String? ownerEmail,
    String? ownerAddress,
    required int numConfirmations,
    required String currencyName,
    required String currencySymbol,
    String? currencyAddress,
    required String userAddressTo,
    required int networkId,
    required int creationTimestamp
  }) = _SharedPayment;

  factory SharedPayment.fromJson(Map<String, dynamic> json) =>
      _$SharedPaymentFromJson(json);
}

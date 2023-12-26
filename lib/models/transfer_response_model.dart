import 'package:freezed_annotation/freezed_annotation.dart';


part 'transfer_response_model.freezed.dart';
part 'transfer_response_model.g.dart';

@freezed
class TransferResponseModel with _$TransferResponseModel {
  const factory TransferResponseModel({
    required String txHash,
    required int nonce,
}) = _TransferResponseModel;

  factory TransferResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseModelFromJson(json);
}

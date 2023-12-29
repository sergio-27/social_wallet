import 'package:freezed_annotation/freezed_annotation.dart';


part 'send_tx_request_model.freezed.dart';
part 'send_tx_request_model.g.dart';

@freezed
class SendTxRequestModel with _$SendTxRequestModel {
  const factory SendTxRequestModel({
    required String contractAddress,
    String? myReference,
    int? contractSpecsId,
    required String sender,
    required int blockchainNetwork,
    required BigInt value,
    int? gasLimit,
    int? gasPrice,
    int? nonce,
    required String method,
    required List<dynamic> params,
    String? pin
}) = _SendTxRequestModel;

  factory SendTxRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SendTxRequestModelFromJson(json);
}

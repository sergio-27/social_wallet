import 'package:freezed_annotation/freezed_annotation.dart';


part 'tx_status_response_model.freezed.dart';
part 'tx_status_response_model.g.dart';

@freezed
class TxStatusResponseModel with _$TxStatusResponseModel {
  const factory TxStatusResponseModel({
    String? blockHash,
    String? blockNumber,
    String? transactionIndex
}) = _TxStatusResponseModel;

  factory TxStatusResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TxStatusResponseModelFromJson(json);
}

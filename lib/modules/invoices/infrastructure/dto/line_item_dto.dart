import 'package:freezed_annotation/freezed_annotation.dart';

part 'line_item_dto.freezed.dart';
part 'line_item_dto.g.dart';

/// Backend serializes Decimal money fields as JSON numbers (occasionally as
/// strings). Parse defensively so either form is accepted, defaulting absent /
/// null values to `0`.
double decimalFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

/// Wire shape of one invoice line item — matches the backend `LineItemDTO`.
@freezed
abstract class LineItemDto with _$LineItemDto {
  const factory LineItemDto({
    required String description,
    @JsonKey(fromJson: decimalFromJson) required double quantity,
    @JsonKey(name: 'unit_price', fromJson: decimalFromJson)
    required double unitPrice,
    @JsonKey(fromJson: decimalFromJson) required double amount,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _LineItemDto;

  factory LineItemDto.fromJson(Map<String, dynamic> json) =>
      _$LineItemDtoFromJson(json);
}
